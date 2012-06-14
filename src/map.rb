class Map
  class OverriddenTile < Struct.new(:to_blob)
    def columns; TILE_SIZE; end
    def rows; TILE_SIZE; end
  end
  
  attr_reader :level_top, :level_bottom
  attr_reader :scripts, :timers, :vars
  attr_accessor :lava_pos, :lava_time_left, :lava_mode, :lava_speed, :lava_frame
  
  def inspect
    "#<Map>"
  end

  def initialize game, ini_file
    @@tiles ||= Gosu::Image.load_tiles 'media/tiles.bmp', -16, -16
    @@skies ||= Gosu::Image.load_tiles 'media/skies.png', -4, -2
    
    @game = game
    @tiles = []
    @scripts = []
    @timers = []
    @vars = [0] * 16
    
    (0...TILES_Y).each do |y|
      row = ini_file['Map', y] || '00' * TILES_X
      (0...TILES_X).each do |x|
        self[x, y] = row[x * 2, 2].to_i(16)
      end
      @scripts[y] = ini_file['Scripts', y]
    end
    
    SCRIPT_TIMERS.times do |i|
      @timers << ini_file['Scripts', "Timer#{i}"]
    end
    
    @sky = (ini_file['Map', 'Sky'] || 0).to_i
    
    @lava_frame = @lava_time_left = 0
    @lava_speed = (ini_file['Map', 'LavaSpeed'] || 1).to_i
    @lava_mode  = (ini_file['Map', 'LavaMode']  || 0).to_i
    @lava_pos   = (ini_file['Map', 'LavaPos']   || TILES_Y).to_i * TILE_SIZE
    @lava_score = (ini_file['Map', 'LavaScore'] || 1).to_i
    @level_top  = (ini_file['Map', 'LevelTop']  || 0).to_i * TILE_SIZE
    @level_bottom = [1024, @lava_pos / TILE_SIZE].min
    
    # Overloaded map tiles
    @tile_images = []
    @@tiles.each_with_index do |original_tile, index|
      if (override = ini_file['Tiles', '%02X' % index]) and override.length == 3456 then
        data = "\0\0\0\0" * (TILE_SIZE * TILE_SIZE)
        
        (TILE_SIZE * TILE_SIZE).times do |i|
          inv_x = i % TILE_SIZE
          inv_y = i / TILE_SIZE
          src_i = inv_x * TILE_SIZE + inv_y
          rrggbb = override[src_i * 6, 6]
          if rrggbb != 'FF00FF' then
            data[i * 4 + 0] = rrggbb[0, 2].to_i(16).chr
            data[i * 4 + 1] = rrggbb[2, 2].to_i(16).chr
            data[i * 4 + 2] = rrggbb[4, 2].to_i(16).chr
            data[i * 4 + 3] = "\xff"
          end
        end
        
        @tile_images[index] = Gosu::Image.new(OverriddenTile.new(data))
      else
        @tile_images[index] = original_tile
      end
    end
  end
  
  def [](x, y)
    # Check for y is implicit in the ||
    return 0x70 if x < 0 or x >= TILES_X
    @tiles[y * TILES_X + x] || 0x70
  end
  
  def []=(x, y, tile)
    @map_image = nil
    if x.between? 0, TILES_X - 1 and y.between? 0, TILES_Y - 1 then
      @tiles[y * TILES_X + x] = tile
    end
  end
  
  def solid? x, y
    y > @lava_pos or self[x / TILE_SIZE, y / TILE_SIZE].between? 0x70, 0xe0
  end
  
  ALL_STAIRS_UP   = [TILE_STAIRS_UP,   TILE_STAIRS_UP_2]
  ALL_STAIRS_DOWN = [TILE_STAIRS_DOWN, TILE_STAIRS_DOWN_2]
  
  def stairs_passable? x, y
    if ALL_STAIRS_DOWN.include? self[x, y] then
      loop do
        y += 1
        return false if y >= TILES_Y
        return true if ALL_STAIRS_UP.include? self[x, y]
      end
    else
      loop do
        y -= 1
        return false if y < 0
        return true if ALL_STAIRS_DOWN.include? self[x, y]
      end
    end
  end
  
  def draw
    @map_image ||= $window.record(TILES_X * TILE_SIZE, TILES_Y * TILE_SIZE) { render_map }
    @sky_image ||= $window.record(TILES_X * TILE_SIZE, HEIGHT) { render_sky }
    
    if @sky == 0 then
      @sky_image.draw 0, 0, 0
    else
      @sky_image.draw 0, 120 - @game.view_pos % 120, 0
    end
    
    @map_image.draw 0, -@game.view_pos, 0
  end
  
  private
  
  def render_sky
    5.times do |y|
      4.times do |x|
        @@skies[@sky].draw x * 144, y * 120 - @game.view_pos % 120, 0
      end
    end
  end
  
  def render_map
    (@level_top / TILE_SIZE).upto(TILES_Y - 1).each do |y|
      TILES_X.times do |x|
        index = self[x, y]
        @tile_images[index].draw x * TILE_SIZE, y * TILE_SIZE, 0 if index and index > 0
      end
    end
  end
end
