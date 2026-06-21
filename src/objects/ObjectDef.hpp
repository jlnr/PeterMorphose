#pragma once

#include "Constants.hpp"
#include "helpers/Rect.hpp"
#include <string>

/// Immutable per-object-type definition loaded once from objects.ini.
struct ObjectDef {
    std::string name = "<no name>";
    int life = 3;
    Rect rect;
    int speed = 3;
    int jump_x = 0;
    int jump_y = 0;

    /// Returns the definition for the given ID (0..ID_MAX). Lazy-loads objects.ini on first use.
    static const ObjectDef& get(PMID pmid);
};
