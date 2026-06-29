#include "LevelSelectionState.hpp"
#include "GameState.hpp"
#include "Hiscore.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"

static constexpr int LEVELS_ON_SCREEN = 4;

LevelSelectionState::LevelSelectionState()
    : m_title_image("media/TitleDark.png"),
      m_levels(LevelInfo::list_levels())
{
}

void LevelSelectionState::update()
{
    play_song("menu");

    // We just returned from playing a level: re-read its highscore so a new record shows at once.
    if (m_reload_hiscore) {
        m_levels[m_selected_index].hiscore = load_hiscore(m_levels[m_selected_index].filename);
        m_reload_hiscore = false;
    }
}

void LevelSelectionState::draw_level_info(const LevelInfo& info, int y, bool active)
{
    if (active) {
        Gosu::draw_rect(0, y + 1, 631, 98, Gosu::Color(0xff603000), Z_UI);
    }

    Gosu::draw_rect(0, y, 631, 1, Gosu::Color(0xff003000), Z_UI);
    const std::string title = info.hiscore.has_value()
        ? info.title + " (" + std::to_string(*info.hiscore) + " Punkte)"
        : info.title + " (noch nicht geschafft)";
    draw_string(title, 5, y + 7, 255);
    draw_right_aligned_string(info.difficulty, 626, y + 7, 255);
    draw_string(info.description, 5, y + 30, 192);
    draw_string(info.goal, 5, y + 53, 128);
    draw_string(info.author, 5, y + 76, 80);
    Gosu::draw_rect(0, y + 99, 631, 1, Gosu::Color(0xff006000), Z_UI);
}

void LevelSelectionState::draw()
{
    m_title_image.draw(0, 0);
    draw_rect(631, 0, 1, 400, Gosu::Color(0xff003010), Z_UI);
    draw_rect(632, 0, 16, 400, Gosu::Color(0xff004020), Z_UI);

    for (int y = 0; y < LEVELS_ON_SCREEN; ++y) {
        if (m_top_index + y >= m_levels.size()) {
            break;
        }
        draw_level_info(m_levels[m_top_index + y], y * 100, (m_top_index + y) == m_selected_index);
    }

    if (m_levels.size() > LEVELS_ON_SCREEN) {
        draw_string("|", 632, 384.0 * m_top_index / (m_levels.size() - LEVELS_ON_SCREEN));
    }

    draw_centered_string("Wähle mit den Pfeiltasten ein Level aus und starte es mit Enter.",
                         640 / 2, 434);
}

void LevelSelectionState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuCancel, id)) {
        pop_state(); // back to menu
    }
    else if (is_mapped_to(InputAction::MenuPrev, id)) {
        if (m_selected_index > 0) {
            m_selected_index--;
            if (m_selected_index < m_top_index) {
                m_top_index--;
            }
        }
    }
    else if (is_mapped_to(InputAction::MenuNext, id)) {
        if (m_selected_index < (int)m_levels.size() - 1) {
            m_selected_index++;
            if (m_selected_index >= m_top_index + LEVELS_ON_SCREEN) {
                m_top_index++;
            }
        }
    }
    else if (is_mapped_to(InputAction::MenuConfirm, id)) {
        m_reload_hiscore = true;
        push_state(std::make_unique<GameState>(m_levels[m_selected_index].ini_file,
                                               m_levels[m_selected_index].filename));
    }
}
