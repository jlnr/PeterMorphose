#include "objects/LivingObject.hpp"
#include <Gosu/Gosu.hpp>
#include "Map.hpp"
#include "ObjectDef.hpp"
#include "helpers/Audio.hpp"
#include "helpers/InputAction.hpp"
#include "helpers/String.hpp"
#include "states/GameState.hpp"
#include <algorithm>
#include <cmath>
#include <string>

LivingObject::LivingObject(GameState& game, std::string extra_data, PMID pmid, //
                           int x, int y, int vx, int vy, //
                           int life, Action action, Direction direction)
    : GameObject(game, std::move(extra_data), pmid, x, y, vx, vy),
      life(life),
      action(action),
      direction(direction)
{
}

void LivingObject::draw()
{
    if (action == ACT_INV_UP || action == ACT_INV_DOWN) {
        return;
    }

    if (between(pmid, ID_PLAYER, ID_PLAYER_BOMBER)) {
        // Draw wings while the fly power-up is active.
        if (game.fly_time_left > 0) {
            // Wings live in effects.bmp, which is loaded here again, not shared with EffectObject.
            static const std::vector<Gosu::Image> effects_images
                = Gosu::load_tiles("media/effects.bmp", -7, -7);
            Gosu::Color wings_color
                = Gosu::Color::WHITE.with_alpha(std::min(game.fly_time_left * 2 + 16, 255));
            const Gosu::Image& left = effects_images[38 + (game.frame / 2) % 4];
            const Gosu::Image& right = effects_images[42 + (game.frame / 2) % 4];
            if (direction == DIR_LEFT) {
                left.draw(x - 18, y - 12 - game.view_pos, 0, 0.75, 1, wings_color, Gosu::BM_ADD);
                right.draw(x, y - 12 - game.view_pos, 0, 1.00, 1, wings_color, Gosu::BM_ADD);
            }
            else {
                left.draw(x - 24, y - 12 - game.view_pos, 0, 1.00, 1, wings_color, Gosu::BM_ADD);
                right.draw(x, y - 12 - game.view_pos, 0, 0.75, 1, wings_color, Gosu::BM_ADD);
            }
        }

        static const std::vector<Gosu::Image> player_images
            = Gosu::load_tiles("media/player.bmp", -ACT_NUM, -10, Gosu::IF_RETRO);
        const int row = direction + (pmid - ID_PLAYER) * 2;
        const Gosu::Image& image = player_images[ACT_NUM * row + action];
        // Be translucent if we are invulnerable from recent damage (except as Feuerpeter).
        Gosu::Color color = Gosu::Color::WHITE;
        if (game.inv_time_left > 0 && pmid != ID_PLAYER_BERSERKER) {
            color.alpha = 160;
        }
        image.draw(x - 11, y - 11 - game.view_pos, 0, 1, 1, color);
    }
    else if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
        // The archer always magically faces the player.
        if (pmid == ID_ENEMY_GUN) {
            direction = (x > game.player().x ? DIR_LEFT : DIR_RIGHT);
        }

        static const std::vector<Gosu::Image> enemy_images
            = Gosu::load_tiles("media/enemies.bmp", -ACT_NUM, -10, Gosu::IF_RETRO);
        const int row = direction + (pmid - ID_ENEMY) * 2;
        const Gosu::Image& image = enemy_images[ACT_NUM * row + action];
        image.draw(x - 11, y - 11 - game.view_pos);
    }
}

