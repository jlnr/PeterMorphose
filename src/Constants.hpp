#pragma once

#include <Gosu/Math.hpp>
#include <cstdint>

const int TILES_X = 24;
const int TILES_Y = 1024;
const int TILE_SIZE = 24;
const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int TARGET_FPS = 30;

/// Actions (animation frames) for ID_PLAYER .. ID_LIVING_MAX.
enum Action
{
    /// Number of animation frames (not of actions).
    ACT_NUM = 20,

    ACT_STAND = 0,
    ACT_WALK_1 = 1,
    ACT_WALK_2 = 2,
    ACT_WALK_3 = 3,
    ACT_WALK_4 = 4,
    ACT_JUMP = 5,
    ACT_LAND = 6,
    ACT_IMPACT_1 = 7,
    ACT_IMPACT_2 = 8,
    ACT_IMPACT_3 = 9,
    ACT_IMPACT_4 = 10,
    ACT_IMPACT_5 = 11,
    ACT_ACTION_1 = 12,
    ACT_ACTION_2 = 13,
    ACT_ACTION_3 = 14,
    ACT_ACTION_4 = 15,
    ACT_ACTION_5 = 16,
    ACT_PAIN_1 = 17,
    ACT_PAIN_2 = 18,
    ACT_DEAD = 19,
    /// Going downstairs (invisible, no animation frame).
    ACT_INV_UP = 20,
    /// Going upstairs (invisible, no animation frame).
    ACT_INV_DOWN = 21,
};

/// The four cardinal directions.
enum Direction
{
    DIR_LEFT = 0,
    DIR_RIGHT = 1,
    DIR_UP = 2,
    DIR_DOWN = 3,
};

enum TileID : std::uint8_t
{
    // Special map tiles (solid, first row)
    TILE_ROCKET_UP = 0xC0,
    TILE_ROCKET_UP_LEFT = 0xC1,
    TILE_ROCKET_UP_RIGHT = 0xC2,
    TILE_ROCKET_UP_2 = 0xC3,
    TILE_ROCKET_UP_LEFT_2 = 0xC4,
    TILE_ROCKET_UP_RIGHT_2 = 0xC5,
    TILE_ROCKET_UP_3 = 0xC6,
    TILE_MORPH_FIGHTER = 0xC7,
    TILE_MORPH_GUN = 0xC8,
    TILE_MORPH_BERSERKER = 0xC9,
    TILE_MORPH_BOMB = 0xCA,
    TILE_MORPH_MAX = 0xCA,
    TILE_MORPH_EMPTY = 0xCB,
    TILE_CLOSED_DOOR = 0xCC,
    TILE_CLOSED_DOOR_2 = 0xCD,
    TILE_CLOSED_DOOR_3 = 0xCE,
    TILE_BIG_BLOCKER_3 = 0xCF,
    // Solid, second row
    TILE_BLOCKER = 0xD0,
    TILE_BLOCKER_2 = 0xD1,
    TILE_BLOCKER_3 = 0xD2,
    TILE_BIG_BLOCKER = 0xD3,
    TILE_BIG_BLOCKER_2 = 0xD4,
    TILE_ROCKET_UP_LEFT_3 = 0xD5,
    TILE_ROCKET_UP_RIGHT_3 = 0xD6,
    TILE_PULL_LEFT = 0xD7,
    TILE_PULL_RIGHT = 0xD8,
    TILE_SLIME = 0xD9,
    TILE_SLIME_2 = 0xDA,
    TILE_SLIME_3 = 0xDB,
    TILE_BRIDGE = 0xDC,
    TILE_BRIDGE_2 = 0xDD,
    TILE_BRIDGE_3 = 0xDE,
    TILE_BRIDGE_4 = 0xDF,
    // Background, first row
    TILE_AIR_ROCKET_UP = 0xE0,
    TILE_AIR_ROCKET_UP_LEFT = 0xE1,
    TILE_AIR_ROCKET_UP_RIGHT = 0xE2,
    TILE_AIR_ROCKET_LEFT = 0xE3,
    TILE_AIR_ROCKET_RIGHT = 0xE4,
    TILE_AIR_ROCKET_DOWN = 0xE5,
    TILE_WATER_5 = 0xE6,
    TILE_HOLE = 0xE7,
    TILE_WATER = 0xE8,
    TILE_WATER_2 = 0xE9,
    TILE_WATER_3 = 0xEA,
    TILE_WATER_4 = 0xEB,
    TILE_OPEN_DOOR = 0xEC,
    TILE_OPEN_DOOR_2 = 0xED,
    TILE_OPEN_DOOR_3 = 0xEE,
    TILE_SPIKES = 0xEF,
    // Background, second row
    TILE_BLOCKER_BROKEN = 0xF0,
    TILE_BLOCKER_3_BROKEN = 0xF1,
    TILE_BIG_BLOCKER_BROKEN = 0xF2,
    TILE_SLOW_ROCKET_UP = 0xF3,
    TILE_AIR_ROCKET_UP_2 = 0xF4,
    TILE_AIR_ROCKET_UP_3 = 0xF5,
    TILE_SPIKES_TOP = 0xF6,
    TILE_HOLE_2 = 0xF7,
    TILE_STAIRS_UP_LOCKED = 0xF8,
    TILE_STAIRS_UP = 0xF9,
    TILE_STAIRS_UP_2 = 0xFA,
    TILE_STAIRS_DOWN_LOCKED = 0xFB,
    TILE_STAIRS_DOWN = 0xFC,
    TILE_STAIRS_DOWN_2 = 0xFD,
    TILE_STAIRS_END = 0xFE,
    TILE_STAIRS_END_2 = 0xFF,
};

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
    ID_HOSTAGE = 0x2C,
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
    ID_FX_FLYING_HOSTAGE = 0x4C,
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

/// -1 for DIR_LEFT and +1 for DIR_RIGHT, like RealDir in Delphi.
inline int dir_to_vx(Direction direction)
{
    return direction == DIR_LEFT ? -1 : +1;
}

/// Random integer. Adding an overload to Gosu::random because would be a subtle breaking change.
inline int rand(int n)
{
    return static_cast<int>(Gosu::random(0, n));
}

/// Inclusive range check, like Comparable#between? in Ruby or the "in"-checks in Delphi.
inline bool between(int value, int min, int max)
{
    return value >= min && value <= max;
}
