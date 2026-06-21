#include "GameState.hpp"
#include "helpers/Audio.hpp"
#include "helpers/String.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"
#include <algorithm>
#include <cmath>

GameState::GameState(const IniFile& ini_file)
    : m_map(ini_file),
      m_view_pos(TILES_Y * TILE_SIZE - WINDOW_HEIGHT)
{
    song("game").play(true);

    m_stars_goal = string_to_int(ini_file["Map", "StarsGoal"].value_or("100"));

    // TODO: Create the player and everything else from [Objects].
}

void GameState::lose(const std::string& reason)
{
    m_result = Result::LOST;
    m_reason = reason;
}

void GameState::update()
{
    // TODO: Detect win/loss once the player object exists (death, reaching the top, hostages, ...).

    if (m_result != Result::PLAYING || m_paused) {
        return;
    }

    m_frame = (m_frame + 1) % 2400;
    if (m_message_opacity > 0) {
        m_message_opacity -= 3;
    }

    // TODO: Run the per-tile and timer scripts (execute_script) once we have PMScript.

    // Rising lava.
    if (m_map.lava_time_left() == 0) {
        if (m_map.lava_speed() != 0) {
            if (m_map.lava_mode() == 0 && m_frame % m_map.lava_speed() == 0) {
                m_map.set_lava_pos(m_map.lava_pos() - 1);
            }
            if (m_map.lava_mode() == 1) {
                m_map.set_lava_pos(m_map.lava_pos() - m_map.lava_speed());
            }
            m_map.set_lava_frame((m_map.lava_frame() + 1) % 120);
            // TODO: Emit the positional lava sound.
        }
    }
    else {
        m_map.set_lava_time_left(m_map.lava_time_left() - 1);
    }

    // The view follows the lava (TODO: and the player).
    m_view_pos = std::max(std::min(m_map.lava_pos() - 432, 24096.0), m_map.level_top());

    // TODO: Player movement/input handling.

    // TODO: Update objects, remove dead ones, create bubbles/flames...
}

void GameState::draw()
{
    m_map.draw(m_view_pos);

    // TODO: Draw objects.

    enum LavaTile
    {
        ACTIVE_SURFACE,
        FROZEN_SURFACE,
        ACTIVE_FILL,
        FROZEN_FILL
    };
    static const std::vector<Gosu::Image> lava_tiles = Gosu::load_tiles("media/danger.png", -2, -2);
    const bool lava_active = m_map.lava_time_left() == 0;
    const int scroll = m_map.lava_frame() + (lava_active ? m_frame / 2 % 2 : 0);
    for (int x = -1; x <= 4; ++x) {
        lava_tiles[lava_active ? ACTIVE_SURFACE : FROZEN_SURFACE].draw(
            x * 120 + scroll, m_map.lava_pos() - m_view_pos, Z_LAVA);
    }
    if (m_map.lava_pos() < m_map.level_top() + 432) {
        for (int x = -1; x <= 4; ++x) {
            for (int y = 0; y <= (m_map.level_top() + 432 - m_map.lava_pos()) / 48 + 1; ++y) {
                lava_tiles[lava_active ? ACTIVE_FILL : FROZEN_FILL].draw(
                    x * 120 + scroll, m_map.lava_pos() - m_view_pos + 48 + y * 48, Z_LAVA);
            }
        }
    }

    draw_status_bar();

    if (m_result == Result::PLAYING && m_message_opacity > 0) {
        draw_centered_string(m_message_text, WINDOW_WIDTH / 2, 230, m_message_opacity);
    }

    static const std::vector<Gosu::Image> dialogs = Gosu::load_tiles("media/dialogs.bmp", -1, -3);
    if (m_result != Result::PLAYING) {
        m_frame_fading_box++;
        if (m_frame_fading_box == 33) {
            m_frame_fading_box = 1;
        }

        if (m_result == Result::LOST) {
            draw_centered_string(m_reason, WINDOW_WIDTH / 2, 220,
                                 std::abs(16 - m_frame_fading_box) * 15);
        }
        else {
            dialogs[1].draw(200, 160, Z_UI, 1, 1,
                            Gosu::Color::WHITE.with_alpha(std::abs(16 - m_frame_fading_box) * 15),
                            Gosu::BM_ADD);
        }
    }
    else if (m_paused) {
        dialogs[2].draw(200, 120, Z_UI, 1, 1, Gosu::Color::WHITE, Gosu::BM_ADD);
    }

    draw_centered_string("Punkte: " + std::to_string(m_score), WINDOW_WIDTH / 2, 5);
}

