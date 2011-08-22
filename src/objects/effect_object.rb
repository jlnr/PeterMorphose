class EffectObject < GameObject
  def initialize *args
    super
    
    @phase = 0
  end
  
  def draw
    @@effect_images ||= Gosu::Image.load_tiles 'media/effects.bmp', -7, -7
    case pmid
    when ID_FX_SMOKE then
      @@effect_images[[ 0, @phase -  1].max].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(128), :additive
    when ID_FX_FLAME then
      @@effect_images[[ 7, @phase +  6].max].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(160), :additive
    when ID_FX_SPARK then
      @@effect_images[[14, @phase + 13].max].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(128), :additive
      # ID_FXBubble:
      #   Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), Max(21, Phase + 20), 192);
      # ID_FXRicochet:
      #   Data.Images[Image_Effects].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 19 + StrToInt(ExtraData), Min((255 - Phase) * 3, 255));
      # ID_FXLine:
      #   Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX, PosY - 11 - Data.ViewPos, StrToInt(ExtraData), 24), 28, 255 - Phase);
      # ID_FXBlockerParts:
      #   Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 29, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
    when ID_FX_BREAK, ID_FX_BREAK_2 then
      @@effect_images[30 + (ID_FX_BREAK_2 - pmid)].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(@phase) # TODO :subtractive
      # ID_FXBreakingParts:
      #   Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 32, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
      # ID_FXBlood:
      #   Data.Images[Image_Effects].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 33, 250 - Phase);
      # ID_FXFire:
      #   Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX, PosY - Data.ViewPos, 24, 24), 34, Phase);
    when ID_FX_FLYING_CAROLIN then
      @@effect_images[35].draw x, y - game.view_pos, Z_EFFECTS
    when ID_FX_FLYING_CHAIN then
      @@effect_images[36].draw_rot x, y - game.view_pos, Z_EFFECTS, x * 10 % 360, 0.5, 0.5, 1, 1, alpha(255 - @phase)
      # ID_FXFlyingBlob:
      #   Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 37, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
      # ID_FXWaterBubble:
      #   Data.Images[Image_Effects].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 46, 100 + Random(29));
      # ID_FXWater:
      #   Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 47, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
    when ID_FX_SPARKLE then
      @@effect_images[48].draw x - 11, y - 11 - game.view_pos, Z_EFFECTS, 1, 1, alpha(255 - @phase), :additive
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
    # ID_FXSpark: begin
    #   Inc(PosX, VelX);
    #   Inc(PosY, VelY);
    #   if Data.Frame mod 3 = 0 then Inc(Phase);
    #   if Phase > 5 then begin Kill; Exit; end;
    # end;
    # ID_FXBubble: begin
    #   Inc(PosX, VelX);
    #   PosY := Data.Map.LavaPos - 12;
    #   if Data.Frame mod 2 = 0 then Inc(Phase);
    #   if Phase > 7 then begin Kill; Exit; end;
    # end;
    # ID_FXBlockerParts: begin
    #   Inc(PosX, VelX);
    #   Inc(PosY, VelY);
    #   Inc(VelY);
    #   Inc(Phase, 15);
    #   if Phase = 255 then begin Kill; Exit; end;
    # end;
    # ID_FXWater: begin
    #   Inc(PosX, VelX);
    #   Inc(VelY);
    #   Inc(PosY, VelY);
    #   Inc(Phase, 25);
    #   if Phase = 250 then begin Kill; Exit; end;
    # end;
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
    # ID_FXFire: begin
    #   Inc(Phase, 15);
    #   if Phase = 255 then begin
    #     Data.Map.Tiles[PosX div 24, PosY div 24] := Tile_BigBlockerBroken;
    #     Explosion(PosX + 12, PosY + 12, 30, Data^, True);
    #     Kill; Exit;
    #   end;
    # end;
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
    # ID_FXWaterBubble: begin
    #   Dec(PosY);
    #   if Random(4) = 0 then PosX := PosX - 1 + Random(3);
    #   if not InWater then Kill;
    # end;
  when ID_FX_SPARKLE then
    @phase += 25
    kill if @phase == 250
    end
  end
end