void LivingObject::update()
{
    // Be affected by gravity.
    if (action < ACT_INV_UP) {
        fall();
    }

    // Or roasted by lava.
    if (y + ObjectDef::get(pmid).rect.bottom() > game.map.lava_pos) {
        game.cast_fx(8, 8, 0, x, y, 16, 16, 0, -4, 1);
        kill();

        game.emit_sound(y, "Shshsh");
        if (action != ACT_DEAD) {
            if (pmid <= ID_PLAYER_MAX) {
                game.emit_sound(y, "PlayerArg");
            }
            if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
                game.emit_sound(y, "Arg");
            }
        }
        return;
    }

    // Climbing a staircase. Downstairs is faster and noisier than upstairs.
    // Adapted from TPMLiving.Update in the Pascal version.
    const auto is_open_door
        = [](Tile tile) { return tile > TILE_STAIRS_UP_LOCKED && tile != TILE_STAIRS_DOWN_LOCKED; };
    const auto tile_below = [this] { return game.map[x / TILE_SIZE, (y + 12) / TILE_SIZE]; };
    const auto tile_above = [this] { return game.map[x / TILE_SIZE, (y - 9) / TILE_SIZE]; };
    if (action == ACT_INV_UP) {
        if (rand(8) == 0) {
            game.emit_sound(y, "StairsRnd");
        }
        for (int i = 0; i <= 2; ++i) {
            if (!is_open_door(tile_below()) || !is_open_door(tile_above())) {
                y -= 2;
                if (i == 2) {
                    // Skip the rest of the function, we are still stuck in the staircase.
                    return;
                }
            }
            else {
                x = x / TILE_SIZE * TILE_SIZE + TILE_SIZE / 2 - 1;
                break;
            }
        }
    }
    else if (action == ACT_INV_DOWN) {
        if (rand(7) == 0) {
            game.emit_sound(y, "StairsRnd");
        }
        for (int i = 0; i <= 3; ++i) {
            if (!is_open_door(tile_below()) || !is_open_door(tile_above())) {
                y += 2;
                if (i == 3) {
                    // Skip the rest of the function, we are still stuck in the staircase.
                    return;
                }
            }
            else {
                x = x / TILE_SIZE * TILE_SIZE + TILE_SIZE / 2 - 1;
                break;
            }
        }
    }

    if (action != ACT_DEAD) {
        check_tile();
    }

    // Break fragile tiles under our feet.
    const Rect break_area = rect(0, 2);
    break_floor(break_area.left, break_area.bottom());
    break_floor(break_area.right(), break_area.bottom());

    if (action == ACT_DEAD) {
        return;
    }

    if (in_water()) {
        // Create bubble particles.
        if (rand(30) == 0) {
            game.create_object(ID_FX_WATER_BUBBLE, "", x, y - 7, 0, 0);
        }
        // In water: Extinguish Feuerpeter...
        if (pmid == ID_PLAYER_BERSERKER) {
            pmid = ID_PLAYER;
            game.cast_fx(8, 0, 0, x, y, 24, 24, 0, -1, 4);
        }
        // ...and his evil counterpart:
        else if (pmid == ID_ENEMY_BERSERKER) {
            pmid = ID_ENEMY;
            game.cast_fx(8, 0, 0, x, y, 24, 24, 0, -1, 4);
        }
    }

    // Open adjacent doors if we have a key.
    if (pmid <= ID_PLAYER_MAX) {
        const Rect& rect = ObjectDef::get(pmid).rect;
        const auto open_door = [&](int tile_x, int tile_y) {
            Tile& tile = game.map[tile_x, tile_y];
            if (between(tile, TILE_CLOSED_DOOR, TILE_CLOSED_DOOR_3) && game.keys > 0) {
                tile = Tile(game.map[tile_x, tile_y] - (TILE_CLOSED_DOOR - TILE_OPEN_DOOR));
                game.keys -= 1;
                play_sound("Door");
            }
        };
        // Left
        open_door((x + rect.left - 1) / TILE_SIZE, y / TILE_SIZE);
        // Right
        open_door((x + rect.right() + 1) / TILE_SIZE, y / TILE_SIZE);
        // Up
        open_door(x / TILE_SIZE, (y + rect.top - 1) / TILE_SIZE);
        // Down
        open_door(x / TILE_SIZE, (y + rect.bottom() + 1) / TILE_SIZE);
    }

    // Regular Peter can flip levers in the middle of his animation.
    if (pmid == ID_PLAYER && action == ACT_ACTION_3 && game.frame % 2 == 0) {
        flip_lever();
    }

    // Ritterpeter: Apply sword damage.
    if (pmid == ID_PLAYER_FIGHTER && between(action, ACT_ACTION_1, ACT_ACTION_5)) {
        const Rect area(x - 11 + dir_to_vx(direction) * 6, y - 16, 22, 32);
        if (LivingObject* target = game.find_living(ID_ENEMY, ID_ENEMY_MAX, //
                                                    ACT_STAND, Action(ACT_PAIN_1 - 1), area)) {
            target->hit();
            target->fling(5 * dir_to_vx(direction), -4, 1, true, true);
            if (target->action == ACT_DEAD) {
                int bonus = ObjectDef::get(target->pmid).life * 3;
                game.score += bonus;
                target->emit_text("*" + std::to_string(bonus) + "*");
            }
        }
    }

    // Bogenpeter: Shoot an arrow at ACT_ACTION_5.
    if (pmid == ID_PLAYER_GUN && action == ACT_ACTION_5) {
        game.ammo -= 1;
        if (LivingObject* target = game.launch_projectile(x, y + 2, direction, //
                                                          ID_ENEMY, ID_ENEMY_MAX)) {
            target->hurt(true);
            target->fling(3 * dir_to_vx(direction), -3, 1, true, true);
            if (target->action == ACT_DEAD) {
                int bonus = ObjectDef::get(target->pmid).life * 3;
                game.score += bonus;
                target->emit_text("*" + std::to_string(bonus) + "*");
            }
        }
    }

    // Feuerpeter: Causes area-of-effect damage every frame.
    if (pmid == ID_PLAYER_BERSERKER) {
        game.cast_fx(rand(2), 2 + rand(2), 0, x, y, 18, 24, 0, -3, 2);
        game.burn_enemies(rect(2, 2));
    }

    // Feuergegner: Bumps into the player to hurt him.
    if (pmid == ID_ENEMY_BERSERKER) {
        game.cast_fx(0, rand(3), 0, x, y, 18, 24, 0, -2, 3);
        if (game.player().action < ACT_DEAD && game.player().rect_collides(rect(5, 2))) {
            game.player().hit();
            game.player().fling(8 * dir_to_vx(direction), -3, 0, true, true);
            fling(-8 * dir_to_vx(direction), -4, 0, true, false);
            return;
        }
    }

    // Bombenlegerpeter: Throw a bomb at ACT_ACTION_4.
    if (pmid == ID_PLAYER_BOMBER && action == ACT_ACTION_4 && game.frame % 3 == 0) {
        game.bombs -= 1;
        game.create_object(ID_FUSING_BOMB, "0", x + dir_to_vx(direction) * 5, y + 2,
                           dir_to_vx(direction) * 8, -3);
    }

    // Let a non-busy Peter face the direction he is moving in.
    if (pmid <= ID_PLAYER_MAX && !busy()) {
        if (vx < 0) {
            direction = DIR_LEFT;
        }
        if (vx > 0) {
            direction = DIR_RIGHT;
        }
    }

    // Enemy archer: Fire at the player at ACT_ACTION_4.
    if (pmid == ID_ENEMY_GUN && action == ACT_ACTION_4) {
        action = ACT_ACTION_5;
        Direction shoot_dir = game.player().x < x ? DIR_LEFT : DIR_RIGHT;
        if (LivingObject* target = game.launch_projectile(x, y + 2, shoot_dir, //
                                                          ID_PLAYER, ID_PLAYER_MAX)) {
            target->hit();
            target->fling(3 * dir_to_vx(shoot_dir), -3, 1, true, true);
        }
    }

    // Enemy "AI".
    if (pmid >= ID_ENEMY && !busy()) {
        // Turn around when bumping into walls.
        if (blocked(direction)) {
            direction = other_dir(direction);
        }

        // Run around.
        if ((pmid == ID_ENEMY_FIGHTER && game.frame % 100 < 70)
            || (pmid == ID_ENEMY_GUN && game.frame % 100 > 15) || pmid == ID_ENEMY
            || pmid == ID_ENEMY_BERSERKER || pmid == ID_ENEMY_BOMBER) {
            if (game.map.is_solid(x + dir_to_vx(direction) * 7,
                                  y + ObjectDef::get(pmid).rect.bottom() + 1)) {
                vx += ObjectDef::get(pmid).speed * dir_to_vx(direction);
            }
            else if (!extra_data.empty() && extra_data[0] == '1') {
                jump();
            }
            else {
                direction = other_dir(direction);
            }
        }

        // Occasionally make enemies use floor tiles.
        if (rand(100) == 0 && extra_data.size() > 2 && extra_data[2] == '1') {
            use_tile();
            return;
        }

        // Charge at the player.
        if (pmid == ID_ENEMY_FIGHTER && game.player().action < ACT_DEAD
            && game.player().rect_collides(Rect(x - 120 + int(direction) * 120, y - 24, 120, 48))
            && game.map.is_solid(x + dir_to_vx(direction) * 7,
                                 y + ObjectDef::get(pmid).rect.bottom() + 1)) {
            vx = ObjectDef::get(pmid).speed * 2 * dir_to_vx(direction);
        }

        // Enemy archer: Start shooting once the line of sight to the player is clear.
        if (pmid == ID_ENEMY_GUN && game.player().action < ACT_DEAD
            && rect(320, 1).contains(game.player().x, game.player().y)) {
            bool is_blocked = false;
            int tiles_to_check = std::abs(game.player().x - x) / TILE_SIZE;
            for (int i = 0; i <= tiles_to_check; ++i) {
                if (game.map.is_solid(i * TILE_SIZE + std::min(game.player().x, x), y)) {
                    is_blocked = true;
                    break;
                }
            }
            if (!is_blocked) {
                action = ACT_ACTION_1;
                return;
            }
        }

        // Contact damage.
        if (game.player().action < ACT_PAIN_1 && rect_collides(game.player().rect(1, -1))) {
            if (pmid == ID_ENEMY_BOMBER) {
                game.player().hurt(true);
                game.cast_fx(10, 30, 10, x, y, 10, 10, 0, -10, 5);
                kill();
            }
            else {
                game.player().hit();
                fling(-6 * dir_to_vx(direction), -2, 0, true, false);
            }
            game.player().fling(8 * dir_to_vx(direction), -3, 0, true, true);
            return;
        }
    }

    // Collide with the player while airborne (Delphi uses different knockback than on the ground).
    if (pmid >= ID_ENEMY && (action == ACT_JUMP || action == ACT_LAND)
        && rect_collides(game.player().rect(0, -1))) {
        if (pmid == ID_ENEMY_BOMBER) {
            game.player().hurt(true);
            game.cast_fx(10, 30, 10, x, y, 10, 10, 0, -10, 5);
            kill();
        }
        else {
            game.player().hit();
            fling(-7 * dir_to_vx(direction), 4, 1, true, false);
        }
        game.player().fling(8 * dir_to_vx(direction), -4, 0, true, true);
        return;
    }

    // Flying.
    if (pmid <= ID_PLAYER_MAX && game.fly_time_left > 0
        && !between(action, ACT_ACTION_1, ACT_ACTION_5)) {
        action = vy < 0 ? ACT_JUMP : ACT_LAND;
        return;
    }

    // The pain only ends when the player lands.
    if ((action == ACT_PAIN_1 || action == ACT_PAIN_2) && !blocked(DIR_DOWN) && !in_water()) {
        return;
    }

    // Getting back up after a hard landing.
    if (between(action, ACT_IMPACT_1, ACT_IMPACT_5)) {
        if (game.frame % 2 != 0) {
            action = Action(action - 1);
        }
        if (!(action == ACT_IMPACT_1 && game.frame % 2 == 1)) {
            return;
        }
    }

    // Continue the special action, which slows down the actor.
    if (between(action, ACT_ACTION_1, ACT_ACTION_4)) {
        int slowness = 1;
        switch (pmid) {
        case ID_PLAYER:
        case ID_PLAYER_GUN:
        case ID_ENEMY_FIGHTER:
            slowness = 2;
            break;
        case ID_ENEMY_GUN:
            slowness = 5;
            break;
        case ID_PLAYER_BOMBER:
            slowness = 3;
            break;
        default:
            break;
        }
        if (game.frame % slowness != 0) {
            return;
        }
        action = Action(action + 1);
        return;
    }

    if (!blocked(DIR_DOWN)) {
        action = vy < 0 ? ACT_JUMP : ACT_LAND;
        return;
    }

    // Walking on slime: a stickier, slower animation.
    // Unfortunately, this is also where the slime sounds have been implemented.
    if (between(game.map[x / TILE_SIZE, (y + ObjectDef::get(pmid).rect.bottom() + 1) / TILE_SIZE],
                TILE_SLIME, TILE_SLIME_3)) {
        const bool player_walking
            = pmid <= ID_PLAYER_MAX && (is_down(InputAction::Left) || is_down(InputAction::Right));
        // Enemies use the same "am I currently walking?" timing as their AI below.
        const bool enemy_walking = (pmid == ID_ENEMY_FIGHTER && game.frame % 100 < 70)
            || (pmid == ID_ENEMY_GUN && game.frame % 100 > 15) || pmid == ID_ENEMY
            || pmid == ID_ENEMY_BERSERKER || pmid == ID_ENEMY_BOMBER;
        if (player_walking || enemy_walking) {
            action = Action(ACT_WALK_1 + game.frame % 12 / 3);
            if (pmid <= ID_PLAYER_MAX) {
                if (is_down(InputAction::Left)) {
                    direction = DIR_LEFT;
                }
                if (is_down(InputAction::Right)) {
                    direction = DIR_RIGHT;
                }
            }
            if (std::abs(y - game.player().y) < WINDOW_HEIGHT && rand(5) == 0) {
                game.create_object(ID_FX_FLYING_BLOB, "", x, y + ObjectDef::get(pmid).rect.bottom(),
                                   rand(3) - 1, rand(3));
                game.emit_sound(y, "Slime");
            }
            return;
        }
    }

    // Walking animation.
    if (blocked(DIR_DOWN) && vx != 0) {
        action = Action(ACT_WALK_1 + game.frame % 8 / 2);
        return;
    }

    // If we are not doing anything else - then we are idle.
    action = ACT_STAND;
}

