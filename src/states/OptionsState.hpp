#pragma once

#include "State.hpp"
#include <Gosu/Gosu.hpp>

/// The options screen, like State_Options in the Delphi original, but much more minimal.
class OptionsState : public State
{
public:
    OptionsState();

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    /// The settings shown, in their on-screen order. Defined at the top of OptionsState.cpp.
    enum Item : int;

    const Gosu::Image m_background;
    int m_selected_item = 0;
};
