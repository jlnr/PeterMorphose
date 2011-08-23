class EffectObject < GameObject
  def initialize *args
    super
    
    @phase = 0
  end
  
  def self.images
    @images ||= Gosu::Image.load_tiles 'media/effects.bmp', -7, -7
  end
  
  def draw
    case pmid
    when ID_FX_SMOKE then
      EffectObject.images[[ 0, @phase -  1].max].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(128), :additive
    when ID_FX_FLAME then
      EffectObject.images[[ 7, @phase +  6].max].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(160), :additive
    when ID_FX_SPARK then
      EffectObject.images[[14, @phase + 13].max].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(128), :additive
    when ID_FX_BUBBLE then
      EffectObject.images[[21, @phase + 20].max].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(192), :additive
    when ID_FX_RICOCHET then
      EffectObject.images[19 + xdata.to_i].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha([255 - @phase * 3, 0].max)
    when ID_FX_LINE then
      EffectObject.images[28].draw x, y - 11 - game.view_pos, Z_EFFECTS, xdata.to_f / EffectObject.images.first.width, 1, alpha(255 - @phase), :additive
    when ID_FX_BLOCKER_PARTS then
      EffectObject.images[29].draw_rot x, y - game.view_pos, Z_EFFECTS, x * 10, 0.5, 0.5, 1, 1, alpha(255 - @phase), :additive
    when ID_FX_BREAK, ID_FX_BREAK_2 then
      EffectObject.images[30 + (ID_FX_BREAK_2 - pmid)].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(@phase) # TODO :subtractive
    when ID_FX_BREAKING_PARTS then
      EffectObject.images[32].draw_rot x, y - game.view_pos, Z_EFFECTS, x * 10, 0.5, 0.5, 1, 1, alpha(255 - @phase)
    when ID_FX_BLOOD then
      EffectObject.images[33].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(250 - @phase)
    when ID_FX_FIRE then
      EffectObject.images[34].draw x, y - game.view_pos, Z_EFFECTS, 1, 1, alpha(@phase)
    when ID_FX_FLYING_CAROLIN then
      EffectObject.images[35].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS
    when ID_FX_FLYING_CHAIN then
      EffectObject.images[36].draw_rot x, y - game.view_pos, Z_EFFECTS, x * 10 % 360, 0.5, 0.5, 1, 1, alpha(255 - @phase)
    when ID_FX_FLYING_BLOB then
      EffectObject.images[37].draw_rot x, y - game.view_pos, Z_EFFECTS, x * 10, 0.5, 0.5, 1, 1, alpha(255 - @phase)
    when ID_FX_WATER_BUBBLE then
      EffectObject.images[46].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(100 + rand(29))
    when ID_FX_WATER then
      EffectObject.images[47].draw_rot x, y - game.view_pos, Z_EFFECTS, x * 10, 0.5, 0.5, 1, 1, alpha(255 - @phase)
    when ID_FX_SPARKLE then
      EffectObject.images[48].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(255 - @phase), :additive
    when ID_FX_TEXT, ID_FX_SLOW_TEXT then
      # TODO: Force text inside portion @ x=0..576
      draw_centered_string xdata, x, y - 7 - game.view_pos, 255 - @phase
    end
  end
  
  def update
    case pmid
    when ID_FX_SMOKE, ID_FX_FLAME then
      self.x += vx
      self.y += vy
      @phase += 1
      kill if @phase > 7
    when ID_FX_SPARK then
      self.x += vx
      self.y += vy
      @phase += 1 if game.frame % 3 == 0
      kill if @phase > 5
    when ID_FX_BUBBLE then
      self.x += vx
      self.y = game.map.lava_pos - 12
      @phase += 1 if game.frame % 2 == 0
      kill if @phase > 7
    when ID_FX_BLOCKER_PARTS then
      self.x += vx
      self.y += vy
      self.vy += 1
      @phase += 15
      kill if @phase == 255
    when ID_FX_WATER then
      self.x += vx
      self.vy += 1
      self.y += vy
      @phase += 25
      kill if @phase == 250
    when ID_FX_BREAK, ID_FX_BREAK_2 then
      @phase += 15
      if @phase == 255 then
        game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_HOLE + ((y / TILE_SIZE % 2 + x / TILE_SIZE) % 2) * 16
        game.cast_objects ID_FX_BREAKING_PARTS, 20, 0, 5, 2,
          ObjectDef::Rect.new(x / (TILE_SIZE/2) * (TILE_SIZE/2), y / (TILE_SIZE/2) * (TILE_SIZE/2), 24, 24)
        emit_sound "break#{rand(2) + 1}"
        kill
        return
      end
    when ID_FX_FIRE then
      @phase += 15
      if @phase == 255 then
        game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_BIG_BLOCKER_BROKEN
        game.explosion x + 12, y + 12, 30, true
        kill
      end
    when ID_FX_BREAKING_PARTS, ID_FX_TEXT, ID_FX_RICOCHET, ID_FX_LINE,
        ID_FX_BLOOD, ID_FX_FLYING_CHAIN, ID_FX_FLYING_BLOB, ID_FX_SLOW_TEXT then
      self.x += vx
      self.y += vy
      @phase += 15
      @phase -= 10 if pmid == ID_FX_SLOW_TEXT
      kill if @phase == 255
    when ID_FX_FLYING_CAROLIN then
      self.x += vx
      self.y += vy
      kill if y < game.view_pos - HEIGHT
    when ID_FX_WATER_BUBBLE then
      self.y -= 1
      self.x += 1 - rand(3) if rand(4) == 0
      kill if not in_water?
    when ID_FX_SPARKLE then
      @phase += 25
      kill if @phase == 250
    end
  end
end
