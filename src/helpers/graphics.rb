def draw_string string, x, y, z = 0, alpha = 255
  # TODO Hackish...
  @font ||= Gosu::Font.new(16)
  if x == :center then
    @font.draw_rel string, WIDTH / 2, y, z, 0.5, 0.0
  else
    @font.draw string, x, y, z
  end
end

def draw_rect x, y, w, h, color, z = 0
  Gosu::draw_quad x, y, color, x + w, y, color,
    x, y + h, color, x + w, y + h, color, z
end
