#pragma once

#include "State.hpp"
#include <Gosu/Gosu.hpp>

/// The options screen, like State_Options in the Delphi original, but now only for volume settings.
class OptionsState : public State
{
public:
    OptionsState();

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    const Gosu::Image m_background;
    int m_selected = 0;
};
