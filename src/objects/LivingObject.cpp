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

    // TODO: Stairs...

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
