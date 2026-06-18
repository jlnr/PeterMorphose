#pragma once

#include "LevelInfo.hpp"
#include "Map.hpp"
#include "State.hpp"
#include "helpers/IniFile.hpp"
#include <string>

class IniFile;
class GameState : public State
{
public:
    explicit GameState(const IniFile& ini_file);

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    enum class Result
    {
        PLAYING,
        WON,
        LOST,
    };

    void lose(const std::string& reason);
    void draw_status_bar();

    Map m_map;

    Result m_result = Result::PLAYING;
    bool m_paused = false;
    std::string m_reason;

    double m_view_pos;
    int m_frame = -1;
    int m_frame_fading_box = 16;

    int m_player_top_pos = 1024;
    int m_lava_top_pos = 1024;

    std::string m_message_text;
    int m_message_opacity = 0;

    int m_score = 0;
    int m_keys = 0;
    int m_stars = 0;
    int m_ammo = 0;
    int m_bombs = 0;
    int m_stars_goal = 0;

    // TODO: The object system and PMScript have not been ported yet.
};
