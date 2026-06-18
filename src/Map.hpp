#pragma once

#include <Gosu/Gosu.hpp>
#include <string>
#include <vector>

class IniFile;

using Tile = std::uint8_t;

const int TILES_X = 24;
const int TILES_Y = 1024;
const int TILE_SIZE = 24;
const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int TARGET_FPS = 30;

class Map {
public:
    explicit Map(const IniFile& ini_file);

    Tile operator[](int x, int y) const;
    Tile& operator[](int x, int y);

    bool is_solid(double x, double y) const;

    void draw(double camera_y);

    double level_top() const { return m_level_top; }
    double level_bottom() const { return m_level_bottom; }

    // Read-only in Game (indexed lookups).
    const std::vector<std::string>& scripts() const { return m_scripts; }
    const std::vector<std::string>& timers() const { return m_timers; }
    // PMScripts reads and writes individual slots, so expose a mutable reference.
    std::vector<int>& vars() { return m_vars; }

    double lava_pos() const { return m_lava_pos; }
    void set_lava_pos(double pos) { m_lava_pos = pos; }

    int lava_speed() const { return m_lava_speed; }
    void set_lava_speed(int speed) { m_lava_speed = speed; }

    int lava_mode() const { return m_lava_mode; }
    void set_lava_mode(int mode) { m_lava_mode = mode; }

    int lava_time_left() const { return m_lava_time_left; }
    void set_lava_time_left(int time_left) { m_lava_time_left = time_left; }

    int lava_frame() const { return m_lava_frame; }
    void set_lava_frame(int frame) { m_lava_frame = frame; }

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
    int m_lava_time_left;
    int m_lava_frame;
    double m_level_top;
    double m_level_bottom;

    std::vector<std::unique_ptr<Gosu::Image>> m_tile_images;

    std::unique_ptr<Gosu::Image> m_map_image;
    std::unique_ptr<Gosu::Image> m_sky_image;
};
