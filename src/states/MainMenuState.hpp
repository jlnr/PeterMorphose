#pragma once

#include "State.hpp"
#include <Gosu/Gosu.hpp>
#include <vector>

/// A port of the original State_MainMenu: play a level, read the manual, show credits, or quit.
/// We don't have options in this version and we try not to need them either.
class MainMenuState : public State
{
public:
    MainMenuState();

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    const Gosu::Image m_title_image;
    const std::vector<Gosu::Image> m_buttons;
    int m_selected_index = 0;
};
