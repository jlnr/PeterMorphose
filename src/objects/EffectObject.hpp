#pragma once

#include "objects/GameObject.hpp"
#include <string>
#include <utility>

/// "Effect objects" are basically particles in a particle engine. They never interact with the map
/// or other objects.
/// Modeled after the original TPMEffect.
class EffectObject : public GameObject
{
public:
    EffectObject(GameState& game, std::string extra_data, PMID pmid, int x, int y, int vx, int vy);

    void update() override;
    void draw() override;

private:
    int m_phase = 0;
};
