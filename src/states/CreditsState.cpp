#include "CreditsState.hpp"
#include "Constants.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"

CreditsState::CreditsState()
    : m_background("assets/TitleDark.png")
{
}

void CreditsState::update()
{
    play_song("menu");
}

void CreditsState::draw()
{
    m_background.draw(0, 0);

    draw_bmp_text("Spielidee, Programmierung, Grafiken, Sounds", 100, 40, 200);
    draw_bmp_text("Julian Raschke", 200, 80);
    draw_bmp_text("http://www.petermorphose.de/", 200, 100);

    draw_bmp_text("Zusätzliche Sounds und Himmel", 100, 140, 200);
    draw_bmp_text("Sandro Mascia", 200, 160);
    draw_bmp_text("Sebastian Ludwig", 200, 180);
    draw_bmp_text("Sören Bevier", 200, 200);
    draw_bmp_text("Sebastian Burkhart", 200, 220);
    draw_bmp_text("Florian Groß", 200, 240);
    draw_bmp_text("Holger Biermann", 200, 260);

    draw_bmp_text("Musik", 100, 300, 200);
    draw_bmp_text("Steffen Wenz", 200, 340);

    draw_bmp_text("Drücke Escape, um zum Hauptmenü zurückzukehren.", WINDOW_WIDTH / 2, 435, //
                  128, Gosu::AL_CENTER);
}

void CreditsState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuConfirm, id) || is_mapped_to(InputAction::MenuCancel, id)) {
        play_sound("WooshBack");
        pop_state(); // back to main menu
    }
}
