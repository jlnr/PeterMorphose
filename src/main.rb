if RUBY_VERSION < '1.9' then
  require 'rubygems'
  require 'require_relative'
end

require 'gosu'
require_relative 'gosu-preview' # upcoming Gosu 0.8 interface wrapper

# TODO More Objects
# TODO Game Logic
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

def debug binding
  require 'pry'
  Pry.start binding
end

# For resource loading.
Dir.chdir File.expand_path("#{__FILE__}/../..")

%w(const helpers/graphics helpers/audio helpers/input
   states/state states/title states/menu states/level_selection states/game
   objects/object_def objects/game_object objects/living_object objects/collectible_object
   ini_file level_info map).each { |fn| require_relative fn }

# Not yet part of gosu-preview
Gosu::enable_undocumented_retrofication rescue nil

WIDTH, HEIGHT = 640, 480

# Simple implementation of the Gosu "State-Based" game pattern
class Window < Gosu::Window
  def initialize
    super WIDTH*3/2, HEIGHT*3/2, :update_interval => 33.33
    
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