bool LivingObject::busy() const
{
    return !blocked(DIR_DOWN) || !between(action, ACT_STAND, ACT_WALK_4);
}

void LivingObject::jump()
{
    // Cannot jump when dead.
    if (action >= ACT_DEAD) {
        return;
    }

    if (in_water()) {
        // Cannot jump when in deep water.
        Tile tile_above = game.map[x / TILE_SIZE, (y - 3) / TILE_SIZE];
        if (between(tile_above, TILE_WATER, TILE_WATER_4) || tile_above == TILE_WATER_5) {
            return;
        }
    }
    else {
        // Cannot jump when busy.
        // Exception: This updated version of the game introduces "stateless coyote time": when
        // Peter is falling, see if he just walked off a cliff, and let him jump for a bit longer.
        const Rect& rect = ObjectDef::get(pmid).rect;
        int behind_x = x + (direction == DIR_RIGHT ? rect.left - 10 : rect.right() + 10);
        bool key_pressed = is_down(direction == DIR_LEFT ? InputAction::Left : InputAction::Right);
        bool coyote = action == ACT_LAND && key_pressed
            && game.map.is_solid(behind_x, y + rect.bottom() + 1)
            && !game.map.is_solid(behind_x, y + rect.top);
        if (busy() && !coyote) {
            return;
        }
    }

    Direction dir = DIR_UP;
    if (pmid <= ID_PLAYER_MAX) {
        if (is_down(InputAction::Left)) {
            dir = direction = DIR_LEFT;
        }
        if (is_down(InputAction::Right)) {
            dir = direction = DIR_RIGHT;
        }
    }
    else if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
        dir = direction;
    }

    const ObjectDef& def = ObjectDef::get(pmid);
    if (pmid <= ID_PLAYER_MAX && game.jump_time_left > 0) {
        vy = static_cast<int>(std::round(def.jump_y * 1.7)) - 1;
        game.cast_objects(ID_FX_SMOKE, 2, 0, 3, 2, rect(1, 0));
        play_sound("Turbo");
        dir = DIR_UP;
    }
    else {
        vy = def.jump_y - 1;
    }

    if (dir == DIR_UP) {
        vx = 0;
    }
    else {
        vx = dir_to_vx(dir) * std::max(def.jump_x, std::abs(vx) / 2);
    }

    // Slime tiles reduce the jumping height.
    int row_below = (y + def.rect.bottom() + 1) / TILE_SIZE;
    Tile tile_below_left = game.map[(x + def.rect.left) / TILE_SIZE, row_below];
    Tile tile_below_right = game.map[(x + def.rect.right()) / TILE_SIZE, row_below];
    if (between(tile_below_left, TILE_SLIME, TILE_SLIME_3)
        || between(tile_below_right, TILE_SLIME, TILE_SLIME_3)) {
        vx /= 3;
        vy /= 1.5;
    }

    if (in_water()) {
        vx /= 3;
        vy += 1;
        game.emit_sound(y, "Water");
    }

    action = ACT_JUMP;
    if (pmid <= ID_PLAYER_MAX) {
        play_sound("Jump");
    }
}

