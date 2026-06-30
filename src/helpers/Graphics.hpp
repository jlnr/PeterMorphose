#pragma once

#include "Constants.hpp"
#include <Gosu/Gosu.hpp>
#include <string>

enum ZOrder
{
    Z_EFFECTS,
    Z_LAVA,
    Z_UI,
    Z_TEXT
};

int bmp_text_width(std::string string);
void draw_bmp_text(std::string string, double x, double y, //
                   Gosu::Color::Channel alpha = 255, Gosu::Alignment = Gosu::AL_LEFT);

const Gosu::Image& tile_image(Tile tile);
const Gosu::Image& player_image(PMID pmid, Direction direction, Action action);
const Gosu::Image& enemy_image(PMID pmid, Direction direction, Action action);
const Gosu::Image& object_image(PMID pmid);
const Gosu::Image& effect_image(int index);
