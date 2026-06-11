#pragma once

#include <Gosu/Gosu.hpp>
#include "State.hpp"

class TitleState : public State
{
public:
    TitleState();
    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    Gosu::Image m_title_image;
};
