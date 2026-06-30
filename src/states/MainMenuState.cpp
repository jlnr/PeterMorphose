#include "MainMenuState.hpp"
#include "Constants.hpp"
#include "CreditsState.hpp"
#include "LevelSelectionState.hpp"
#include "OptionsState.hpp"
#include "ReadMeState.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"
#include <memory>

enum MainMenuState::Item : int
{
    PLAY,
    MANUAL,
    OPTIONS,
    CREDITS,
    QUIT,
    ITEM_COUNT
};

MainMenuState::MainMenuState()
    : m_title_image("assets/TitleDark.png"),
      m_buttons(Gosu::load_tiles("assets/Buttons.png", 400, 64, Gosu::IF_RETRO))
{
}

void MainMenuState::update()
{
    play_song("Menu");
}

void MainMenuState::draw()
{
    m_title_image.draw(0, 0);

    for (int i = 0; i < ITEM_COUNT; ++i) {
        m_buttons[i * 2 + (m_selected_item == i)].draw(120, 20 + i * 70, Z_UI); // Spielen
    }

    draw_bmp_text("Wähle mit den Pfeiltasten aus, was du tun willst und drücke Enter.",
                  WINDOW_WIDTH / 2, 435, 255, Gosu::AL_CENTER);
}

void MainMenuState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuPrev, id) && m_selected_item > PLAY) {
        m_selected_item--;
    }
    if (is_mapped_to(InputAction::MenuNext, id) && m_selected_item < QUIT) {
        m_selected_item++;
    }
    if (is_mapped_to(InputAction::MenuConfirm, id)) {
        play_sound("Woosh");
        switch (m_selected_item) {
        case PLAY:
            push_state(std::make_unique<LevelSelectionState>());
            break;
        case MANUAL:
            push_state(std::make_unique<ReadMeState>());
            break;
        case OPTIONS:
            push_state(std::make_unique<OptionsState>());
            break;
        case CREDITS:
            push_state(std::make_unique<CreditsState>());
            break;
        case QUIT:
            pop_state(); // emptying the state stack quits the game
            break;
        }
    }
    if (is_mapped_to(InputAction::MenuCancel, id)) {
        play_sound("WooshBack");
        pop_state(); // quit
    }
}
