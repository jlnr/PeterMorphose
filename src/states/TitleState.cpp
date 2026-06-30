#include "TitleState.hpp"
#include "Constants.hpp"
#include "MainMenuState.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"

TitleState::TitleState()
    : m_title_image("assets/Title.png")
{
}

void TitleState::update()
{
    play_song("Menu");
}

void TitleState::draw()
{
    m_title_image.draw(0, 0);
    draw_bmp_text("Version: 2026.06.     https://www.petermorphose.de/", //
                  WINDOW_WIDTH / 2, 440, 255, Gosu::AL_CENTER);
}

void TitleState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuConfirm, id) || is_mapped_to(InputAction::MenuCancel, id)) {
        play_sound("Woosh");
        pop_state();
        push_state(std::make_unique<MainMenuState>());
    }
}
