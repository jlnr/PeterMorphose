#pragma once

#include <Gosu/Gosu.hpp>
#include <string>
#include <vector>

class IniFile;

using Tile = std::uint8_t;

const int TILES_X = 24;
const int TILES_Y = 1024;
const int TILE_SIZE = 24;
const int HEIGHT = 480;

class Map {
public:
    explicit Map(const IniFile& ini_file);

    Tile operator[](int x, int y) const;
    Tile& operator[](int x, int y);

    bool is_solid(double x, double y) const;

    void draw(double camera_y);

    double level_top() const { return m_level_top; }
    double level_bottom() const { return m_level_bottom; }

    double lava_pos() const { return m_lava_pos; }
    void set_lava_pos(double pos) { m_lava_pos = pos; }

private:
    void render_sky(double camera_y);
    void render_map();

    std::vector<Tile> m_tiles;
    std::vector<std::string> m_scripts;
    std::vector<std::string> m_timers;
    std::vector<int> m_vars;
    int m_sky;

    double m_lava_pos;
    int m_lava_speed;
    int m_lava_mode;
    double m_level_top;
    double m_level_bottom;

    std::vector<std::unique_ptr<Gosu::Image>> m_tile_images;

    std::unique_ptr<Gosu::Image> m_map_image;
    std::unique_ptr<Gosu::Image> m_sky_image;
};
