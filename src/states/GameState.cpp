#include "GameState.hpp"
#include "Constants.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/IniFile.hpp"
#include "helpers/InputAction.hpp"
#include "helpers/String.hpp"
#include "objects/CollectibleObject.hpp"
#include "objects/EffectObject.hpp"
#include "objects/GameObject.hpp"
#include "objects/LivingObject.hpp"
#include "objects/ObjectDef.hpp"
#include <algorithm>
#include <cmath>
#include <memory>
#include <optional>

GameState::GameState(const IniFile& ini)
    : map(ini)
{
    view_pos = TILES_Y * TILE_SIZE - WINDOW_HEIGHT;

    stars_goal = ini.integer("Map", "StarsGoal").value_or(100);

    PMID player_id = PMID(ini.integer("Objects", "PlayerID").value_or(0));
    int player_x = ini.integer("Objects", "PlayerX").value_or(288);
    int player_y = ini.integer("Objects", "PlayerY").value_or(24515);
    int player_vx = ini.integer("Objects", "PlayerVX").value_or(0);
    int player_vy = ini.integer("Objects", "PlayerVY").value_or(0);
    int player_life = ini.integer("Objects", "PlayerLife").value_or(ObjectDef::get(ID_PLAYER).life);
    Direction player_direction
        = Direction(ini.integer("Objects", "PlayerDirection").value_or(rand(2)));
    Action player_action = ACT_STAND;
    m_player = std::make_shared<LivingObject>(*this, "", player_id, //
                                              player_x, player_y, player_vx, player_vy, //
                                              player_life, player_action, player_direction);

    // If the player starts as a Special Peter, give him some morph time.
    time_left = (m_player->pmid == ID_PLAYER ? 0 : ObjectDef::get(m_player->pmid).life);

    m_objects.push_back(m_player);

    // Load and create all other objects. Each [Objects] line is "pmid|x|y" (all hex), with the
    // optional extra data in a second INI entry.
    for (int i = 0;; ++i) {
        const std::optional<std::string> line = ini.string("Objects", std::to_string(i));
        if (!line) {
            // IF there is no key for the given object, it marks the end of the object list.
            break;
        }
        std::string extraData = ini.string("Objects", std::to_string(i) + "Y").value_or("");
        const PMID pmid = PMID(hex_chars_to_int(*line, 0, 2));
        const int x = hex_chars_to_int(*line, 3, 3, 0);
        const int y = hex_chars_to_int(*line, 7, 4, 288);
        const int vx = hex_chars_to_int(*line, 12, 5, 0);
        const int vy = hex_chars_to_int(*line, 18, 5, 0);
        create_object(pmid, std::move(extraData), x, y, vx, vy);
    }
}

