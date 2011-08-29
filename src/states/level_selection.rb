# Encoding: UTF-8

class LevelSelection < State
  LEVELS_ON_SCREEN = 4
  
  def initialize
    @@title  ||= Gosu::Image.new 'media/title_dark.png'
    @@ls_top ||= 0
    @@ls_sel ||= 0
    @@levels ||= Dir.glob('levels/*.pml').map(&LevelInfo.method(:new)).sort
    
    song(:menu).play(true)
  end
  
  def draw
    @@title.draw 0, 0, 0
    draw_rect 631, 0, 1, 400, 0xff003010
    draw_rect 632, 0, 16, 400, 0xff004020
    LEVELS_ON_SCREEN.times do |y|
      break if y == @@levels.size
      @@levels[y + @@ls_top].draw y * 100, @@ls_top + y == @@ls_sel
    end
    if @@levels.size > LEVELS_ON_SCREEN then
      draw_string '|', 632, 384.0 * @@ls_top / (@@levels.size - LEVELS_ON_SCREEN)
    end
    draw_centered_string t('Wähle mit den Pfeiltasten ein Level aus und starte es mit Enter.'), WIDTH / 2, 434
    #draw_centered_string t('Willst du zurück zum Hauptmenü, drücke Escape.'), WIDTH / 2, 446
  end
  
  def button_down(id)
    if menu_cancel? id then
      State.current = nil#Menu.new
    elsif menu_prev? id then
      @@ls_sel -= 1 if @@ls_sel > 0
      @@ls_top -= 1 if @@ls_sel < @@ls_top
    elsif menu_next? id then
      @@ls_sel += 1 if @@ls_sel < @@levels.size - 1
      @@ls_top += 1 if @@ls_sel >= @@ls_top + LEVELS_ON_SCREEN
    elsif menu_confirm? id then
      State.current = Game.new(@@levels[@@ls_sel])
    end
  end
end