void LivingObject::hit()
{
    if (action == ACT_DEAD || pmid == ID_PLAYER_BERSERKER) {
        return;
    }
    // As a knight, Peter dodges half of all hits.
    if (pmid == ID_PLAYER_FIGHTER && rand(2) == 0) {
        return;
    }
    if (pmid <= ID_PLAYER_MAX) {
        if (game.inv_time_left > 0) {
            return;
        }
        game.inv_time_left = std::max(25, game.inv_time_left);
    }

    life -= 1;
    if (life < 1) {
        action = ACT_DEAD;
        life = 0;
    }
    else {
        action = Action(ACT_PAIN_1 + rand(2));
    }

    if (between(pmid, ID_PLAYER, ID_PLAYER_MAX)) {
        play_sound("PlayerArg");
    }
    else if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
        game.emit_sound(y, "Arg");
    }

    if (pmid == ID_ENEMY_BOMBER && action == ACT_DEAD) {
        kill();
        game.cast_fx(10, 30, 10, x, y, 10, 10, 0, -10, 5);
    }
}

void LivingObject::hurt(bool from_explosion)
{
    if (action == ACT_DEAD || pmid == ID_PLAYER_BERSERKER) {
        return;
    }
    int damage = 3;
    // Knights rarely (1 in 6) shrug off a point of damage.
    if (pmid == ID_PLAYER_FIGHTER && rand(6) == 0) {
        damage -= 1;
    }
    if (pmid <= ID_PLAYER_MAX) {
        if (game.inv_time_left > 0) {
            damage = from_explosion ? 1 : 0;
        }
        if (from_explosion || game.inv_time_left == 0) {
            game.inv_time_left = std::max(25, game.inv_time_left);
        }
    }

    life -= damage;
    if (life < 1) {
        action = ACT_DEAD;
        life = 0;
    }
    else {
        action = Action(ACT_PAIN_1 + rand(2));
    }

    if (between(pmid, ID_PLAYER, ID_PLAYER_MAX)) {
        play_sound("PlayerArg");
    }
    else if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
        game.emit_sound(y, "Arg");
    }

    if (pmid == ID_ENEMY_BOMBER && action == ACT_DEAD) {
        kill();
        game.cast_fx(10, 30, 10, x, y, 10, 10, 0, -10, 5);
    }
}

