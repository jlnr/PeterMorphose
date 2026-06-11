#include "InputAction.hpp"
#include <algorithm>
#include <map>

static const std::map<InputAction, std::vector<Gosu::Button>> CONTROLS = {
    { InputAction::MenuPrev, { Gosu::KB_UP, Gosu::GP_UP, Gosu::KB_LEFT, Gosu::GP_LEFT } },
    { InputAction::MenuNext, { Gosu::KB_DOWN, Gosu::GP_DOWN, Gosu::KB_RIGHT, Gosu::GP_RIGHT } },
    { InputAction::MenuConfirm,
      { Gosu::KB_ENTER, Gosu::KB_RETURN, Gosu::KB_SPACE, Gosu::GP_BUTTON_0 } },
    { InputAction::MenuCancel, { Gosu::KB_ESCAPE, Gosu::GP_BUTTON_2 } },
    { InputAction::Up, { Gosu::KB_UP, Gosu::GP_UP } },
    { InputAction::Down, { Gosu::KB_DOWN, Gosu::GP_DOWN } },
    { InputAction::Left, { Gosu::KB_LEFT, Gosu::GP_LEFT } },
    { InputAction::Right, { Gosu::KB_RIGHT, Gosu::GP_RIGHT } },
    { InputAction::Jump, { Gosu::KB_UP, Gosu::GP_BUTTON_0 } },
    { InputAction::Action, { Gosu::KB_SPACE, Gosu::GP_BUTTON_1 } },
    { InputAction::Use, { Gosu::KB_DOWN, Gosu::GP_DOWN } },
};

bool is_mapped_to(InputAction action, Gosu::Button id)
{
    auto it = CONTROLS.find(action);
    if (it == CONTROLS.end()) {
        return false;
    }
    return std::ranges::contains(it->second, id);
}

bool is_down(InputAction action)
{
    auto it = CONTROLS.find(action);
    if (it == CONTROLS.end()) {
        return false;
    }
    return std::ranges::any_of(it->second, &Gosu::Input::down);
}
