#include "objects/CollectibleObject.hpp"
#include "Map.hpp"
#include "ObjectDef.hpp"
#include "helpers/Audio.hpp"
#include "objects/LivingObject.hpp"
#include "states/GameState.hpp"

CollectibleObject::CollectibleObject(GameState& game, std::string extra_data, PMID pmid, //
                                     int x, int y, int vx, int vy)
    : GameObject(game, std::move(extra_data), pmid, x, y, vx, vy)
{
}

void CollectibleObject::update()
{
    // The extra_data of a collectible object decides whether it is affected by gravity.
    if (pmid != ID_EDIBLE_FISH_LEFT && pmid != ID_EDIBLE_FISH_RIGHT //
        && extra_data.size() > 1 && extra_data[1] == '1') {
        fall();
        check_tile();
    }

    // Burn in lava.
    if (y + ObjectDef::get(pmid).rect.bottom() > game.map.lava_pos) {
        game.cast_fx(2, 2, 0, x, y, 16, 16, 0, -3, 1);
        kill();
        game.emit_sound(y, "Shshsh");
        if (pmid == ID_HOSTAGE) {
            game.lose("Du hast verloren, weil eine Gefangene verbrannt ist.");
        }
        return;
    }

    // Occasionally let the player hear this game's trademark HILFE scream.
    if (pmid == ID_HOSTAGE && game.frame % 20 == 0 && rand(4) == 0) {
        game.emit_sound(y, "Help");
    }

    // Edible fish swim in water, and fall out of it if their extra_data is set to allow gravity.
    if (pmid == ID_EDIBLE_FISH_LEFT || pmid == ID_EDIBLE_FISH_RIGHT) {
        if (!in_water()) {
            if (!extra_data.empty() && extra_data[0] == '1') {
                fall();
                check_tile();
            }
        }
        else if (pmid == ID_EDIBLE_FISH_LEFT) {
            x -= 2;
            if (blocked(DIR_LEFT)) {
                pmid = ID_EDIBLE_FISH_RIGHT;
            }
            if (rand(30) == 0) {
                game.create_object(ID_FX_WATER_BUBBLE, "", x, y - 3, 0, 0);
            }
        }
        else {
            x += 2;
            if (blocked(DIR_RIGHT)) {
                pmid = ID_EDIBLE_FISH_LEFT;
            }
            if (rand(30) == 0) {
                game.create_object(ID_FX_WATER_BUBBLE, "", x, y - 3, 0, 0);
            }
        }
    }

    // Get collected by the player.
    if (game.player().action < ACT_DEAD && rect_collides(game.player().rect(2, 2))) {
        switch (pmid) {
        case ID_HOSTAGE:
            game.cast_objects(ID_FX_FLYING_CHAIN, 8, 0, -1, 3, rect(1, -1));
            game.create_object(ID_FX_FLYING_HOSTAGE, "", x, y, -7 + rand(15), -15);
            play_sound("Jeepee");
            game.score += 100;
            kill();
            break;

        case ID_KEY:
            play_sound("KeyCollect");
            game.player().emit_text(ObjectDef::get(pmid).name + "!");
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            game.score += 2;
            game.keys += 1;
            kill();
            break;

        case ID_HEALTH:
        case ID_HEALTH_2: {
            int amount = (pmid == ID_HEALTH_2 ? 4 : 1);
            play_sound("HealthCollect");
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
            play_sound("StarCollect", Gosu::random(0.5, 0.7), Gosu::random(0.9, 1.1));
            game.score += 2;
            game.stars += 1;
            if (game.stars < game.stars_goal) {
                game.player().emit_text(std::to_string(game.stars) + " von "
                                        + std::to_string(game.stars_goal));
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
            play_sound("AmmoCollect");
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
            play_sound("AmmoCollect");
            game.player().emit_text("+" + std::to_string(amount));
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            game.score += amount;
            game.bombs += amount;
            kill();
            break;
        }

        case ID_EDIBLE_FISH_LEFT:
        case ID_EDIBLE_FISH_RIGHT:
            play_sound("HealthCollect");
            play_sound("Eat");
            game.player().emit_text("+1");
            game.score += 2;
            game.player().life += 1;
            kill();
            break;

        case ID_MORE_TIME:
        case ID_MORE_TIME_2:
            // Only useful while morphing.
            if (game.player().pmid != ID_PLAYER) {
                play_sound("Morph");
                game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
                if (pmid == ID_MORE_TIME) {
                    game.player().emit_text("+1 Sekunde");
                    game.score += 5;
                    game.time_left += 33;
                }
                else {
                    game.player().emit_text("+3,5 Sekunden");
                    game.score += 10;
                    game.time_left += 110;
                }
                kill();
            }
            break;

        case ID_COOKIE: {
            // The cookie's message is the second '|'-separated field of its extra_data.
            play_sound("Eat");
            game.cast_objects(ID_FX_SPARKLE, 1, 0, 0, 0, rect());
            if (extra_data.length() >= 2) {
                emit_text(extra_data.substr(2), ID_FX_SLOW_TEXT);
            }
            game.score += 10;
            kill();
            break;
        }

        case ID_SLOW_DOWN:
            // Nudge the lava back towards a slower setting.
            if (game.map.lava_mode == 0 && game.map.lava_speed == 48) {
                // One pixel of lava every 48 ticks is the minimum we allow -> don't collect.
                return;
            }
            if (game.map.lava_mode == 1 && game.map.lava_speed == 1) {
                // Drop from "1 pixel per 1 frame" to "1 pixel every 2 frames".
                game.map.lava_mode = 0;
                game.map.lava_speed = 2;
            }
            else if (game.map.lava_mode == 0) {
                game.map.lava_speed += 1;
            }
            else {
                game.map.lava_speed -= 1;
            }
            play_sound("FreezeCollect");
            game.player().emit_text("Lava verlangsamt!");
            game.cast_objects(ID_FX_SPARKLE, 3, 0, 0, 0, rect());
            kill();
            break;

        case ID_CRYSTAL:
            play_sound("FreezeCollect");
            game.player().emit_text("Lava angehalten!", ID_FX_SLOW_TEXT);
            game.map.lava_time_left += 80;
            game.cast_objects(ID_FX_SPARKLE, 4, 0, 0, 0, rect());
            kill();
            break;

        case ID_SEAMINE:
            game.explosion(x, y, 50, false);
            kill();
            break;

        case ID_SPEED:
        case ID_JUMP:
        case ID_FLY:
            play_sound("Morph");
            game.player().emit_text(ObjectDef::get(pmid).name + "!", ID_FX_SLOW_TEXT);
            if (pmid == ID_SPEED) {
                game.speed_time_left = 330;
            }
            else if (pmid == ID_JUMP) {
                game.jump_time_left = 330;
            }
            else {
                game.fly_time_left = 88;
            }
            game.cast_fx(8, 0, 0, game.player().x, game.player().y - 10, 24, 24, 0, -1, 4);
            game.cast_objects(ID_FX_SPARKLE, 2, 0, 0, 0, rect());
            kill();
            break;

        default:
            // The value of ID_POINTS_* is defined as their ObjectDef::life.
            if (between(pmid, ID_POINTS, ID_POINTS_MAX)) {
                play_sound("PointCollect");
                game.player().emit_text("*" + std::to_string(ObjectDef::get(pmid).life) + "*");
                game.cast_objects(ID_FX_SPARKLE, 3, 0, 0, 0, rect());
                game.score += ObjectDef::get(pmid).life;
                kill();
            }
            // Morph medals turn Peter into the corresponding special form.
            if (between(pmid, ID_MORPH_FIGHTER, ID_MORPH_MAX)) {
                PMID target = PMID(ID_PLAYER_FIGHTER + pmid - ID_MORPH_FIGHTER);
                if (game.player().pmid != target) {
                    play_sound("Morph");
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
