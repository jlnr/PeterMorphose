require 'rubygems'
require 'gosu'

# TODO Game
# TODO Music
# TODO High Scores
# TODO Script
# TODO Remaining Menu
# TODO Proper scaling
# TODO Packaging as gem
# TODO Deployment tasks
# TODO "Gosu" splash screen
# TODO Support for editor quick-starting
# TODO Localization
# TODO Better resource handling

# What is a better way to do this?
File.dirname(File.dirname(__FILE__)).tap do |root|
  Dir.chdir root
  $LOAD_PATH << "#{root}/src"
end

require 'gosu-preview' # upcoming Gosu 0.8 interface wrapper
%w(const helpers/graphics helpers/audio helpers/input
   states/state states/title states/menu states/level_selection states/game
   ini_file level_info map).each &method(:require)

# Not yet part of gosu-preview
Gosu::enable_undocumented_retrofication rescue nil

WIDTH, HEIGHT = 640, 480

# Simple implementation of the Gosu "State-Based" pattern
class Window < Gosu::Window
  def initialize
    super WIDTH*3/2, HEIGHT*3/2
    
    self.caption = "Peter Morphose"
    
    State.current = Title.new
  end
  
  def update
    if State.current then
      State.current.update
    else
      close
    end
  end
  
  def draw
    scale(1.5) do
      State.current.draw if State.current
    end
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

Window.new.show
