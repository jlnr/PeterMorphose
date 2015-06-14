# Encoding: UTF-8

def font
  $PM_FONT ||= begin
    font = Gosu::Font.new(16)
    # Cache some often used glyphs
    common_symbols = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a + %w(Ä Ö Ü ä ö ü ß)
    font.text_width common_symbols.join
    font
   end
end

def draw_string string, x, y, a = 255
  font.draw string, x, y, Z_TEXT, 1, 1, alpha(a)
end

def draw_centered_string string, x, y, a = 255
  font.draw_rel string, x, y, Z_TEXT, 0.5, 0.0, 1, 1, alpha(a)
end

def draw_right_aligned_string string, x, y, a = 255
  font.draw_rel string, x, y, Z_TEXT, 1, 0.0, 1, 1, alpha(a)
end

def draw_rect x, y, w, h, color, z = 0
  Gosu::draw_quad x, y, color, x + w, y, color,
    x, y + h, color, x + w, y + h, color, z
end

def alpha n
  n << 24 | 0xffffff
end