void GameState::update()
{
    play_song("game");

    // Win/loss detection.
    if (m_result == Result::PLAYING && (m_player->action == ACT_DEAD || m_player->marked)) {
        lose("Du bist gestorben.");
    }
    else if (m_result == Result::PLAYING && m_player->y < map.level_top()) {
        if (stars < stars_goal) {
            lose("Du hast verloren, weil du nicht genug Sterne gesammelt hast.");
        }
        else if (find_object(ID_HOSTAGE, ID_HOSTAGE, Rect(0, 0, 576, 24576))) {
            lose("Du hast verloren, weil du nicht alle Gefangenen befreit hast.");
        }
        else {
            m_result = Result::WON;
        }
    }

    if (m_result != Result::PLAYING || m_paused) {
        return;
    }

    frame += 1;
    frame %= 2400;
    if (m_message_opacity > 0) {
        m_message_opacity -= 3;
    }

    // TODO: Run the per-tile and timer scripts (execute_script) once we have PMScript.

    // Rising lava.
    if (map.lava_time_left == 0) {
        if (map.lava_speed != 0) {
            if (map.lava_mode == 0 && frame % map.lava_speed == 0) {
                map.lava_pos -= 1;
            }
            else if (map.lava_mode == 1) {
                map.lava_pos -= map.lava_speed;
            }
            map.lava_frame += 1;
            map.lava_frame %= 120;
            if (frame % 10 == 0 && rand(10) == 0) {
                emit_sound(map.lava_pos, "lava");
            }
        }
    }
    else {
        map.lava_time_left -= 1;
    }

    // The camera follows the lava and the player.
    view_pos = std::clamp(std::min(map.lava_pos - 432, m_player->y - 240), map.level_top(), 24096);

    // Player movement.
    LivingObject& player = *m_player;
    const ObjectDef& def = ObjectDef::get(player.pmid);
    if (fly_time_left == 0 && !player.in_water()) {
        if (is_down(InputAction::Left)) {
            if (!player.busy() && player.vx > -def.speed * 1.75) {
                player.vx -= def.speed + (speed_time_left > 0 ? 6 : 0);
            }
            if (player.action == ACT_JUMP || player.action == ACT_LAND
                || player.action == ACT_PAIN_1 || player.action == ACT_PAIN_2) {
                for (int i = 0; i < def.jump_x * 2; ++i) {
                    if (!player.blocked(DIR_LEFT)) {
                        player.x -= 1;
                    }
                }
            }
        }
        if (is_down(InputAction::Right)) {
            if (!player.busy() && player.vx < def.speed * 1.75) {
                player.vx += def.speed + (speed_time_left > 0 ? 6 : 0);
            }
            if (player.action == ACT_JUMP || player.action == ACT_LAND
                || player.action == ACT_PAIN_1 || player.action == ACT_PAIN_2) {
                for (int i = 0; i < def.jump_x * 2; ++i) {
                    if (!player.blocked(DIR_RIGHT)) {
                        player.x += 1;
                    }
                }
            }
        }
    }
    else {
        for (int i = 0; i < 4; ++i) {
            if (is_down(InputAction::Up) && player.vy > -4) {
                player.vy -= 1;
            }
        }
        for (int i = 0; i < 2; ++i) {
            if (is_down(InputAction::Down) && player.vy < +4) {
                player.vy += 1;
            }
        }
        for (int i = 0; i < 4; ++i) {
            if (is_down(InputAction::Left) && player.vx > -6) {
                player.vx -= 1;
            }
        }
        for (int i = 0; i < 4; ++i) {
            if (is_down(InputAction::Right) && player.vx < +6) {
                player.vx += 1;
            }
        }
        if (!player.in_water()) {
            if (player.vx > 0) {
                player.vx -= 1;
            }
            if (player.vx < 0) {
                player.vx += 1;
            }
            if (player.vy > 0) {
                player.vy -= 1;
            }
            if (player.vy < 0) {
                player.vy += 1;
            }
        }
        else if (player.vx + player.vy > 1 && frame % 3 == 0 && rand(5) == 0) {
            play_sound("water" + std::to_string(rand(2) + 1));
        }
        if (player.vx < 0) {
            player.direction = DIR_LEFT;
        }
        if (player.vx > 0) {
            player.direction = DIR_RIGHT;
        }
    }

    // No actions in the first frames to avoid an accidental jump when coming from the main menu.
    if (frame > 2) {
        // Holding the jump button keeps Peter hopping.
        if (is_down(InputAction::Jump)) {
            m_player->jump();
        }
        // Holding down makes the player use stairs and other map tiles.
        if (is_down(InputAction::Use)) {
            m_player->use_tile();
        }
    }

    // Update every object, then delete those objects that were marked.
    for (const std::shared_ptr<GameObject>& obj : m_objects) {
        obj->update();
    }
    std::erase_if(m_objects, [](const std::shared_ptr<GameObject>& obj) { return obj->marked; });
}

