def draw_string string, x, y, alpha = 255
  # TODO Hackish...
  # TODO ZOrder
  @font ||= Gosu::Font.new(16)
  if x == :center then
    @font.draw_rel string, WIDTH / 2, y, 255, 0.5, 0.0,
      1, 1, alpha << 24 | 0xffffff
  else
    @font.draw string, x, y, 255,
      1, 1, alpha << 24 | 0xffffff
  end
end

def draw_rect x, y, w, h, color, z = 0
  Gosu::draw_quad x, y, color, x + w, y, color,
    x, y + h, color, x + w, y + h, color, z
end

def alpha n
  n << 24 | 0xffffff
end
