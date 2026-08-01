#include "WonInfoState.hpp"
#include "Constants.hpp"
#include "Map.hpp"
#include "Options.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/I18n.hpp"
#include "helpers/InputAction.hpp"
#include "objects/LivingObject.hpp"
#include "states/GameState.hpp"
#include <string>

WonInfoState::WonInfoState(const std::string& level_filename, GameState& game)
    : m_background("assets/Won.png")
{
    // Award the end-of-level bonuses, like in the the original TFormPeterM/State_WonInfo screen.
    int total = game.score;

    m_score_lines.push_back(t("Übrige Lebensenergie (je Punkt 5 Punkte)") + ": "
                            + std::to_string(game.player().life));
    total += game.player().life * 5;

    m_score_lines.push_back(t("Übrige Schlüssel (je Schlüssel 25 Punkte)") + ": "
                            + std::to_string(game.keys));
    total += game.keys * 3;

    m_score_lines.push_back(t("Übrige Sterne (je Stern 3 Punkte)") + ": "
                            + std::to_string(game.stars - game.stars_goal));
    total += (game.stars - game.stars_goal) * 3;

    m_score_lines.push_back(t("Übrige Munition (je Schuss 2 Punkte)") + ": "
                            + std::to_string(game.ammo));
    total += game.ammo * 2;

    m_score_lines.push_back(t("Übrige Bomben (je Bombe 5 Punkte)") + ": "
                            + std::to_string(game.bombs));
    total += game.bombs * 5;

    // Some levels also reward distance to the lava.
    if (game.map.lava_score == 1) {
        int distance = game.map.lava_pos - game.map.level_top();
        total += game.map.lava_time_left + distance / 10;
        m_score_lines.push_back(t("Übrige Lava-Einfrierzeit (pro Bild 1 Punkt)") + ": "
                                + std::to_string(game.map.lava_time_left) + " " + t("Bilder"));
        m_score_lines.push_back(t("Abstand zur Lava bei Spielende (pro Pixel 0.1 Punkte)") + ": "
                                + std::to_string(distance) + " " + t("Pixel"));
    }

    m_score_lines.push_back(t("Gesamtpunktestand") + ": " + std::to_string(total) + " "
                            + t("Punkte") + "!");

    // Persist the score as the level's new highscore if it is a new record.
    save_hiscore(level_filename, total);
}

void WonInfoState::update()
{
    play_song("Menu");
}

void WonInfoState::draw()
{
    m_background.draw(0, 0);
    for (int i = 0; i < m_score_lines.size(); ++i) {
        draw_bmp_text(m_score_lines[i], 40, 150 + i * 30);
    }
    draw_bmp_text("(Taste drücken)", WINDOW_WIDTH / 2, 440, 128, Gosu::AL_CENTER);
}

void WonInfoState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuConfirm, id) || is_mapped_to(InputAction::MenuCancel, id)) {
        play_sound("Woosh");
        pop_state(); // back to level selection
    }
}
