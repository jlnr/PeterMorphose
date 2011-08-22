def font
  @font ||= Gosu::Font.new(16)
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
