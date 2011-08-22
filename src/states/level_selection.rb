# Encoding: UTF-8

class LevelSelection < State
  LEVELS_ON_SCREEN = 4
  
  def initialize
    @title = Gosu::Image.new 'media/title_dark.png'
    @top = 0
    @selection = 0
    @levels = Dir.glob('levels/*.pml').map(&LevelInfo.method(:new)).sort
  end
  
  def draw
    @title.draw 0, 0, 0
    draw_rect 631, 0, 1, 400, 0xff003010
    draw_rect 632, 0, 16, 400, 0xff004020
    LEVELS_ON_SCREEN.times do |y|
      break if y == @levels.size
      @levels[y + @top].draw y * 100, @top + y == @selection
    end
    if @levels.size > LEVELS_ON_SCREEN then
      draw_string '|', 632, 384.0 * @top / (@levels.size - LEVELS_ON_SCREEN)
    end
    draw_centered_string 'Wähle mit den Pfeiltasten ein Level aus und starte es mit Enter.', WIDTH / 2, 424
    draw_centered_string 'Willst du zurück zum Hauptmenü, drücke Escape.', WIDTH / 2, 446
  end
  
  def button_down(id)
    if menu_cancel? id then
      State.current = Menu.new
    elsif menu_prev? id then
      @selection -= 1 if @selection > 0
      @top -= 1 if @selection < @top
    elsif menu_next? id then
      @selection += 1 if @selection < @levels.size - 1
      @top += 1 if @selection >= @top + LEVELS_ON_SCREEN
    elsif menu_confirm? id then
      State.current = Game.new(@levels[@selection])
    end
  end
end
