class Title < State
  def initialize
    @title = Gosu::Image.new 'media/title.png'
    song(:menu).play
  end
  
  def draw
    @title.draw 0, 0, 0
  end
  
  def button_down id
    sample(:whoosh).play
    State.current = Menu.new
  end
end
