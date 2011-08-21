require 'state'

class Title < State
  def initialize
    @title = Gosu::Image.new 'media/title.png'
  end
  
  def draw
    @title.draw 0, 0, 0
  end
end
