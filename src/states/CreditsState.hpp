#pragma once

#include "State.hpp"
#include <Gosu/Gosu.hpp>

/// The credits screen, like State_Credits in the Delphi original.
class CreditsState : public State
{
public:
    CreditsState();

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    const Gosu::Image m_background;
};
