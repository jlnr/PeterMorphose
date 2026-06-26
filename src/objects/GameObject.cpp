#include "objects/GameObject.hpp"
#include <Gosu/Gosu.hpp>
#include "LivingObject.hpp"
#include "Map.hpp"
#include "ObjectDef.hpp"
#include "helpers/String.hpp"
#include "states/GameState.hpp"
#include <algorithm>
#include <cmath>
#include <string>

GameObject::GameObject(GameState& game, std::string extra_data, PMID pmid, //
                       int x, int y, int vx, int vy)
    : game(game),
      pmid(pmid),
      x(x),
      y(y),
      vx(vx),
      vy(vy),
      extra_data(extra_data),
      marked(false),
      last_frame_in_water(in_water())
{
}

void GameObject::update()
{
    // Firewalls and fire: dissolve in lava, otherwise hurt overlapping living objects every frame.
    if (pmid == ID_FIREWALL_1 || pmid == ID_FIREWALL_2 || pmid == ID_FIRE) {
        if (y + ObjectDef::get(pmid).rect.bottom() - 11 > game.map.lava_pos) {
            game.cast_fx(4, 4, 0, x, y, 16, 16, 0, -3, 1);
            kill();
            game.emit_sound(y, "shshsh");
        }
        else {
            game.burn_everything(rect());
            return;
        }
    }

    // Hint arrows disappear once the player reaches them.
    if (pmid == ID_HELP_ARROW && rect(10, 20).contains(game.player().x, game.player().y)) {
        kill();
    }

    // Fish swim back and forth in water and fall (and react to tiles) out of it.
    if (pmid == ID_FISH || pmid == ID_FISH_2) {
        if (!in_water()) {
            fall();
            check_tile();
        }
        else if (pmid == ID_FISH) {
            x -= 2;
            if (blocked(DIR_LEFT)) {
                pmid = ID_FISH_2;
            }
            if (rand(30) == 0) {
                game.create_object(ID_FX_WATER_BUBBLE, "", x, y - 3, 0, 0);
            }
        }
        else {
            x += 2;
            if (blocked(DIR_RIGHT)) {
                pmid = ID_FISH;
            }
            if (rand(30) == 0) {
                game.create_object(ID_FX_WATER_BUBBLE, "", x, y - 3, 0, 0);
            }
        }
    }

    // Fusing bombs count up and explode - on a timer, or on contact with an enemy.
    if (pmid == ID_FUSING_BOMB) {
        bool extra_data_numeric = !extra_data.empty()
            && std::ranges::all_of(extra_data, [](char c) { return c >= '0' && c <= '9'; });
        int time = (extra_data_numeric ? string_to_int(extra_data) : 0) + 1;
        extra_data = std::to_string(time);
        if (time >= 25) {
            kill();
            game.explosion(x, y, 50, true);
            return;
        }

        LivingObject* enemy = game.find_living(ID_ENEMY, ID_ENEMY_MAX, //
                                               ACT_STAND, ACT_PAIN_2, rect(1, 1));
        if (enemy) {
            enemy->hurt(true);
            kill();
            game.explosion(x, y, 50, true);
            return;
        }
        fall();
        check_tile();
    }

    // Rocks and other trash fall down.
    if (between(pmid, ID_TRASH, ID_TRASH_4)) {
        fall();
        check_tile();
    }

    // Get roasted by lava.
    if (y + ObjectDef::get(pmid).rect.bottom() > game.map.lava_pos) {
        game.cast_fx(4, 4, 0, x, y, 16, 16, 0, -3, 1);
        kill();
        game.emit_sound(y, "shshsh");
    }
}

