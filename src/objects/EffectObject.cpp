#include "objects/EffectObject.hpp"
#include <Gosu/Gosu.hpp>
#include "Map.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/String.hpp"
#include "states/GameState.hpp"
#include <algorithm>
#include <string>

static Gosu::Color alpha(int a)
{
    return Gosu::Color::WHITE.with_alpha(std::clamp(a, 0, 255));
}

EffectObject::EffectObject(GameState& game, std::string extra_data, PMID pmid, //
                           int x, int y, int vx, int vy)
    : GameObject(game, std::move(extra_data), pmid, x, y, vx, vy)
{
}

void EffectObject::update()
{
    switch (pmid) {
    case ID_FX_SMOKE:
    case ID_FX_FLAME:
        x += vx;
        y += vy;
        m_phase += 1;
        if (m_phase > 7) {
            kill();
        }
        break;

    case ID_FX_SPARK:
        x += vx;
        y += vy;
        if (game.frame % 3 == 0) {
            m_phase += 1;
        }
        if (m_phase > 5) {
            kill();
        }
        break;

    case ID_FX_BUBBLE:
        x += vx;
        y = game.map.lava_pos - 12;
        if (game.frame % 2 == 0) {
            m_phase += 1;
        }
        if (m_phase > 7) {
            kill();
        }
        break;

    case ID_FX_BLOCKER_PARTS:
        x += vx;
        y += vy;
        vy += 1;
        m_phase += 15;
        if (m_phase == 255) {
            kill();
        }
        break;

    case ID_FX_WATER:
        x += vx;
        vy += 1;
        y += vy;
        m_phase += 25;
        if (m_phase == 250) {
            kill();
        }
        break;

    case ID_FX_BREAK:
    case ID_FX_BREAK_2:
        m_phase += 15;
        if (m_phase == 255) {
            int even_odd = (y / TILE_SIZE % 2 + x / TILE_SIZE) % 2;
            game.map[x / TILE_SIZE, y / TILE_SIZE] = even_odd == 0 ? TILE_HOLE : TILE_HOLE_2;
            game.cast_objects(ID_FX_BREAKING_PARTS, 20, 0, 5, 2,
                              Rect(x / TILE_SIZE * TILE_SIZE, y / TILE_SIZE * TILE_SIZE, 24, 24));
            game.emit_sound(y, "Break");
            kill();
        }
        break;

    case ID_FX_FIRE:
        m_phase += 15;
        if (m_phase == 255) {
            game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_BIG_BLOCKER_BROKEN;
            game.explosion(x + 12, y + 12, 30, true);
            kill();
        }
        break;

    case ID_FX_BREAKING_PARTS:
    case ID_FX_TEXT:
    case ID_FX_RICOCHET:
    case ID_FX_LINE:
    case ID_FX_BLOOD:
    case ID_FX_FLYING_CHAIN:
    case ID_FX_FLYING_BLOB:
        x += vx;
        y += vy;
        m_phase += 15;
        if (m_phase == 255) {
            kill();
        }
        break;

    case ID_FX_SLOW_TEXT:
        x += vx;
        y += vy;
        m_phase += 5;
        if (m_phase == 255) {
            kill();
        }
        break;

    case ID_FX_FLYING_HOSTAGE:
        x += vx;
        y += vy;
        if (y < game.view_pos - WINDOW_HEIGHT) {
            kill();
        }
        break;

    case ID_FX_WATER_BUBBLE:
        y -= 1;
        if (rand(4) == 0) {
            x += 1 - rand(3);
        }
        if (!in_water()) {
            kill();
        }
        break;

    case ID_FX_SPARKLE:
        m_phase += 25;
        if (m_phase == 250) {
            kill();
        }
        break;
    }
}

void EffectObject::draw()
{
    const double dy = y - game.view_pos;
    switch (pmid) {
    case ID_FX_SMOKE:
        effect_image(std::max(0, m_phase - 1))
            .draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(128), Gosu::BM_ADD);
        break;
    case ID_FX_FLAME:
        effect_image(std::max(7, m_phase + 6))
            .draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(160), Gosu::BM_ADD);
        break;
    case ID_FX_SPARK:
        effect_image(std::max(14, m_phase + 13))
            .draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(128), Gosu::BM_ADD);
        break;
    case ID_FX_BUBBLE:
        effect_image(std::max(21, m_phase + 20))
            .draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(192), Gosu::BM_ADD);
        break;
    case ID_FX_RICOCHET:
        effect_image(19 + (extra_data.empty() ? 0 : string_to_int(extra_data)))
            .draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(255 - m_phase * 3));
        break;
    case ID_FX_LINE:
        effect_image(28).draw(
            x, dy - 11, Z_EFFECTS,
            extra_data.empty() ? 0.0 : string_to_int(extra_data) / effect_image(28).width(), 1,
            alpha(255 - m_phase), Gosu::BM_ADD);
        break;
    case ID_FX_BLOCKER_PARTS:
        effect_image(29).draw_rot(x, dy, Z_EFFECTS, x * 10, 0.5, 0.5, //
                                  1, 1, alpha(255 - m_phase), Gosu::BM_ADD);
        break;
    case ID_FX_BREAK:
        // Unlike DelphiX, Gosu does not have BM_SUBTRACT...but regular blending should be fine.
        effect_image(30).draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(m_phase));
        break;
    case ID_FX_BREAK_2:
        effect_image(31).draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(m_phase));
        break;
    case ID_FX_BREAKING_PARTS:
        effect_image(32).draw_rot(x, dy, Z_EFFECTS, x * 10, 0.5, 0.5, 1, 1, alpha(255 - m_phase));
        break;
    case ID_FX_BLOOD:
        effect_image(33).draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(250 - m_phase));
        break;
    case ID_FX_FIRE:
        effect_image(34).draw(x, dy, Z_EFFECTS, 1, 1, alpha(m_phase));
        break;
    case ID_FX_FLYING_HOSTAGE:
        effect_image(35).draw(x - 11, dy - 11, Z_EFFECTS);
        break;
    case ID_FX_FLYING_CHAIN:
        effect_image(36).draw_rot(x, dy, Z_EFFECTS, x * 10 % 360, 0.5, 0.5, 1, 1,
                                  alpha(255 - m_phase));
        break;
    case ID_FX_FLYING_BLOB:
        effect_image(37).draw_rot(x, dy, Z_EFFECTS, x * 10, 0.5, 0.5, 1, 1, alpha(255 - m_phase));
        break;
    case ID_FX_WATER_BUBBLE:
        effect_image(46).draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(100 + rand(29)));
        break;
    case ID_FX_WATER:
        effect_image(47).draw_rot(x, dy, Z_EFFECTS, x * 10, 0.5, 0.5, 1, 1, alpha(255 - m_phase));
        break;
    case ID_FX_SPARKLE:
        effect_image(48).draw(x - 11, dy - 11, Z_EFFECTS, 1, 1, alpha(255 - m_phase), Gosu::BM_ADD);
        break;
    case ID_FX_TEXT:
    case ID_FX_SLOW_TEXT:
        // Keep the centered text on screen.
        int half_width = bmp_text_width(extra_data) / 2;
        int max_x = TILES_X * TILE_SIZE - half_width;
        draw_bmp_text(extra_data, std::clamp(x, half_width, max_x), dy - 7,
                      std::clamp(255 - m_phase, 0, 255), Gosu::AL_CENTER);
        break;
    }
}
