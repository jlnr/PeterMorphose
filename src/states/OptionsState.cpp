#include "OptionsState.hpp"
#include "Constants.hpp"
#include "Options.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"
#include <algorithm>
#include <string>

enum OptionsState::Item : int
{
    MUSIC,
    SOUND,
    MINIMAP,
    ITEM_COUNT
};

static constexpr int VOLUME_STEP = 5;

static void draw_slider(int y, int volume)
{
    constexpr int track_x = 360, track_w = 170, track_h = 16;
    Gosu::draw_rect(track_x, y, track_w, track_h, Gosu::Color(0xff202020), Z_UI);
    Gosu::draw_rect(track_x, y, track_w * volume / 100.0, track_h, Gosu::Color::WHITE, Z_UI);
    draw_bmp_text(std::to_string(volume) + "%", WINDOW_WIDTH - 20, y, 255, Gosu::AL_RIGHT);
}

OptionsState::OptionsState()
    : m_background("assets/TitleDark.png")
{
}

void OptionsState::update()
{
    play_song("Menu");
}

void OptionsState::draw()
{
    m_background.draw(0, 0);

    draw_bmp_text("Optionsmenü", 20, 20);

    Gosu::draw_rect(0, (m_selected_item + 1) * 70 - 1, WINDOW_WIDTH, 18, //
                    Gosu::Color(0xff964800), Z_LAVA, Gosu::BM_ADD);

    draw_bmp_text("Musik", 20, 70);
    draw_slider(70, music_volume());
    draw_bmp_text("Lautstärke der Hintergrundmusik.", 20, 70 + 20, 180);

    draw_bmp_text("Andere Geräusche", 20, 140);
    draw_slider(140, sound_volume());
    draw_bmp_text("Lautstärke aller übrigen Geräusche.", 20, 140 + 20, 180);

    draw_bmp_text("Positionsanzeige im Spiel", 20, 210);
    draw_bmp_text(minimap_enabled() ? "<ein>" : "<aus>", //
                  WINDOW_WIDTH - 20, 210, 255, Gosu::AL_RIGHT);
    draw_bmp_text("Blendet im Spiel links eine Leiste zur besseren Orientierung ein.", //
                  20, 210 + 20, 180);

    draw_bmp_text("Pfeiltasten wählen aus und ändern. Escape kehrt zum Hauptmenü zurück.",
                  WINDOW_WIDTH / 2, 440, 180, Gosu::AL_CENTER);
}

void OptionsState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::Up, id)) {
        m_selected_item = std::max(0, m_selected_item - 1);
    }
    if (is_mapped_to(InputAction::Down, id)) {
        m_selected_item = std::min(ITEM_COUNT - 1, m_selected_item + 1);
    }
    if (is_mapped_to(InputAction::Left, id) || is_mapped_to(InputAction::Right, id)) {
        const bool right = is_mapped_to(InputAction::Right, id);
        const int delta = right ? +VOLUME_STEP : -VOLUME_STEP;
        switch (m_selected_item) {
        case MUSIC:
            set_music_volume(std::clamp(music_volume() + delta, 0, 100));
            break;
        case SOUND:
            set_sound_volume(std::clamp(sound_volume() + delta, 0, 100));
            play_sound("StarCollect"); // let the player hear the new sound volume
            break;
        case MINIMAP:
            set_minimap_enabled(right); // left = off, right = on, like in Delphi
            break;
        }
    }
    if (is_mapped_to(InputAction::MenuCancel, id) || is_mapped_to(InputAction::MenuConfirm, id)) {
        play_sound("WooshBack");
        pop_state();
    }
}
