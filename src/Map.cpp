#include "Map.hpp"
#include "Constants.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/IniFile.hpp"
#include "helpers/String.hpp"
#include <fstream>
#include <iomanip>
#include <sstream>
#include <stdexcept>

Map::Map(const IniFile& ini)
{
    for (int y = 0; y < TILES_Y; ++y) {
        std::string row
            = ini.string("Map", std::to_string(y)).value_or(std::string(TILES_X * 2, '0'));

        for (int x = 0; x < TILES_X; ++x) {
            if (x * 2 + 1 < row.length()) {
                m_tiles[y * TILES_X + x] = hex_chars_to_int(row, x * 2, 2);
            }
        }
    }

    m_sky = ini.integer("Map", "Sky").value_or(0);

    lava_frame = 0;
    lava_time_left = 0;
    lava_speed = ini.integer("Map", "LavaSpeed").value_or(1);
    lava_mode = ini.integer("Map", "LavaMode").value_or(0);
    lava_pos = ini.integer("Map", "LavaPos").value_or(TILES_Y) * TILE_SIZE;
    lava_score = ini.integer("Map", "LavaScore").value_or(1) != 0;

    m_level_top = ini.integer("Map", "LevelTop").value_or(0) * TILE_SIZE;
    m_level_bottom = std::min(1024, lava_pos / TILE_SIZE);

    for (int index = 0; index < 256; ++index) {
        // A level may replace the image of any tile through its [Tiles] section.
        if (std::optional<std::string> tile = ini.string("Tiles", byte_to_hex(index))) {
            m_tile_images.push_back(decode_tile(*tile));
        }
        else {
            m_tile_images.push_back(tile_image(TileID(index)));
        }
    }
}

Tile Map::operator[](int x, int y) const
{
    if (x < 0 || x >= TILES_X || y < 0 || y >= TILES_Y) {
        return 0x70;
    }
    return m_tiles[y * TILES_X + x];
}

Tile& Map::operator[](int x, int y)
{
    // Writing a tile invalidates the cached map image - it will be recreated in draw().
    m_map_image.reset();
    // Out-of-bounds accesses are redirected to a throwaway tile that will be reset to the default
    // value on every call, so reads still observe 0x70.
    static Tile out_of_bounds;
    if (x < 0 || x >= TILES_X || y < 0 || y >= TILES_Y) {
        out_of_bounds = 0x70;
        return out_of_bounds;
    }
    return m_tiles[y * TILES_X + x];
}

bool Map::is_solid(int x, int y) const
{
    if (x < 0 || y < 0 || (y > lava_pos && lava_time_left > 0)) {
        return true;
    }
    int tile_x = x / TILE_SIZE;
    int tile_y = y / TILE_SIZE;
    int tile = (*this)[tile_x, tile_y];
    return tile >= 0x70 && tile < 0xE0;
}

bool Map::do_stairs_end(int x, int y) const
{
    Tile tile = (*this)[x, y];
    // Downstairs: look for a matching door leading upstairs, or a hole to fall out of.
    if (tile == TILE_STAIRS_DOWN || tile == TILE_STAIRS_DOWN_2) {
        while (true) {
            ++y;
            if (y >= TILES_Y) {
                return false;
            }
            tile = (*this)[x, y];
            if (tile == TILE_STAIRS_UP || tile == TILE_STAIRS_UP_2 || tile == TILE_STAIRS_END
                || tile == TILE_STAIRS_END_2) {
                return true;
            }
        }
    }
    // Upstairs: look for a matching door leading downstairs, or a hole to fall out of.
    if (tile == TILE_STAIRS_UP || tile == TILE_STAIRS_UP_2) {
        while (true) {
            --y;
            if (y < level_top() / TILE_SIZE) {
                return false;
            }
            tile = (*this)[x, y];
            if (tile == TILE_STAIRS_DOWN || tile == TILE_STAIRS_DOWN_2 || tile == TILE_STAIRS_END
                || tile == TILE_STAIRS_END_2) {
                return true;
            }
        }
    }
    return false;
}

void Map::draw(int camera_y)
{
    if (!m_map_image) {
        m_map_image = std::make_unique<Gosu::Image>(
            Gosu::record(TILES_X * TILE_SIZE, TILES_Y * TILE_SIZE, [&] { render_map(); }));
    }
    if (!m_sky_image) {
        m_sky_image = std::make_unique<Gosu::Image>(
            Gosu::record(TILES_X * TILE_SIZE, WINDOW_HEIGHT + 120, [&] { render_sky(); }));
    }

    if (m_sky == 0) {
        m_sky_image->draw(0, 0);
    }
    else {
        m_sky_image->draw(0, -(camera_y % 120));
    }

    m_map_image->draw(0, -camera_y);
}

void Map::render_sky()
{
    static const std::vector<Gosu::Image> skies
        = Gosu::load_tiles("media/Sky.png", 144, 120, Gosu::IF_RETRO);
    for (int y = 0; y < 5; ++y) {
        for (int x = 0; x < 4; ++x) {
            skies[m_sky].draw(x * 144, y * 120, 120);
        }
    }
}

void Map::render_map()
{
    for (int y = m_level_top / TILE_SIZE; y < TILES_Y; ++y) {
        for (int x = 0; x < TILES_X; ++x) {
            int index = (*this)[x, y];
            if (index > 0) {
                m_tile_images[index].draw(x * TILE_SIZE, y * TILE_SIZE);
            }
        }
    }
}

