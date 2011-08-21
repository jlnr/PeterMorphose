require 'rubygems'
require 'gosu'

# What is a better way to do this?
File.dirname(File.dirname(__FILE__)).tap do |root|
  Dir.chdir root
  $LOAD_PATH << "#{root}/src"
end

require 'new-gosu'
require 'const'
require 'title'

# Simple implementation of the Gosu "State-Based" pattern

class Window < Gosu::Window
  def initialize
    super 800, 600
    
    self.caption = "Peter Morphose"
    
    @state = Title.new
  end
  
  def update
    @state.update
  end
  
  def draw
    @state.draw
  end
  
  def button_down id
    @state.button_down id
  end
  
  def button_up id
    @state.button_up id
  end
end

Window.new.show
