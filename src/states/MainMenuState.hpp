#pragma once

#include <Gosu/Gosu.hpp>
#include "State.hpp"
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
    enum Item : int;

    const Gosu::Image m_title_image;
    const std::vector<Gosu::Image> m_buttons_de;
    const std::vector<Gosu::Image> m_buttons_en;
    int m_selected_item = 0;
};
