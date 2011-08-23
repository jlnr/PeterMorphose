class Title < State
  def initialize
    @title = Gosu::Image.new 'media/title.png'
    song(:menu).play
  end
  
  def draw
    @title.draw 0, 0, 0
  end
  
  def button_down id
    if menu_confirm? id or menu_cancel? id then
      sound(:whoosh).play
      State.current = LevelSelection.new#Menu.new
    end
  end
end
