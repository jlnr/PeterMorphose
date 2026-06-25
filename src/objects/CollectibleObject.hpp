#pragma once

#include "objects/GameObject.hpp"
#include <string>
#include <utility>

/// Objects the player can touch to collect them: keys, stars, ...
/// Modeled after the original Delphi class TPMCollectible.
class CollectibleObject : public GameObject
{
public:
    CollectibleObject(GameState& game, std::string extra_data, PMID pmid, //
                      int x, int y, int vx, int vy);

    void update() override;
};
