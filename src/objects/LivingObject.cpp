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
        // TODO: Draw wings.

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

    // TODO: Unlock doors.

    // TODO: Flip levers once we have them.

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
            target->fling(3 * dir_to_vx(direction) * 3, -3, 1, true, true);
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
            game.player().fling(8 * dir_to_vx(direction) * 8, -3, 0, true, true);
            fling(-8 * dir_to_vx(direction) * 8, -4, 0, true, false);
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
            else if (!extraData.empty() && extraData[0] == '1') {
                jump();
            }
            else {
                direction = other_dir(direction);
            }
        }

        // Occasionally make enemies use floor tiles.
        if (rand(100) == 0 && extraData.size() > 2 && extraData[2] == '1') {
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
                game.cast_fx(10, 30, 10, x, y, 10, 20, 0, -10, 5);
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

    // Collide with the player while airborne.
    if (pmid >= ID_ENEMY && (action == ACT_JUMP || action == ACT_LAND)
        && rect_collides(game.player().rect(0, -1))) {
        if (pmid == ID_ENEMY_BOMBER) {
            game.player().hurt(true);
            game.cast_fx(10, 30, 10, x, y, 10, 20, 0, -10, 5);
            kill();
        }
        else {
            game.player().hit();
            fling(-6 * dir_to_vx(direction), -2, 0, true, false);
        }
        game.player().fling(8 * dir_to_vx(direction), -3, 0, true, true);
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
        if (pmid <= ID_PLAYER_MAX && (is_down(InputAction::Left) || is_down(InputAction::Right))) {
            action = Action(ACT_WALK_1 + game.frame % 12 / 3);
            if (is_down(InputAction::Left)) {
                direction = DIR_LEFT;
            }
            if (is_down(InputAction::Right)) {
                direction = DIR_RIGHT;
            }
            if (std::abs(y - game.player().y) < WINDOW_HEIGHT && rand(5) == 0) {
                game.create_object(ID_FX_FLYING_BLOB, "", x, y + ObjectDef::get(pmid).rect.bottom(),
                                   rand(3) - 1, rand(3));
                game.emit_sound(y, "slime" + std::to_string(rand(3) + 1));
            }
            return;
        }
        // TODO: The same for enemies
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
        play_sound("turbo");
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
        game.emit_sound(y, "water" + std::to_string(rand(2) + 1));
    }

    action = ACT_JUMP;
    if (pmid <= ID_PLAYER_MAX) {
        play_sound("jump");
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
        play_sound("player_arg");
    }
    else if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
        game.emit_sound(y, "arg" + std::to_string(rand(2) + 1));
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
    if (pmid == ID_PLAYER_FIGHTER) {
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
        play_sound("player_arg");
    }
    else if (between(pmid, ID_ENEMY, ID_ENEMY_MAX)) {
        game.emit_sound(y, "arg" + std::to_string(rand(2) + 1));
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

    switch (game.map[x / TILE_SIZE, (y + ObjectDef::get(pmid).rect.bottom() + 1) / TILE_SIZE]) {
    case TILE_ROCKET_UP:
    case TILE_ROCKET_UP_2:
    case TILE_ROCKET_UP_3:
        if (pmid <= ID_PLAYER_MAX) {
            play_sound("jump");
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
            play_sound("jump");
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
            play_sound("jump");
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
        play_sound("door" + std::to_string(rand(2) + 1));
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
        play_sound("door" + std::to_string(rand(2) + 1));
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

void LivingObject::special_action()
{
    if (game.frame == -1) {
        return;
    }

    switch (pmid) {
    case ID_PLAYER:
        if (busy()) {
            return;
        }
        if (game.find_object(ID_LEVER, ID_LEVER_RIGHT, rect(10, 3))) {
            action = ACT_ACTION_1;
            vx = 0;
        }
        break;

    case ID_PLAYER_FIGHTER:
        if (action > ACT_LAND) {
            return;
        }
        play_sound("sword_whoosh");
        action = ACT_ACTION_1;
        if (int tile_x = (x + 10 * dir_to_vx(direction)) / TILE_SIZE, tile_y = y / TILE_SIZE;
            between(game.map[tile_x, tile_y], TILE_BLOCKER, TILE_BLOCKER_3)) {
            game.map[tile_x, tile_y] = game.map[tile_x, tile_y] != TILE_BLOCKER_3
                ? TILE_BLOCKER_BROKEN
                : TILE_BLOCKER_3_BROKEN;
            game.cast_objects(ID_FX_BLOCKER_PARTS, 10, 0, -2, 5,
                              Rect(tile_x * TILE_SIZE, tile_y * TILE_SIZE, TILE_SIZE, TILE_SIZE));
            play_sound("blocker_break");
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

    default:
        break;
    }
}
