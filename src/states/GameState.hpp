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
    // The public state is inspired by TPMData in the original Delphi source code.
    Map map;
    int view_pos = 0;
    // Initial values taken from TFormPeterM.StartGame.
    int frame = 1;
    // All "time" measured in frames.
    int time_left = 0;
    int inv_time_left = 0;
    int speed_time_left = 0;
    int jump_time_left = 0;
    int fly_time_left = 0;

    int keys = 0;
    int stars = 0;
    int ammo = 0;
    int bombs = 0;
    int score = 0;

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

    Result m_result = Result::PLAYING;
    bool m_paused = false;
    std::string m_reason;

    int m_frame_fading_box = 16;
    std::string m_message_text;
    int m_message_opacity = 0;

    int m_stars_goal = 0;

    // TODO: The object system and PMScript have not been ported yet.
};
