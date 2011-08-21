class Map
  def initialize game, ini_file
    @@tiles ||= Gosu::Image.load_tiles 'media/tiles.bmp', -16, -16
    
    @game = game
    @tiles = []
    @scripts = []
    @timers = []
    @vars = []
    #@lava_frame = @lava_time_left = @lava_score = 0
    #Sky, LavaSpeed, LavaMode, LevelTop: Integer;
    
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
    
    @stars_goal = (ini_file['Map', 'StarsGoal'] || 100).to_i
    @sky = (ini_file['Map', 'Sky'] || 0).to_i
    @lava_speed = (ini_file['Map', 'LavaSpeed'] || 1).to_i
    @lava_mode = (ini_file['Map', 'LavaMode'] || 0).to_i
    @lava_pos = (ini_file['Map', 'LavaPos'] || TILES_Y).to_i * TILE_SIZE
    @lava_score = (ini_file['Map', 'LavaScore'] || 1).to_i
    @level_top = (ini_file['Map', 'LevelTop'] || 0).to_i * TILE_SIZE
    @level_bottom = [1024, @lava_pos / TILE_SIZE].min
  end
  
  def [](x, y)
    return @tiles[y * TILES_X + x]
  end
  
  def []=(x, y, tile)
    if (0...TILES_X).include? x and (0...TILES_Y).include? y then
      @tiles[y * TILES_X + x] = tile
    end
  end
  
  def solid? x, y
    y > @lava_pos or (0x70...0xe0).include? self[x / TILE_SIZE, y / TILE_SIZE]
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
    offset = @game.view_pos % TILE_SIZE
    row = @game.view_pos / TILE_SIZE
    (HEIGHT / TILE_SIZE + 1).times do |y|
      TILES_X.times do |x|
        @@tiles[self[x, row + y] || 0].draw x * TILE_SIZE, y * TILE_SIZE - offset, 0
      end
    end
  end
end