void LivingObject::use_tile()
{
    if (busy()) {
        return;
    }

    // Lever behind player.
    if (pmid <= ID_PLAYER_MAX && can_reach_lever()) {
        if (pmid == ID_PLAYER) {
            // Only the normal Peter has an animation for that.
            action = ACT_ACTION_1;
        }
        else {
            flip_lever();
        }
        vx = 0;
        return;
    }

    const int foot_row = (y + ObjectDef::get(pmid).rect.bottom() + 1) / TILE_SIZE;
    const Tile foot_tile = game.map[x / TILE_SIZE, foot_row];
    switch (foot_tile) {
    case TILE_ROCKET_UP:
    case TILE_ROCKET_UP_2:
    case TILE_ROCKET_UP_3:
        if (pmid <= ID_PLAYER_MAX) {
            play_sound("Jump");
        }
        game.emit_sound(y, "Turbo");
        vx = 0;
        vy = -20;
        if (!blocked(DIR_UP)) {
            y -= 1;
        }
        action = ACT_JUMP;
        game.cast_fx(0, 0, 10, x, y, 24, 24, 0, -10, 1);
        return;

    case TILE_ROCKET_UP_LEFT:
    case TILE_ROCKET_UP_LEFT_2:
    case TILE_ROCKET_UP_LEFT_3:
        if (pmid <= ID_PLAYER_MAX) {
            play_sound("Jump");
        }
        game.emit_sound(y, "Turbo");
        vx = -15;
        vy = -15;
        if (!blocked(DIR_UP)) {
            y -= 1;
        }
        action = ACT_JUMP;
        direction = DIR_LEFT;
        game.cast_fx(0, 0, 10, x, y, 24, 24, -8, -8, 1);
        return;

    case TILE_ROCKET_UP_RIGHT:
    case TILE_ROCKET_UP_RIGHT_2:
    case TILE_ROCKET_UP_RIGHT_3:
        if (pmid <= ID_PLAYER_MAX) {
            play_sound("Jump");
        }
        game.emit_sound(y, "Turbo");
        vx = +15;
        vy = -15;
        if (!blocked(DIR_UP)) {
            y -= 1;
        }
        action = ACT_JUMP;
        direction = DIR_RIGHT;
        game.cast_fx(0, 0, 10, x, y, 24, 24, +8, -8, 1);
        return;

    case TILE_MORPH_FIGHTER:
    case TILE_MORPH_GUN:
    case TILE_MORPH_BERSERKER:
    case TILE_MORPH_BOMB:
        // Stepping onto a morph tile turns the player into the matching special form; the tile is
        // then spent (becomes TILE_MORPH_EMPTY). foot_row/foot_tile are captured before pmid
        // changes, so the cleared cell uses the old hitbox.
        if (pmid <= ID_PLAYER_MAX) {
            game.map[x / TILE_SIZE, foot_row] = TILE_MORPH_EMPTY;
            play_sound("Morph");
            pmid = PMID(ID_PLAYER_FIGHTER + foot_tile - TILE_MORPH_FIGHTER);
            if (pmid != ID_PLAYER) {
                game.time_left = ObjectDef::get(pmid).life;
            }
            game.cast_fx(8, 0, 0, x, y, 24, 24, 0, -1, 4);
            emit_text(ObjectDef::get(pmid).name + "!");
            return;
        }
        break;

    default:
        break;
    }

    // Interact with background tiles:
    switch (game.map[x / TILE_SIZE, y / TILE_SIZE]) {
    case TILE_STAIRS_UP_LOCKED:
        if (pmid > ID_PLAYER_MAX || game.keys == 0) {
            return;
        }
        game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_STAIRS_UP;
        game.keys -= 1;
        play_sound("Door");
        [[fallthrough]];

    case TILE_STAIRS_UP:
    case TILE_STAIRS_UP_2:
        if (!game.map.do_stairs_end(x / TILE_SIZE, y / TILE_SIZE) && pmid > ID_PLAYER_MAX) {
            return;
        }
        y = y / TILE_SIZE * TILE_SIZE;
        action = ACT_INV_UP;
        vx = vy = 0;
        game.emit_sound(y, "Stairs");
        break;

    case TILE_STAIRS_DOWN_LOCKED:
        if (pmid > ID_PLAYER_MAX || game.keys == 0) {
            return;
        }
        game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_STAIRS_DOWN;
        game.keys -= 1;
        play_sound("Door");
        [[fallthrough]];

    case TILE_STAIRS_DOWN:
    case TILE_STAIRS_DOWN_2:
        if (!game.map.do_stairs_end(x / TILE_SIZE, y / TILE_SIZE)) {
            return;
        }
        y = y / TILE_SIZE * TILE_SIZE + 13;
        action = ACT_INV_DOWN;
        vx = vy = 0;
        game.emit_sound(y, "Stairs");
        break;

    default:
        break;
    }
}

