WIDTH, HEIGHT = 640, 480
TARGET_FPS = 30

# Z Order
Z_EFFECTS, Z_LAVA, Z_UI, Z_TEXT = *0..255

# Simple implementation of the Gosu "State-Based" game pattern
class Window < Gosu::Window
  def initialize(*args)
    super
    
    self.caption = 'Peter Morphose'
    
    if ARGV[0] then
      State.current = Game.new LevelInfo.new(ARGV[0])
    else
      State.current = Title.new
    end
  end
  
  def update
    if State.current then
      State.current.update
    else
      close
    end
  end
  
  def draw
    State.current.draw if State.current
  end
  
  def button_down id
    State.current.button_down id if State.current
  end
  
  def button_up id
    State.current.button_up id if State.current
  end
  
  def needs_cursor?
    State.current.needs_cursor? if State.current
  end
end
