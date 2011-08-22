# Encoding: UTF-8

class Menu < State
  ITEMS = 5
  
  def initialize
    @title = Gosu::Image.new 'media/title_dark.png'
    @buttons = Gosu::Image.load_tiles 'media/buttons.png', -2, -ITEMS
    @selection = 0
  end
  
  def draw
    @title.draw 0, 0, 0
    
    (0...ITEMS).each do |index|
      image_index = index * 2
      image_index += 1 if index == @selection
      @buttons[image_index].draw 120, 20 + 70 * index, 0
    end
    
    draw_string 'Wähle mit den Pfeiltasten aus, was du tun willst und drücke Enter.', :center, 435
  end
  
  def button_down id
    if menu_prev? id then
      @selection -= 1 if @selection > 0
    elsif menu_next? id then
      @selection += 1 if @selection < ITEMS - 1
    elsif menu_confirm? id
      sound(:whoosh).play
      case @selection
      when 0 then
        State.current = LevelSelection.new
      when 1 then
        State.current = Help.new
      when 2 then
        State.current = Options.new
      when 3 then
        State.current = Credits.new
      when 4 then
        State.current = nil
      end
    end
  end
end
