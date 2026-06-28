#pragma once

#include "State.hpp"
#include <Gosu/Gosu.hpp>
#include <string>
#include <vector>

class GameState;

/// The score with explanations after finishing a level. Like State_WonInfo in the Delphi original..
/// Any key returns to the level selection.
class WonInfoState : public State
{
public:
    WonInfoState(const std::string& level_filename, GameState& game);

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    Gosu::Image m_background;
    std::vector<std::string> m_score_lines;
};
