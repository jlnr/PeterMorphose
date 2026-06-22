#include "Map.hpp"
#include "Constants.hpp"
#include "helpers/IniFile.hpp"
#include "helpers/String.hpp"
#include <fstream>
#include <iomanip>
#include <sstream>

Map::Map(const IniFile& ini_file)
{
    for (int y = 0; y < TILES_Y; ++y) {
        std::string row
            = ini_file["Map", std::to_string(y)].value_or(std::string(TILES_X * 2, '0'));

        for (int x = 0; x < TILES_X; ++x) {
            if (x * 2 + 1 < row.length()) {
                std::string hex = row.substr(x * 2, 2);
                m_tiles[y * TILES_X + x] = string_to_int(hex, 16);
            }
        }
    }

    m_sky = string_to_int(ini_file["Map", "Sky"].value_or("0"));

    lava_frame = 0;
    lava_time_left = 0;
    lava_speed = string_to_int(ini_file["Map", "LavaSpeed"].value_or("1"));
    lava_mode = string_to_int(ini_file["Map", "LavaMode"].value_or("0"));
    lava_pos
        = string_to_int(ini_file["Map", "LavaPos"].value_or(std::to_string(TILES_Y))) * TILE_SIZE;

    m_level_top = string_to_int(ini_file["Map", "LevelTop"].value_or("0")) * TILE_SIZE;
    m_level_bottom = std::min(1024, lava_pos / TILE_SIZE);

    auto original_tiles = Gosu::load_tiles("media/tiles.bmp", TILE_SIZE, TILE_SIZE, Gosu::IF_RETRO);
    for (auto& tile : original_tiles) {
        // TODO: Handle level-specific tile overrides.
        m_tile_images.push_back(std::move(tile));
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
    return tile >= 0x70 && tile <= 0xe0;
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
        = Gosu::load_tiles("media/skies.png", 144, 120, Gosu::IF_RETRO);
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
        // Tiles 0x70 to 0xE0 are solid
        CHECK(map.is_solid(0 * TILE_SIZE, 0 * TILE_SIZE) == false); // 0x00
        CHECK(map.is_solid(0 * TILE_SIZE, 1 * TILE_SIZE) == true); // 0x70

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

        // Otherwise, it is not solid, so that objects can fall into it.
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
}