void LivingObject::special_action()
{
    if (game.frame == -1) {
        return;
    }

    switch (pmid) {
    case ID_PLAYER:
        // The plain Peter has no attack, he can only flip levers.
        break;

    case ID_PLAYER_FIGHTER:
        if (action > ACT_LAND) {
            return;
        }
        play_sound("SwordWoosh");
        action = ACT_ACTION_1;
        if (int tile_x = (x + 10 * dir_to_vx(direction)) / TILE_SIZE, tile_y = y / TILE_SIZE;
            between(game.map[tile_x, tile_y], TILE_BLOCKER, TILE_BLOCKER_3)) {
            game.map[tile_x, tile_y] = game.map[tile_x, tile_y] != TILE_BLOCKER_3
                ? TILE_BLOCKER_BROKEN
                : TILE_BLOCKER_3_BROKEN;
            game.cast_objects(ID_FX_BLOCKER_PARTS, 10, 0, -2, 5,
                              Rect(tile_x * TILE_SIZE, tile_y * TILE_SIZE, TILE_SIZE, TILE_SIZE));
            play_sound("BlockerBreak");
        }
        break;

    case ID_PLAYER_GUN:
        if (action <= ACT_LAND && game.ammo > 0) {
            action = ACT_ACTION_1;
        }
        break;

    case ID_PLAYER_BOMBER:
        if (action <= ACT_LAND && game.bombs > 0) {
            action = ACT_ACTION_1;
        }
        break;
    }
}