void GameState::draw_status_bar()
{
    static const std::vector<Gosu::Image> gui = Gosu::load_tiles("media/gui.bmp", -4, -11);
    const double tile_w = gui.front().width();
    const double tile_h = gui.front().height();

    Gosu::transform(Gosu::Transform::translate(576, 0), [&] {
        const auto blank_line = [&](int row) {
            for (int x = 0; x <= 3; ++x) {
                gui[x + 4].draw(tile_w * x, tile_h * row, Z_UI);
            }
        };
        const auto draw_digits = [&](int num, int row) {
            const int left_digit = std::min(num, 99) / 10 * 2 + 20;
            const int right_digit = std::min(num, 99) % 10 * 2 + 21;
            gui[left_digit].draw(tile_w * 2, tile_h * row, Z_UI);
            gui[right_digit].draw(tile_w * 3, tile_h * row, Z_UI);
        };

        // Game logo and spacing
        for (int x = 0; x <= 3; ++x) {
            gui[x + 0].draw(tile_w * x, tile_h * 0, Z_UI);
            gui[x + 4].draw(tile_w * x, tile_h * 1, Z_UI);
        }
        // Health.
        // TODO: Draw player.life or blank_line when the player is dead.
        gui[8].draw(tile_w * 0, tile_h * 2, Z_UI);
        gui[9].draw(tile_w * 1, tile_h * 2, Z_UI);
        draw_digits(0, 2);
        // Keys
        gui[10].draw(tile_w * 0, tile_h * 3, Z_UI);
        gui[11].draw(tile_w * 1, tile_h * 3, Z_UI);
        draw_digits(m_keys, 3);
        // Stars
        gui[12].draw(tile_w * 0, tile_h * 4, Z_UI);
        gui[13].draw(tile_w * 1, tile_h * 4, Z_UI);
        draw_digits(m_stars, 4);
        if (m_stars > m_stars_goal) {
            // Enough stars - draw checkmark
            gui[42].draw(tile_w * 2, tile_h * 4, Z_UI);
            gui[43].draw(tile_w * 3, tile_h * 4, Z_UI);
        }
        if (m_stars_goal == 0) {
            // Or blank the line out if no stars are needed
            blank_line(4);
        }
        // TODO: Remaining special Peter morph time.
        blank_line(5);
        // Ammo
        gui[16].draw(tile_w * 0, tile_h * 6, Z_UI);
        gui[17].draw(tile_w * 1, tile_h * 6, Z_UI);
        draw_digits(m_ammo, 6);
        // Bombs
        gui[18].draw(tile_w * 0, tile_h * 7, Z_UI);
        gui[19].draw(tile_w * 1, tile_h * 7, Z_UI);
        draw_digits(m_bombs, 7);
        // Remaining time for frozen lava.
        if (m_map.lava_time_left() == 0) {
            blank_line(8);
        }
        else {
            gui[40].draw(tile_w * 0, tile_h * 8, Z_UI);
            gui[41].draw(+tile_w * 1, tile_h * 8, Z_UI);
            draw_digits(m_map.lava_time_left() / TARGET_FPS, 8);
        }
        // Spacing
        blank_line(9);
    });
}

void GameState::button_down(Gosu::Button id)
{
    switch (m_result) {
    case Result::PLAYING:
        if (is_mapped_to(InputAction::MenuCancel, id)) {
            sound("whoosh").play();
            pop_state(); // back to level selection
        }
        else if (m_paused) {
            if (id == Gosu::KB_P) {
                m_paused = false;
            }
        }
        else {
            if (id == Gosu::KB_P) {
                m_paused = true;
            }
            // TODO: player.jump / use_everything / act on the Jump/Use/Action buttons...
        }
        break;
    case Result::LOST:
        if (is_mapped_to(InputAction::MenuCancel, id)) {
            sound("whoosh").play();
            pop_state();
        }
        break;
    case Result::WON:
        if (is_mapped_to(InputAction::MenuConfirm, id)
            || is_mapped_to(InputAction::MenuCancel, id)) {
            sound("whoosh").play();
            pop_state();
        }
        break;
    }
}
