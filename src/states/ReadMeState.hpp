#pragma once

#include "State.hpp"
#include <Gosu/Gosu.hpp>

/// The in-game manual, ported from the original State_ReadMe1...8.
/// Left/right arrows turn the page, Escape returns to the main menu.
class ReadMeState : public State
{
public:
    ReadMeState();

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    const Gosu::Image m_title_image;
    int m_page = 0;
};