void GameObject::check_tile()
{
    // Only living objects (the player and enemies) have a direction and can be hit.
    auto* living = dynamic_cast<LivingObject*>(this);
    const bool enemy = between(pmid, ID_ENEMY, ID_ENEMY_MAX);

    switch (game.map[x / TILE_SIZE, y / TILE_SIZE]) {
    case TILE_AIR_ROCKET_UP:
    case TILE_AIR_ROCKET_UP_2:
    case TILE_AIR_ROCKET_UP_3:
        game.emit_sound(y, "turbo");
        fling(0, -21, 0, true, false);
        if (!blocked(DIR_UP)) {
            y -= 1;
        }
        x = x / TILE_SIZE * TILE_SIZE + 11;
        if (living && enemy) {
            vx = dir_to_vx(living->direction);
        }
        game.cast_fx(0, 0, 10, x, y, 24, 24, 0, -10, 1);
        break;

    case TILE_AIR_ROCKET_UP_LEFT:
        game.emit_sound(y, "turbo");
        if (!blocked(DIR_UP)) {
            y -= 1;
        }
        fling(-10, -16, 0, true, false);
        y = y / TILE_SIZE * TILE_SIZE + 11;
        for (int i = 0; i < TILE_SIZE && stuck(); ++i) {
            vy -= 1;
        }
        game.cast_fx(0, 0, 10, x, y, 24, 24, -8, -8, 1);
        break;

    case TILE_AIR_ROCKET_UP_RIGHT:
        game.emit_sound(y, "turbo");
        if (!blocked(DIR_UP)) {
            y -= 1;
        }
        fling(+10, -16, 0, true, false);
        y = y / TILE_SIZE * TILE_SIZE + 11;
        for (int i = 0; i < TILE_SIZE && stuck(); ++i) {
            vy -= 1;
        }
        game.cast_fx(0, 0, 10, x, y, 24, 24, +8, -8, 1);
        break;

    case TILE_AIR_ROCKET_LEFT:
        game.emit_sound(y, "turbo");
        fling(-20, -3, 0, true, false);
        y = y / TILE_SIZE * TILE_SIZE + 11;
        for (int i = 0; i < TILE_SIZE && stuck(); ++i) {
            vy -= 1;
        }
        game.cast_fx(0, 0, 10, x, y, 24, 24, -10, 0, 1);
        break;

    case TILE_AIR_ROCKET_RIGHT:
        game.emit_sound(y, "turbo");
        fling(+20, -3, 0, true, false);
        y = y / TILE_SIZE * TILE_SIZE + 11;
        for (int i = 0; i < TILE_SIZE && stuck(); ++i) {
            vy -= 1;
        }
        game.cast_fx(0, 0, 10, x, y, 24, 24, +10, 0, 1);
        break;

    case TILE_AIR_ROCKET_DOWN:
        game.emit_sound(y, "turbo");
        fling(0, 15, 0, true, false);
        y = y / TILE_SIZE * TILE_SIZE + 11;
        if (living && enemy) {
            vx = dir_to_vx(living->direction);
        }
        game.cast_fx(0, 0, 10, x, y, 24, 24, 0, 8, 1);
        break;

    case TILE_SLOW_ROCKET_UP:
        game.cast_fx(0, 0, 1, x, y, 24, 24, 0, -2, 1);
        vy -= 4;
        if (living && enemy) {
            vx = dir_to_vx(living->direction);
        }
        else {
            vx /= 2;
        }
        if (living && pmid <= ID_LIVING_MAX) {
            living->action = ACT_JUMP;
        }
        break;

    case TILE_SPIKES:
        if (living && pmid <= ID_LIVING_MAX && (y + ObjectDef::get(pmid).rect.bottom()) % 24 > 8) {
            living->hit();
            vx = 0;
            vy = -10;
        }
        break;

    case TILE_SPIKES_TOP:
        if (living && pmid <= ID_LIVING_MAX && (y + ObjectDef::get(pmid).rect.bottom()) % 24 < 14) {
            living->hit();
            vx = 0;
            vy = 5;
        }
        break;

    default:
        break;
    }
}

void GameObject::draw()
{
    static const std::vector<Gosu::Image> images
        = Gosu::load_tiles("media/stuff.bmp", -16, -3, Gosu::IF_RETRO);
    const int index = (pmid - ID_OTHER_OBJECTS_MIN);
    if (!between(index, 0, images.size() - 1)) {
        return;
    }

    Gosu::Color color = Gosu::Color::WHITE;
    Gosu::BlendMode mode = Gosu::BM_DEFAULT;
    if (pmid == ID_FIREWALL_1 || pmid == ID_FIREWALL_2 || pmid == ID_FIRE) {
        // Pulsate as in TPMObject.Draw.
        int pulse = std::abs(static_cast<int>(game.frame * 7.5) % 256 - 128);
        color = Gosu::Color::WHITE.with_alpha(std::clamp(127 + pulse, 0, 255));
        mode = Gosu::BM_ADD;
    }
    else if (pmid == ID_HELP_ARROW) {
        color = Gosu::Color::WHITE.with_alpha(127 + (game.frame / 8 % 2) * 64);
    }
    images[index].draw(x - 11, y - 11 - game.view_pos, 0, 1, 1, color, mode);
}

