#include "objects/GameObject.hpp"
#include "LivingObject.hpp"
#include "Map.hpp"
#include "ObjectDef.hpp"
#include "states/GameState.hpp"
#include <algorithm>
#include <cmath>
#include <string>

GameObject::GameObject(GameState& game, std::string extraData, PMID pmid, //
                       int x, int y, int vx, int vy)
    : game(game),
      pmid(pmid),
      x(x),
      y(y),
      vx(vx),
      vy(vy),
      extraData(extraData),
      marked(false),
      last_frame_in_water(in_water())
{
}

void GameObject::update()
{
    // TODO: Not yet ported from Ruby, we only want the player for now
}

void GameObject::draw()
{
    // TODO: Not yet ported from Ruby, we only want the player for now
}

void GameObject::kill()
{
    // TODO: clear references to this object held once PMScript is ported.
    marked = true;
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
        // Not ported: I don't think any level uses conveyor belts (TILE_PULL_LEFT/RIGHT)?
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
    if (std::abs(vx) > 12 || vx < -15) {
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
