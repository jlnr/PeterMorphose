#include "MainMenuState.hpp"
#include "Constants.hpp"
#include "CreditsState.hpp"
#include "LevelSelectionState.hpp"
#include "ReadMeState.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"
#include <memory>

MainMenuState::MainMenuState()
    : m_title_image("assets/TitleDark.png"),
      m_buttons(Gosu::load_tiles("assets/Buttons.png", 400, 64, Gosu::IF_RETRO))
{
}

void MainMenuState::update()
{
    play_song("menu");
}

void MainMenuState::draw()
{
    m_title_image.draw(0, 0);

    m_buttons[m_selected_index == 0 ? 1 : 0].draw(120, 80, Z_UI); // Spielen
    m_buttons[m_selected_index == 1 ? 3 : 2].draw(120, 150, Z_UI); // Anleitung
    m_buttons[m_selected_index == 2 ? 7 : 6].draw(120, 220, Z_UI); // Mitwirkende
    m_buttons[m_selected_index == 3 ? 9 : 8].draw(120, 290, Z_UI); // Beenden

    draw_bmp_text("Wähle mit den Pfeiltasten aus, was du tun willst und drücke Enter.",
                  WINDOW_WIDTH / 2, 435, 255, Gosu::AL_CENTER);
}

void MainMenuState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuPrev, id) && m_selected_index > 0) {
        m_selected_index--;
    }
    if (is_mapped_to(InputAction::MenuNext, id) && m_selected_index < 4) {
        m_selected_index++;
    }
    if (is_mapped_to(InputAction::MenuConfirm, id)) {
        play_sound("Woosh");
        switch (m_selected_index) {
        case 0:
            push_state(std::make_unique<LevelSelectionState>());
            break;
        case 1:
            push_state(std::make_unique<ReadMeState>());
            break;
        case 2:
            push_state(std::make_unique<CreditsState>());
            break;
        case 3:
            pop_state(); // emptying the state stack quits the game
            break;
        }
    }
    if (is_mapped_to(InputAction::MenuCancel, id)) {
        play_sound("WooshBack");
        pop_state(); // quit
    }
}