void GameState::draw()
{
    map.draw(view_pos);

    for (const std::shared_ptr<GameObject>& obj : m_objects) {
        if (!obj->marked) {
            obj->draw();
        }
    }

    enum LavaTile
    {
        ACTIVE_SURFACE,
        FROZEN_SURFACE,
        ACTIVE_FILL,
        FROZEN_FILL
    };
    static const std::vector<Gosu::Image> lava_tiles
        = Gosu::load_tiles("media/danger.png", -2, -2, Gosu::IF_RETRO);
    const bool lava_active = map.lava_time_left == 0;
    const int scroll = map.lava_frame + (lava_active ? frame / 2 % 2 : 0);
    for (int x = -1; x <= 4; ++x) {
        lava_tiles[lava_active ? ACTIVE_SURFACE : FROZEN_SURFACE].draw(
            x * 120 + scroll, map.lava_pos - view_pos, Z_LAVA);
    }
    if (map.lava_pos < map.level_top() + 432) {
        for (int x = -1; x <= 4; ++x) {
            for (int y = 0; y <= (map.level_top() + 432 - map.lava_pos) / 48 + 1; ++y) {
                lava_tiles[lava_active ? ACTIVE_FILL : FROZEN_FILL].draw(
                    x * 120 + scroll, map.lava_pos - view_pos + 48 + y * 48, Z_LAVA);
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

    draw_centered_string("Punkte: " + std::to_string(score), WINDOW_WIDTH / 2, 5);
}

void GameState::draw_status_bar()
{
    static const std::vector<Gosu::Image> gui
        = Gosu::load_tiles("media/gui.bmp", -4, -11, Gosu::IF_RETRO);
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
        gui[8].draw(tile_w * 0, tile_h * 2, Z_UI);
        gui[9].draw(tile_w * 1, tile_h * 2, Z_UI);
        draw_digits(m_player->life, 2);
        // Keys
        gui[10].draw(tile_w * 0, tile_h * 3, Z_UI);
        gui[11].draw(tile_w * 1, tile_h * 3, Z_UI);
        draw_digits(keys, 3);
        // Stars
        gui[12].draw(tile_w * 0, tile_h * 4, Z_UI);
        gui[13].draw(tile_w * 1, tile_h * 4, Z_UI);
        draw_digits(stars, 4);
        if (stars > stars_goal) {
            // Enough stars - draw checkmark
            gui[42].draw(tile_w * 2, tile_h * 4, Z_UI);
            gui[43].draw(tile_w * 3, tile_h * 4, Z_UI);
        }
        if (stars_goal == 0) {
            // Or blank the line out if no stars are needed
            blank_line(4);
        }
        // Remaining special Peter morph time.
        if (m_player->pmid == ID_PLAYER) {
            blank_line(5);
        }
        else {
            gui[14].draw(tile_w * 0, tile_h * 5, Z_UI);
            gui[15].draw(tile_w * 1, tile_h * 5, Z_UI);
            draw_digits(time_left / TARGET_FPS, 5);
        }
        // Ammo
        gui[16].draw(tile_w * 0, tile_h * 6, Z_UI);
        gui[17].draw(tile_w * 1, tile_h * 6, Z_UI);
        draw_digits(ammo, 6);
        // Bombs
        gui[18].draw(tile_w * 0, tile_h * 7, Z_UI);
        gui[19].draw(tile_w * 1, tile_h * 7, Z_UI);
        draw_digits(bombs, 7);
        // Remaining time for frozen lava.
        if (map.lava_time_left == 0) {
            blank_line(8);
        }
        else {
            gui[40].draw(tile_w * 0, tile_h * 8, Z_UI);
            gui[41].draw(+tile_w * 1, tile_h * 8, Z_UI);
            draw_digits(map.lava_time_left / TARGET_FPS, 8);
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
            play_sound("whoosh");
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
            if (is_mapped_to(InputAction::Jump, id) && fly_time_left == 0) {
                m_player->jump();
            }
        }
        break;
    case Result::LOST:
        if (is_mapped_to(InputAction::MenuCancel, id)) {
            play_sound("whoosh");
            pop_state();
        }
        break;
    case Result::WON:
        if (is_mapped_to(InputAction::MenuConfirm, id)
            || is_mapped_to(InputAction::MenuCancel, id)) {
            play_sound("whoosh");
            pop_state();
        }
        break;
    }
}

void GameState::lose(std::string reason)
{
    m_result = Result::LOST;
    m_reason = std::move(reason);
}

void GameState::emit_sound(int y, const std::string& name)
{
    constexpr int MAX_SOUND_DISTANCE = 500;
    const int distance = std::abs(y - m_player->y);
    if (distance < MAX_SOUND_DISTANCE) {
        play_sound(name, 1 - 1.0 * distance / MAX_SOUND_DISTANCE);
    }
}

void GameState::cast_fx(int smoke, int flames, int sparks, int x, int y, int width, int height,
                        int vx, int vy, int randomness)
{
    // Don't waste time on particles that are out of sight.
    if (std::abs(view_pos + WINDOW_HEIGHT / 2 - y) > WINDOW_HEIGHT) {
        return;
    }

    const auto cast_single_fx = [&](PMID pmid, int count) {
        for (int i = 0; i < count; ++i) {
            int sx = std::clamp(x - width / 2 + rand(width + 1), 0, 575);
            int sy = y - height / 2 + rand(height + 1);
            create_object(pmid, "", sx, sy, vx - randomness + rand(randomness * 2 + 1),
                          vy - randomness + rand(randomness * 2 + 1));
        }
    };
    cast_single_fx(ID_FX_SMOKE, smoke);
    cast_single_fx(ID_FX_FLAME, flames);
    cast_single_fx(ID_FX_SPARK, sparks);
}

void GameState::cast_objects(PMID pmid, int count, int vx, int vy, int randomness, const Rect& rect)
{
    for (int i = 0; i < count; ++i) {
        create_object(pmid, "", rect.left + rand(rect.width), rect.top + rand(rect.height),
                      vx - randomness + rand(randomness * 2 + 1),
                      vy - randomness + rand(randomness * 2 + 1));
    }
}

GameObject* GameState::create_object(PMID pmid, std::string extraData, int x, int y, int vx, int vy)
{
    std::shared_ptr<GameObject> object;
    if (pmid <= ID_LIVING_MAX) {
        // Enemies: created, but the AI and enemy drawing are not ported yet, so they just fall
        // idle.
        object = std::make_shared<LivingObject>(*this, std::move(extraData), pmid, x, y, vx, vy,
                                                ObjectDef::get(pmid).life, ACT_STAND,
                                                Direction(rand(2)));
    }
    else if (pmid <= ID_OTHER_OBJECTS_MAX) {
        object = std::make_shared<GameObject>(*this, std::move(extraData), pmid, x, y, vx, vy);
    }
    else if (pmid <= ID_COLLECTIBLE_MAX) {
        object
            = std::make_shared<CollectibleObject>(*this, std::move(extraData), pmid, x, y, vx, vy);
    }
    else if (pmid <= ID_FX_MAX) {
        object = std::make_shared<EffectObject>(*this, std::move(extraData), pmid, x, y, vx, vy);
    }
    else {
        return nullptr;
    }
    m_objects.push_back(object);
    return object.get();
}

void GameState::explosion(int, int, int, bool)
{
    // TODO: Create effects and damage nearby living objects.
}

GameObject* GameState::find_object(PMID min_id, PMID max_id, const Rect& rect)
{
    for (auto& obj : m_objects) {
        if (between(obj->pmid, min_id, max_id) && rect.contains(obj->x, obj->y)) {
            return obj.get();
        }
    }
    return nullptr;
}

GameObject* GameState::find_living(PMID min_id, PMID max_id, Action min_act, Action max_act,
                                   const Rect& rect)
{
    for (auto& obj : m_objects) {
        if (between(obj->pmid, min_id, max_id) && obj->rect_collides(rect)) {
            auto* living = dynamic_cast<LivingObject*>(obj.get());
            if (living && between(living->action, min_act, max_act)) {
                return obj.get();
            }
        }
    }
    return nullptr;
}

GameObject* GameState::launch_projectile(int, int, Direction, PMID, PMID)
{
    // TODO: Later...
    return nullptr;
}