GameObject* LivingObject::can_reach_lever() const
{
    return game.find_object(ID_LEVER, ID_LEVER_RIGHT, rect(10, 3));
}

void LivingObject::flip_lever()
{
    GameObject* target = can_reach_lever();
    if (!target) {
        return;
    }
    play_sound("Lever");
    switch (target->pmid) {
    case ID_LEVER:
        target->pmid = ID_LEVER_DOWN;
        break;
    case ID_LEVER_LEFT:
        target->pmid = ID_LEVER_RIGHT;
        break;
    case ID_LEVER_RIGHT:
        target->pmid = ID_LEVER_LEFT;
        break;
    }

    // The extra_data lists tile changes (hex) or a PMScript snippet (TODO: port from Ruby).
    // If the string does not start with an upper-case hex byte, then we cannot handle it yet.
    if (target->extra_data.find_first_of("0123456789ABCDEF") != 0) {
        return;
    }

    // The first byte is the number of target tiles to change.
    int count = hex_chars_to_int(target->extra_data, 0, 1, 0);
    for (int i = 0; i < count; ++i) {
        // Next come the target tile coordinates in hex.
        int tile_x = hex_chars_to_int(target->extra_data, 2 + i * 10, 2, 0);
        int tile_y = hex_chars_to_int(target->extra_data, 5 + i * 10, 3, 0);
        // Then the target tile.
        Tile new_tile = Tile(hex_chars_to_int(target->extra_data, 9 + i * 10, 2, 0));
        Tile old_tile = game.map[tile_x, tile_y];
        game.map[tile_x, tile_y] = new_tile;
        // Store the previous tile, so flipping the lever again restores it.
        target->extra_data.replace(9 + i * 10, 2, byte_to_hex(old_tile));
        // Indicate that the tile has changed to the player.
        game.cast_fx(8, 0, 0, tile_x * TILE_SIZE + 10, tile_y * TILE_SIZE + 12, 24, 24, 0, 0, 2);
    }
}

void LivingObject::break_floor(int px, int py)
{
    int tile_x = px / TILE_SIZE, tile_y = py / TILE_SIZE;
    if (between(game.map[tile_x, tile_y], TILE_BRIDGE, TILE_BRIDGE_4)) {
        if (game.find_object(ID_FX_BREAK, ID_FX_BREAK_2,
                             Rect(tile_x * TILE_SIZE, tile_y * TILE_SIZE, TILE_SIZE, TILE_SIZE))) {
            return;
        }
        game.create_object(PMID(ID_FX_BREAK + rand(2)), "", //
                           tile_x * TILE_SIZE + 11, tile_y * TILE_SIZE + 11, 0, 0);
        game.emit_sound(y, "Break");
    }
}
