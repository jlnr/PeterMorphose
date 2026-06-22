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

    explicit Map(const IniFile& ini_file);

    int level_top() const { return m_level_top; }
    int level_bottom() const { return m_level_bottom; }

    Tile operator[](int x, int y) const;
    Tile& operator[](int x, int y);

    /// Whether the given point (not tile coordinate!) is solid.
    bool is_solid(int x, int y) const;

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
};
