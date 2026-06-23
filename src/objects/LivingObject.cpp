#include "objects/LivingObject.hpp"
#include <Gosu/Gosu.hpp>
#include "Map.hpp"
#include "ObjectDef.hpp"
#include "helpers/Audio.hpp"
#include "helpers/InputAction.hpp"
#include "states/GameState.hpp"
#include <algorithm>
#include <cmath>
#include <string>

LivingObject::LivingObject(GameState& game, std::string extraData, PMID pmid, //
                           int x, int y, int vx, int vy, //
                           int life, Action action, Direction direction)
    : GameObject(game, std::move(extraData), pmid, x, y, vx, vy),
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
        // TODO: Draw wings, consider whether the player is invulnerable from a recent hit.

        static const std::vector<Gosu::Image> player_images
            = Gosu::load_tiles("media/player.bmp", -ACT_NUM, -10, Gosu::IF_RETRO);
        const int row = direction + (pmid - ID_PLAYER) * 2;
        const Gosu::Image& image = player_images[ACT_NUM * row + action];
        image.draw(x - 11, y - 11 - game.view_pos, 0);
    }
    else {
        // TODO: Draw enemies.
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

        game.emit_sound(y, "shshsh");
        if (action != ACT_DEAD) {
            if (pmid <= ID_PLAYER_MAX) {
                game.emit_sound(y, "player_arg");
            }
            if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
                game.emit_sound(y, "arg" + std::to_string(rand(2) + 1));
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
            game.emit_sound(y, "stairs_steps");
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
            game.emit_sound(y, "stairs_steps");
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

    if (action == ACT_DEAD) {
        return;
    }

    // TODO: Water logic

    if (pmid <= ID_PLAYER_MAX && !busy()) {
        if (vx < 0) {
            direction = DIR_LEFT;
        }
        if (vx > 0) {
            direction = DIR_RIGHT;
        }
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

    if (!blocked(DIR_DOWN)) {
        action = vy < 0 ? ACT_JUMP : ACT_LAND;
        return;
    }

    // TODO: Slime animation...

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
        if (busy()) {
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
        sound("turbo").play();
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

        // Checking a single point as in Ruby, not two as in Delphi.
        Tile tile_below_left = game.map[x / TILE_SIZE, (y + def.rect.bottom() + 1) / TILE_SIZE];
        if (between(tile_below_left, TILE_SLIME, TILE_SLIME_3)) {
            vx /= 3;
            vy -= -2;
        }
    }

    if (in_water()) {
        vx /= 3;
        vy += 1;
        game.emit_sound(y, "water" + std::to_string(rand(2) + 1));
    }

    action = ACT_JUMP;
    if (pmid <= ID_PLAYER_MAX) {
        sound("jump").play();
    }
}

void LivingObject::use_tile()
{
    if (busy()) {
        return;
    }

    switch (game.map[x / TILE_SIZE, (y + ObjectDef::get(pmid).rect.bottom() + 1) / TILE_SIZE]) {
    case TILE_ROCKET_UP:
    case TILE_ROCKET_UP_2:
    case TILE_ROCKET_UP_3:
        if (pmid <= ID_PLAYER_MAX) {
            sound("jump").play();
        }
        game.emit_sound(y, "turbo");
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
            sound("jump").play();
        }
        game.emit_sound(y, "turbo");
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
            sound("jump").play();
        }
        game.emit_sound(y, "turbo");
        vx = +15;
        vy = -15;
        if (!blocked(DIR_UP)) {
            y -= 1;
        }
        action = ACT_JUMP;
        direction = DIR_RIGHT;
        game.cast_fx(0, 0, 10, x, y, 24, 24, +8, -8, 1);
        return;
    }

    // Interact with background tiles:
    switch (game.map[x / TILE_SIZE, y / TILE_SIZE]) {
    case TILE_STAIRS_UP_LOCKED:
        if (pmid > ID_PLAYER_MAX || game.keys == 0) {
            return;
        }
        game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_STAIRS_UP;
        game.keys -= 1;
        sound("door" + std::to_string(rand(2) + 1)).play();
        [[fallthrough]];

    case TILE_STAIRS_UP:
    case TILE_STAIRS_UP_2:
        if (!game.map.do_stairs_end(x / TILE_SIZE, y / TILE_SIZE) && pmid > ID_PLAYER_MAX) {
            return;
        }
        y = y / TILE_SIZE * TILE_SIZE;
        action = ACT_INV_UP;
        vx = vy = 0;
        game.emit_sound(y, "stairs");
        break;

    case TILE_STAIRS_DOWN_LOCKED:
        if (pmid > ID_PLAYER_MAX || game.keys == 0) {
            return;
        }
        game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_STAIRS_DOWN;
        game.keys -= 1;
        sound("door" + std::to_string(rand(2) + 1)).play();
        [[fallthrough]];

    case TILE_STAIRS_DOWN:
    case TILE_STAIRS_DOWN_2:
        if (!game.map.do_stairs_end(x / TILE_SIZE, y / TILE_SIZE)) {
            return;
        }
        y = y / TILE_SIZE * TILE_SIZE + 13;
        action = ACT_INV_DOWN;
        vx = vy = 0;
        game.emit_sound(y, "stairs");
        break;

    default:
        break;
    }
}
