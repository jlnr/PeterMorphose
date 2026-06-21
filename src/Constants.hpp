#pragma once

#include <cstdint>

const int TILES_X = 24;
const int TILES_Y = 1024;
const int TILE_SIZE = 24;
const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int TARGET_FPS = 30;

/// An object ID for anything in Peter Morphose.
enum PMID : std::uint8_t
{
    // 00 - 04 = Peter and special morphed versions
    ID_PLAYER = 0x00,
    ID_PLAYER_FIGHTER = 0x01,
    ID_PLAYER_GUN = 0x02,
    ID_PLAYER_BERSERKER = 0x03,
    ID_PLAYER_BOMBER = 0x04,
    ID_PLAYER_MAX = 0x04,
    // 05 - 09 = enemies
    ID_ENEMY = 0x05,
    ID_ENEMY_FIGHTER = 0x06,
    ID_ENEMY_GUN = 0x07,
    ID_ENEMY_BERSERKER = 0x08,
    ID_ENEMY_BOMBER = 0x09,
    ID_ENEMY_MAX = 0x09,
    ID_LIVING_MAX = 0x09,
    // 10 - 1F = other objects
    ID_OTHER_OBJECTS_MIN = 0x10,
    ID_FIREWALL_1 = 0x10,
    ID_FIREWALL_2 = 0x11,
    ID_FIRE = 0x12,
    ID_HELP_ARROW = 0x13,
    ID_FISH = 0x14,
    ID_FISH_2 = 0x15,
    ID_TRASH_IDLE = 0x16,
    ID_FUSING_BOMB = 0x17,
    ID_TRASH = 0x18,
    ID_TRASH_2 = 0x19,
    ID_TRASH_3 = 0x1A,
    ID_TRASH_4 = 0x1B,
    ID_LEVER_DOWN = 0x1C,
    ID_LEVER = 0x1D,
    ID_LEVER_LEFT = 0x1E,
    ID_LEVER_RIGHT = 0x1F,
    ID_OTHER_OBJECTS_MAX = 0x1F,
    // 20 - 3F = collectibles
    ID_COLLECTIBLE_MIN = 0x20,
    ID_KEY = 0x20,
    ID_HEALTH = 0x21,
    ID_HEALTH_2 = 0x22,
    ID_STAR = 0x23,
    ID_STAR_2 = 0x24,
    ID_STAR_3 = 0x25,
    ID_POINTS = 0x26,
    ID_POINTS_MAX = 0x2B,
    ID_CAROLIN = 0x2C,
    ID_SPEED = 0x2D,
    ID_JUMP = 0x2E,
    ID_FLY = 0x2F,
    ID_MORPH_FIGHTER = 0x38,
    ID_MORPH_MAX = 0x3B,
    ID_MUNITION_MIN = 0x3C,
    ID_MUNITION_MAX = 0x3F,
    ID_COLLECTIBLE_MAX = 0x3F,
    // 40 - 53 = effects
    ID_FX_MIN = 0x40,
    ID_FX_SMOKE = 0x40,
    ID_FX_FLAME = 0x41,
    ID_FX_SPARK = 0x42,
    ID_FX_BUBBLE = 0x43,
    ID_FX_RICOCHET = 0x44,
    ID_FX_LINE = 0x45,
    ID_FX_BLOCKER_PARTS = 0x46,
    ID_FX_BREAK = 0x47,
    ID_FX_BREAK_2 = 0x48,
    ID_FX_BREAKING_PARTS = 0x49,
    ID_FX_BLOOD = 0x4A,
    ID_FX_FIRE = 0x4B,
    ID_FX_FLYING_CAROLIN = 0x4C,
    ID_FX_FLYING_CHAIN = 0x4D,
    ID_FX_FLYING_BLOB = 0x4E,
    ID_FX_TEXT = 0x4F,
    ID_FX_SLOW_TEXT = 0x50,
    ID_FX_WATER_BUBBLE = 0x51,
    ID_FX_WATER = 0x52,
    ID_FX_SPARKLE = 0x53,
    ID_FX_MAX = 0x53,

    ID_MAX = 0x53
};
