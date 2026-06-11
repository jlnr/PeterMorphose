#pragma once

#include <Gosu/Gosu.hpp>

enum class InputAction
{
    MenuPrev,
    MenuNext,
    MenuConfirm,
    MenuCancel,
    Up,
    Down,
    Left,
    Right,
    Jump,
    Action,
    Use
};

bool is_mapped_to(InputAction action, Gosu::Button id);
bool is_down(InputAction action);
