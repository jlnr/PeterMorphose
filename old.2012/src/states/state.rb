class State
  class << self
    attr_accessor :current
  end
  
  def update; end
  def draw; end
  def button_down id; end
  def button_up id; end
  def needs_cursor?; end
end
