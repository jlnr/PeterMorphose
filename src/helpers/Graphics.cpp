#include "Graphics.hpp"
#include "String.hpp"
#include <vector>

static constexpr int LETTER_WIDTH = 8;
static constexpr int LETTER_SPACING = 9;
static constexpr int LINE_HEIGHT = 16;

int bmp_text_width(std::string string)
{
    utf8_to_latin1(string);
    return string.size() * LETTER_SPACING;
}

void draw_bmp_text(std::string string, double x, double y, Gosu::Color::Channel alpha,
                   Gosu::Alignment alignment)
{
    static const std::vector<Gosu::Image> images
        = Gosu::load_tiles("media/Font.png", LETTER_WIDTH, LINE_HEIGHT, Gosu::IF_RETRO);

    const Gosu::Color color = Gosu::Color::WHITE.with_alpha(alpha);

    utf8_to_latin1(string);
    if (alignment == Gosu::Alignment::AL_RIGHT) {
        x -= string.length() * LETTER_SPACING;
    }
    else if (alignment == Gosu::Alignment::AL_CENTER) {
        x -= string.length() * LETTER_SPACING / 2;
    }

    for (std::size_t i = 0; i < string.size(); ++i) {
        const auto code_point = static_cast<std::uint8_t>(string[i]);
        if (code_point >= 32) { // our font has glyphs for 32...255
            images.at(code_point - 32)
                .draw(x + i * LETTER_SPACING, y, Z_TEXT, 1, 1, color, Gosu::BM_ADD);
        }
    }
}
