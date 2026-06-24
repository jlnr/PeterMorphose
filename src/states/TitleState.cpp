#include "TitleState.hpp"
#include "LevelSelectionState.hpp"
#include "helpers/Audio.hpp"
#include "helpers/InputAction.hpp"

TitleState::TitleState()
    : m_title_image("media/title.png")
{
}

void TitleState::update()
{
    play_song("menu");
}

void TitleState::draw()
{
    m_title_image.draw(0, 0);
}

void TitleState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuConfirm, id) || is_mapped_to(InputAction::MenuCancel, id)) {
        play_sound("whoosh");
        pop_state();
        push_state(std::make_unique<LevelSelectionState>());
    }
}
