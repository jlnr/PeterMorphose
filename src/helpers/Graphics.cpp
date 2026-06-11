#include "Graphics.hpp"

const Gosu::Font& font()
{
    static const Gosu::Font font(16);
    return font;
}

void draw_string(const std::string& string, double x, double y, Gosu::Color::Channel alpha)
{
    font().draw_text(string, x, y, Z_TEXT, 1, 1, Gosu::Color::WHITE.with_alpha(alpha));
}

void draw_centered_string(const std::string& string, double x, double y, Gosu::Color::Channel alpha)
{
    font().draw_text_rel(string, x, y, Z_TEXT, 0.5, 0.0, 1, 1,
                         Gosu::Color::WHITE.with_alpha(alpha));
}

void draw_right_aligned_string(const std::string& string, double x, double y,
                               Gosu::Color::Channel alpha)
{
    font().draw_text_rel(string, x, y, Z_TEXT, 1.0, 0.0, 1, 1,
                         Gosu::Color::WHITE.with_alpha(alpha));
}
