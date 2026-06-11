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

const Gosu::Font& font();
void draw_string(const std::string& string, double x, double y, Gosu::Color::Channel alpha = 255);
void draw_centered_string(const std::string& string, double x, double y,
                          Gosu::Color::Channel alpha = 255);
void draw_right_aligned_string(const std::string& string, double x, double y,
                               Gosu::Color::Channel alpha = 255);
