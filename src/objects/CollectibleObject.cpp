#include "objects/CollectibleObject.hpp"
#include "Map.hpp"
#include "ObjectDef.hpp"
#include "helpers/Audio.hpp"
#include "objects/LivingObject.hpp"
#include "states/GameState.hpp"

CollectibleObject::CollectibleObject(GameState& game, std::string extraData, PMID pmid, //
                                     int x, int y, int vx, int vy)
    : GameObject(game, std::move(extraData), pmid, x, y, vx, vy)
{
}

void CollectibleObject::update()
{
    // The extraData of a collectible object decides whether it is affected by gravity.
    if (extraData.size() > 1 && extraData[1] == '1') {
        fall();
        // TODO: Port check_tile()
    }

    // Burn in lava.
    if (y + ObjectDef::get(pmid).rect.bottom() > game.map.lava_pos) {
        game.cast_fx(2, 2, 0, x, y, 16, 16, 0, -3, 1);
        kill();
        game.emit_sound(y, "shshsh");
        if (pmid == ID_HOSTAGE) {
            game.lose("Du hast verloren, weil eine Gefangene verbrannt ist.");
        }
        return;
    }

    // TODO: Fish movement.

    // Get collected by the player.
    if (game.player().action < ACT_DEAD && rect_collides(game.player().rect(2, 2))) {
        switch (pmid) {
        case ID_HOSTAGE:
            game.cast_objects(ID_FX_FLYING_CHAIN, 8, 0, -1, 3, rect(1, -1));
            game.create_object(ID_FX_FLYING_HOSTAGE, "", x, y, -7 + rand(15), -15);
            play_sound("yippie");
            game.score += 100;
            kill();
            break;

        case ID_KEY:
            play_sound("collect_key");
            game.player().emit_text(ObjectDef::get(pmid).name + "!");
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            game.score += 2;
            game.keys += 1;
            kill();
            break;

        case ID_HEALTH:
        case ID_HEALTH_2: {
            int amount = (pmid == ID_HEALTH_2 ? 4 : 1);
            play_sound("collect_health");
            game.player().emit_text("+" + std::to_string(amount));
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            game.score += amount;
            game.player().life += amount;
            kill();
            break;
        }

        case ID_STAR:
        case ID_STAR_2:
        case ID_STAR_3:
            play_sound("collect_star", Gosu::random(0.5, 0.7), Gosu::random(0.9, 1.1));
            game.score += 2;
            game.stars += 1;
            if (game.stars < game.stars_goal) {
                game.player().emit_text("Noch " + std::to_string(game.stars_goal - game.stars));
            }
            else if (game.stars == game.stars_goal) {
                game.player().emit_text("Genug gesammelt!");
            }
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            kill();
            break;

        case ID_MUNITION_GUN:
        case ID_MUNITION_GUN_2: {
            int amount = 1 + (pmid - ID_MUNITION_GUN) * 2;
            play_sound("collect_ammo");
            game.player().emit_text("+" + std::to_string(amount));
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            game.score += amount;
            game.ammo += amount;
            kill();
            break;
        }

        case ID_MUNITION_BOMBER:
        case ID_MUNITION_BOMBER_2: {
            int amount = 1 + (pmid - ID_MUNITION_BOMBER) * 2;
            play_sound("collect_ammo");
            game.player().emit_text("+" + std::to_string(amount));
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            game.score += amount;
            game.bombs += amount;
            kill();
            break;
        }

        // TODO: Port more collectibles.

        default:
            // The value of ID_POINTS_* is defined as their ObjectDef::life.
            if (between(pmid, ID_POINTS, ID_POINTS_MAX)) {
                play_sound("collect_points");
                game.player().emit_text("*" + std::to_string(ObjectDef::get(pmid).life) + "*");
                game.cast_objects(ID_FX_SPARKLE, 3, 0, 0, 0, rect());
                game.score += ObjectDef::get(pmid).life;
                kill();
            }
            // Morph medals turn Peter into the corresponding special form.
            if (between(pmid, ID_MORPH_FIGHTER, ID_MORPH_MAX)) {
                PMID target = PMID(ID_PLAYER_FIGHTER + pmid - ID_MORPH_FIGHTER);
                if (game.player().pmid != target) {
                    play_sound("morph");
                    game.player().pmid = target;
                    game.player().emit_text(ObjectDef::get(target).name + "!", ID_FX_SLOW_TEXT);
                    game.player().action = ACT_JUMP;
                    game.cast_fx(8, 0, 0, x, y, 24, 24, 0, -1, 4);
                    game.time_left = ObjectDef::get(target).life;
                    game.cast_objects(ID_FX_SPARKLE, 5, 0, 0, 0, rect());
                    kill();
                }
            }
            break;
        }
    }
}
