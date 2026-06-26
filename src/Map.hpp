#pragma once

#include <Gosu/Gosu.hpp>
#include "Constants.hpp"
#include <array>

class IniFile;

using Tile = std::uint8_t;

class Map
{
public:
    int lava_pos;
    int lava_speed;
    int lava_mode;
    int lava_time_left;
    int lava_frame;

    explicit Map(const IniFile& ini);

    int level_top() const { return m_level_top; }
    int level_bottom() const { return m_level_bottom; }

    Tile operator[](int x, int y) const;
    Tile& operator[](int x, int y);

    /// Whether the given point (not tile coordinate!) is solid.
    bool is_solid(int x, int y) const;

    /// Whether the stairs at the given tile coordinates lead anywhere on the map.
    /// Enemies will not use stairs that lead out of the level.
    /// Ported from TPMMap.StairsEnd.
    bool do_stairs_end(int x, int y) const;

    void draw(int camera_y);

private:
    void render_sky();
    void render_map();

    std::array<Tile, TILES_X * TILES_Y> m_tiles;
    int m_sky;
    int m_level_top;
    int m_level_bottom;

    std::vector<Gosu::Image> m_tile_images;

    /// Cached Gosu macro that contains the whole map.
    std::unique_ptr<Gosu::Image> m_map_image;
    /// Cached Gosu macro that contains the repeating sky pattern.
    std::unique_ptr<Gosu::Image> m_sky_image;

    /// Peter Morphose levels can override tiles by providing an RGB string in the INI file.
    /// This method decodes such a tile and converts it into a Gosu::Image.
    /// @throw std::invalid_argument if the data does not have the expected length.
    static Gosu::Image decode_tile(const std::string& data);
};
