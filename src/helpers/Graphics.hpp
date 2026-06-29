#pragma once

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
                   Gosu::Color::Channel alpha = 255, Gosu::Alignment alignment = Gosu::AL_LEFT);
