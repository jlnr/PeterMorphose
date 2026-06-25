#pragma once

#include "objects/GameObject.hpp"
#include <optional>

/// Subclass for living objects: Peter Morphose and his enemies.
/// Modeled after the original Delphi class TPMLiving.
class LivingObject : public GameObject
{
public:
    int life;
    Action action;
    Direction direction;

    LivingObject(GameState& game, std::string extra_data, PMID pmid, int x, int y, int vx, int vy,
                 int life, Action action, Direction direction);

    void update() override;
    void draw() override;

    /// True if the object can perform an action (standing on ground, not doing anything).
    bool busy() const;

    void jump();

    /// Takes one point of damage.
    void hit();
    /// Takes damage, depends on what kind of damage and applied to whom.
    void hurt(bool from_explosion);

    /// Uses the tile the object stands on (stairs...) or uses a lever.
    void use_tile();
    /// Lets a special Peter attack.
    void special_action();

private:
    /// The lever the object can currently reach (behind/around it), or nullptr.
    GameObject* can_reach_lever() const;
    /// Flips a reachable lever: toggles its direction and applies its tile changes.
    void flip_lever();
    /// Breaks a fragile bridge tile at the given pixel position, if there is one.
    void break_floor(int x, int y);
};