void GameObject::kill()
{
    // TODO: clear references to this object held once PMScript is ported.
    marked = true;
}

void GameObject::emit_text(const std::string& text, PMID text_pmid)
{
    game.create_object(text_pmid, text, x, y - 10, 0, -1);
}

void GameObject::fall()
{
    // Make a splash
    if (in_water() && !last_frame_in_water) {
        game.cast_objects(ID_FX_WATER, 5, -vx / 2, -5, 3, rect(1, 1));
        game.emit_sound(y, "water" + std::to_string(rand(2) + 1));
    }
    last_frame_in_water = in_water();

    // Gravity (except for when Peter can fly).
    if (pmid > ID_PLAYER_MAX || game.fly_time_left == 0) {
        vy += 1;
    }

    // Water slows everything down.
    if (in_water()) {
        if (vy > +1) {
            vy -= 1;
        }
        if (vy < -1) {
            vy += 1;
        }
        if (vx > +2) {
            vx -= 1;
        }
        if (vx < -2) {
            vx += 1;
        }
    }

    // Velocity is limited to TILE_SIZE so that tiles cannot be skipped in motion.
    vx = std::clamp(vx, -TILE_SIZE, TILE_SIZE);
    vy = std::clamp(vy, -TILE_SIZE, TILE_SIZE);

    // Remember whether the player was on ground at the start of this function.
    // This ensures we always either apply air or ground friction. In the Delphi and Ruby versions,
    // Peter goes too fast when he runs off a cliff because we apply neither for one frame.
    const bool on_ground = blocked(DIR_DOWN);

    // Air friction affects the player. This is new in Ruby, and is the major improvement over the
    // unusual jumping physics in the Delphi version.
    if (between(pmid, ID_PLAYER, ID_PLAYER_MAX) && !on_ground) {
        if (std::abs(vx) < 5) {
            vx = static_cast<int>(vx / 2.0);
        }
    }

    // Vertical movement, one pixel at a time so we stop exactly at obstacles.
    for (int i = 0; i < vy; ++i) {
        if (blocked(DIR_DOWN)) {
            break;
        }
        y += 1;
    }
    for (int i = 0; i < -vy; ++i) {
        if (blocked(DIR_UP)) {
            break;
        }
        y -= 1;
    }

    if (blocked(DIR_DOWN)) {
        auto* living = dynamic_cast<LivingObject*>(this);
        if (living && vx > 10 && living->action != ACT_DEAD && living->action != ACT_ACTION_1
            && living->action != ACT_ACTION_2) {
            living->action = Action(ACT_IMPACT_1 + std::min(vy - 11, 4));
        }
        vy = 0;

        // Conveyor belts pull objects into the respective direction.
        const Rect& rect = ObjectDef::get(pmid).rect;
        const int row_below = (y + rect.bottom() + 1) / TILE_SIZE;
        const Tile tile_below_left = game.map[(x + rect.left) / TILE_SIZE, row_below];
        if (tile_below_left == TILE_PULL_LEFT && !blocked(DIR_LEFT)) {
            x -= 1;
        }
        else if (tile_below_left == TILE_PULL_RIGHT && !blocked(DIR_RIGHT)) {
            x += 1;
        }
        const Tile tile_below_right = game.map[(x + rect.right()) / TILE_SIZE, row_below];
        if (tile_below_right == TILE_PULL_LEFT && !blocked(DIR_LEFT)) {
            x -= 1;
        }
        else if (tile_below_right == TILE_PULL_RIGHT && !blocked(DIR_RIGHT)) {
            x += 1;
        }
    }

    if (blocked(DIR_UP) && game.fly_time_left == 0) {
        // This follows the Delphi code. In Ruby, vx is not adjusted here. Not sure why?
        vy /= -2;
        vx /= 2;
    }

    // Horizontal movement, one pixel at a time.
    for (int i = 0; i < -vx; ++i) {
        if (blocked(DIR_LEFT)) {
            vx = 0;
            break;
        }
        x -= 1;
    }
    for (int i = 0; i < vx; ++i) {
        if (blocked(DIR_RIGHT)) {
            vx = 0;
            break;
        }
        x += 1;
    }

    // Ground friction and slime tiles.
    if ((pmid > ID_PLAYER_MAX || game.fly_time_left == 0) && on_ground) {
        const ObjectDef& def = ObjectDef::get(pmid);
        if (vx > 0) {
            vx -= 1;
        }
        if (vx > +1) {
            vx -= 1;
        }
        if (pmid <= ID_ENEMY_MAX && vx > +def.speed) {
            vx -= 1;
        }
        if (vx < 0) {
            vx += 1;
        }
        if (vx < -1) {
            vx += 1;
        }
        if (pmid <= ID_ENEMY_MAX && vx < -def.speed) {
            vx += 1;
        }

        Tile tile_below = game.map[x / TILE_SIZE, (y + def.rect.bottom() + 1) / TILE_SIZE];
        if (between(tile_below, TILE_SLIME, TILE_SLIME_3)) {
            for (int i = 0; i < 4 + game.frame % 2; ++i) {
                if (vx > 0) {
                    vx -= 1;
                }
                if (vx < 0) {
                    vx += 1;
                }
            }
            for (int i = 0; i < 2 + game.frame % 2; ++i) {
                if (pmid <= ID_ENEMY_MAX && vx > +def.speed) {
                    vx -= 1;
                }
                if (pmid <= ID_ENEMY_MAX && vx < -def.speed) {
                    vx += 1;
                }
            }
        }
    }

    // Add extra particle effects when objects are moving super fast.
    if (std::abs(vx) > 12 || vy < -15) {
        game.cast_fx(rand(5), rand(3), 0, x, y, 5, 5, 0, -2, 2);
    }
}

