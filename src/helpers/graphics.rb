def draw_string string, x, y, z = 0, alpha = 255
  # TODO Hackish...
  @font ||= Gosu::Font.new(16)
  @font.draw string, x, y, z
end