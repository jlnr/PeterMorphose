#pragma once

#include "Constants.hpp"
#include "Gosu/Utility.hpp"
#include "helpers/Rect.hpp"
#include <string>

class GameState;

/// Base class for everything that lives in the game world: the player and enemies.
/// Modeled after the original Delphi class TPMObject.
class GameObject : Gosu::Noncopyable
{
public:
    GameState& game;
    PMID pmid;
    int x, y, vx, vy;
    std::string extra_data;
    bool last_frame_in_water;
    bool marked;

    GameObject(GameState& game, std::string extra_data, PMID pmid, int x, int y, int vx, int vy);
    virtual ~GameObject() = default;

    virtual void update();
    virtual void draw();

    /// Marks the object as "to be deleted" and unsets it from all PMScript variables.
    void kill();

    /// Creates a floating text effect above the object (e.g. "Schlüssel!", "+1").
    void emit_text(const std::string& text, PMID text_pmid = ID_FX_TEXT);

    /// Per-frame physics: gravity, water, friction...
    void fall();

    /// Adds a velocity impulse.
    /// @param fixed  Overwrites existing vx/vy.
    /// @param malign If true, this only affects the player.
    void fling(int h, int v, int randomness, bool fixed, bool malign);

    /// Is the map solid next to the object, in the given direction?
    bool blocked(Direction direction) const;

    bool rect_collides(const Rect& other) const { return rect().collide_with(other); }

    /// The hitbox width optional padding.
    Rect rect(int extra_width = 0, int extra_height = 0) const;

    bool stuck() const;

    bool in_water() const;
};