Gosu::Image Map::decode_tile(const std::string& data)
{
    // The override encodes a TILE_SIZE x TILE_SIZE image as "RRGGBB" hex pixels.
    if (data.length() != TILE_SIZE * TILE_SIZE * 6) {
        throw std::invalid_argument("Invalid custom tile length: " + std::to_string(data.length()));
    }

    Gosu::Bitmap bitmap(TILE_SIZE, TILE_SIZE); // still fully transparent
    for (int row = 0; row < TILE_SIZE; ++row) {
        for (int col = 0; col < TILE_SIZE; ++col) {
            const std::size_t src = (col * TILE_SIZE + row) * 6;
            const int r = hex_chars_to_int(data, src + 0, 2, 0);
            const int g = hex_chars_to_int(data, src + 2, 2, 0);
            const int b = hex_chars_to_int(data, src + 4, 2, 0);
            // Fuchsia is used as a color key -> leave these pixels transparent.
            if (r != 0xFF || g != 0x00 || b != 0xFF) {
                bitmap.pixel(col, row) = Gosu::Color(r, g, b);
            }
        }
    }
    return Gosu::Image(bitmap, Gosu::IF_RETRO);
}

#include <doctest.h>

TEST_CASE("Map")
{
    std::stringstream ss;
    ss << "[Map]\n";
    ss << "0=000102030405060708090A0B0C0D0E0F101112131415\n"; // 22 tiles
    ss << "1=707172737475767778797A7B7C7D7E7F808182838485\n";
    ss << "Sky=1\n";
    ss << "LavaPos=1024\n";

    IniFile ini(std::move(ss));
    Map map(ini);

    SUBCASE("operator[] initial values")
    {
        CHECK(map[0, 0] == 0x00);
        CHECK(map[1, 0] == 0x01);
        CHECK(map[21, 0] == 0x15);
        CHECK(map[0, 1] == 0x70);
        CHECK(map[21, 1] == 0x85);
    }

    SUBCASE("operator[] out of bounds reads default")
    {
        CHECK(map[-1, 0] == 0x70);
        CHECK(map[24, 0] == 0x70);
        CHECK(map[0, -1] == 0x70);
        CHECK(map[0, 1024] == 0x70);
    }

    SUBCASE("operator[] assignment")
    {
        map[5, 5] = 0xAB;
        CHECK(map[5, 5] == 0xAB);

        // Assigning out of bounds is harmless and does not persist.
        map[-1, 0] = 0xFF;
        CHECK(map[-1, 0] == 0x70);
    }

    SUBCASE("const operator[]")
    {
        const Map& const_map = map;
        CHECK(const_map[0, 0] == 0x00);
        CHECK(const_map[21, 1] == 0x85);
        CHECK(const_map[100, 100] == 0x70);
    }

    SUBCASE("is_solid")
    {
        // Tiles 0x70..0xDF are solid; 0xE0 (TILE_AIR_ROCKET_UP) and above are not.
        CHECK(map.is_solid(0 * TILE_SIZE, 0 * TILE_SIZE) == false); // 0x00
        CHECK(map.is_solid(0 * TILE_SIZE, 1 * TILE_SIZE) == true); // 0x70

        map[5, 5] = 0xDF;
        map[6, 5] = 0xE0;
        CHECK(map.is_solid(5 * TILE_SIZE, 5 * TILE_SIZE) == true); // 0xDF (bridge) is solid
        CHECK(map.is_solid(6 * TILE_SIZE, 5 * TILE_SIZE) == false); // 0xE0 (air rocket up) is not

        // Check that everything to the left and right of, or above the level, is considered solid.
        CHECK(map.is_solid(0, -1) == true);
        CHECK(map.is_solid(0, -547324) == true);
        CHECK(map.is_solid(-1, 0) == true);
        CHECK(map.is_solid(-84294, 0) == true);
        CHECK(map.is_solid(TILES_X * TILE_SIZE, 0) == true);
        CHECK(map.is_solid(251863, 0) == true);

        // If the lava is frozen (lava_time_left > 0), then it is also considered solid.
        map.lava_pos = 10 * TILE_SIZE;
        map.lava_time_left = 1;
        CHECK(map.is_solid(0, 11 * TILE_SIZE) == true);

        // Otherwise, it is not solid, so that objects can fall into ot.
        map.lava_time_left = 0;
        CHECK(map.is_solid(0, 11 * TILE_SIZE) == false);
    }

    SUBCASE("can read the first level")
    {
        std::ifstream file("levels/jr_Gemuetlicher_Aufstieg.pml");
        REQUIRE_MESSAGE(file.good(), "Could not open the first level for tests");

        const IniFile level1_ini(std::move(file));
        Map level1_map(level1_ini);

        // LevelTop=963, and row 963 starts with the tiles "0202".
        CHECK(level1_map.level_top() == 963 * TILE_SIZE);
        CHECK(level1_map[0, 963] == 0x02);
        CHECK(level1_map[1, 963] == 0x02);

        // Row 964 starts with "020B".
        CHECK(level1_map[0, 964] == 0x02);
        CHECK(level1_map[1, 964] == 0x0B);
    }

    SUBCASE("overridden tiles don't crash")
    {
        std::ifstream file("levels/jr_Die_zwei_Baeume.pml");
        REQUIRE_MESSAGE(file.good(),
                        "Could not open the level we use for testing overridden tiles");

        // Constructing the Map builds the overridden tile images for the indices listed in the
        // [Tiles] section (0E, 0F, 32, 33, ...); this exercises Map::decode_tile end to end.
        const IniFile level2_ini(std::move(file));
        Map level2_map(level2_ini);
    }
}