void GameObject::fling(int h, int v, int randomness, bool fixed, bool malign)
{
    if (pmid <= ID_PLAYER_MAX && malign
        && (game.inv_time_left > 0 || pmid == ID_PLAYER_BERSERKER)) {
        return;
    }

    if (fixed) {
        vx = 0;
        vy = 0;
    }

    // Why does it only cause drift to the right/bottom?? (Both Pascal and Ruby)
    vx += h + rand(randomness + 1);
    vy += v + rand(randomness + 1);
}

bool GameObject::blocked(Direction direction) const
{
    const Rect& r = ObjectDef::get(pmid).rect;
    switch (direction) {
    case DIR_LEFT:
        return game.map.is_solid(x + r.left - 1, y + r.top)
            || game.map.is_solid(x + r.left - 1, y + r.bottom());
    case DIR_RIGHT:
        return game.map.is_solid(x + r.right() + 1, y + r.top)
            || game.map.is_solid(x + r.right() + 1, y + r.bottom());
    case DIR_UP:
        return game.map.is_solid(x + r.left, y + r.top - 1)
            || game.map.is_solid(x + r.right(), y + r.top - 1);
    case DIR_DOWN:
        return game.map.is_solid(x + r.left, y + r.bottom() + 1)
            || game.map.is_solid(x + r.right(), y + r.bottom() + 1);
    default:
        return false;
    }
}

Rect GameObject::rect(int extra_width, int extra_height) const
{
    const Rect& r = ObjectDef::get(pmid).rect;
    return Rect(x + r.left - extra_width, y + r.top - extra_height, //
                r.width + extra_width * 2, r.height + extra_height * 2);
}

bool GameObject::stuck() const
{
    const Rect r = rect();
    return game.map.is_solid(r.left, r.top) || game.map.is_solid(r.right(), r.top)
        || game.map.is_solid(r.left, r.bottom()) || game.map.is_solid(r.right(), r.bottom());
}

bool GameObject::in_water() const
{
    Tile tile = game.map[x / TILE_SIZE, y / TILE_SIZE];
    // For historical reasons, the water tile IDs are not contiguous!
    return between(tile, TILE_WATER, TILE_WATER_4) || tile == TILE_WATER_5;
}
