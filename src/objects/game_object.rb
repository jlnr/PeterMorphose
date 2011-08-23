class GameObject
  attr_reader :game
  attr_accessor :pmid, :x, :y, :xdata, :vx, :vy
  
  def marked?
    @marked
  end
  
  def kill
    0.upto(game.obj_vars.size) do |i|
      game.obj_vars[i] = nil if game.obj_vars[i] == self
    end
    @marked = true
  end
  
  def emit_text string, speed = :fast
    if speed == :slow then id = ID_FX_SLOW_TEXT else id = ID_FX_TEXT end
    game.create_object(id, x, y - 10, string).vy = -1
  end
  
  def initialize game, pmid, x, y, xdata
    @game, @pmid, @x, @y, @xdata = game, pmid, x, y, xdata
    @vx = @vy = 0
    @last_frame_in_water = in_water?
  end
  
  def emit_sound name
    game.emit_sound name, y
  end
  
  ALL_WATER_TILES = (TILE_WATER..TILE_WATER_4).to_a + [TILE_WATER_5]
  def in_water?
    ALL_WATER_TILES.include? game.map[x / TILE_SIZE, y / TILE_SIZE]
  end
  
  def update
    if [ID_FIREWALL_1, ID_FIREWALL_2, ID_FIRE].include? pmid then
      if y + ObjectDef[pmid].rect.bottom - 11 > game.map.lava_pos then
        game.cast_fx 4, 4, 0, x, y, 16, 16, 0, -3, 1
        kill
        emit_sound(:shshsh)
      else
        self.xdata = ((game.frame * 7.5).to_i % 256 - 128).abs.to_s
        rect = self.rect
        game.objects.each do |obj|
          if obj.pmid <= ID_LIVING_MAX and obj.pmid != ID_ENEMY_BERSERKER and rect.include? obj then
            obj.hurt(false)
            game.cast_fx rand(3), rand(2), 0, x, y, 12, 12, 0, 0, 2
          end
        end
        return
      end
    end
    
    # Hint arrows
    kill if pmid == ID_HELP_ARROW and rect(10, 20).include? game.player
    
    # Fish
    if pmid == ID_FISH or pmid == ID_FISH_2 then
      if not in_water? then
        fall
        check_tile
      else
        if pmid == ID_FISH then
          self.x -= 2
          self.pmid = ID_FISH_2 if blocked? DIR_LEFT
        else
          self.x += 2
          self.pmid = ID_FISH if blocked? DIR_RIGHT
        end
        if rand(30) == 0 then
          game.create_object ID_FX_WATER_BUBBLE, x, y - 3, nil
        end
      end
    end
    
    # Fused bomb
    if pmid == ID_FUSING_BOMB then
      # Count up and possibly explode
      time = (xdata || 1).to_i + 1
      self.xdata = time.to_s
      if time >= 25 then
        kill
        game.explosion x, y, 50, true
        return
      end
      
      # Also explode on touching an enemy
      game.objects.each do |obj|
        if obj.pmid >= ID_ENEMY and obj.pmid <= ID_ENEMY_MAX and obj.collide_with? rect(1, 1) and
            not [ACT_DEAD, ACT_INV_UP, ACT_INV_UP].include? obj.action then
          obj.hurt true
          kill
          game.explosion x, y, 50, true
          return
        end
      end
      
      fall
      check_tile
    end
    
    # Rocks fall down
    if (ID_TRASH..ID_TRASH_4).include? pmid then
      fall
      check_tile
    end
    
    # Get roasted by lava
    if y + ObjectDef[pmid].rect.bottom > game.map.lava_pos then
      # TODO CastFX(4, 4, 0, PosX, PosY, 16, 16, 0, -3, 1, Data.OptEffects, Data.ObjEffects);
      kill
      emit_sound :shshsh
    end
  end
  
  def draw
    @@stuff_images ||= Gosu::Image.load_tiles 'media/stuff.bmp', -16, -3
    color = 0xffffffff
    mode = :default
    
    if [ID_FIREWALL_1, ID_FIREWALL_2, ID_FIRE].include? pmid then
      color = alpha(127 + (xdata && xdata.to_i || 128))
      mode = :additive
    elsif pmid == ID_HELP_ARROW then
      color = alpha(127 + (game.frame / 8 % 2) * 64)
    end
    @@stuff_images[pmid - ID_OTHER_OBJECTS_MIN].draw x - 11, y - 11 - game.view_pos, 0, 1, 1, color, mode
    if pmid == ID_CAROLIN then
      if xdata and xdata.length > 2 then
        name = xdata[2..-1]
      else
        name = 'Carolin'
      end
      draw_centered_string name, x, y + 16 - game.view_pos, 128
    end
  end
  
  def fall
    if in_water? and not @last_frame_in_water then
      game.cast_objects ID_FX_WATER, 5, -vx / 2, -5, 3, rect(1, 1)
      emit_sound "water#{rand(2) + 1}"
    end
    @last_frame_in_water = in_water?
    
    # Gravity
    self.vy += 1 if (pmid > ID_PLAYER_MAX or game.fly_time_left == 0)# and not in_water?
    
    if in_water? then
      self.vy -= 1 if vy > +1
      self.vy += 1 if vy < -1
      self.vx -= 1 if vx > +2
      self.vx += 1 if vx < -2
    end
    
    if pmid <= ID_PLAYER_MAX and not blocked? DIR_DOWN then
      if vx.abs < 5 then
        self.vx = (self.vx / 2.0).to_i
      else
        self.vx = (self.vx / 1.03).to_i if game.frame % 3 == 0
      end
    end
    
    # Velocity is limited to +- TILE_SIZE
    self.vx = [[vx, -TILE_SIZE].max, TILE_SIZE].min
    self.vy = [[vy, -TILE_SIZE].max, TILE_SIZE].min
    
    if vy > 0 then
      vy.times do
        break if blocked? DIR_DOWN
        self.y += 1
      end
    elsif vy < 0 then
      vy.abs.times do
        break if blocked? DIR_UP
        self.y -= 1
      end
    end
    
    if blocked? DIR_DOWN then
      if is_a? LivingObject and vx > 10 and not [ACT_DEAD, ACT_ACTION_1, ACT_ACTION_2].include? action then
        self.action = ACT_IMPACT_1 + [vy - 11, 4].min
      end
      self.vy = 0
      # Conveyor belts are neither implemented nor used
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullLeft) and (not Blocked(Dir_Left)) then Dec(PosX);
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullRight) and (not Blocked(Dir_Right)) then Inc(PosX);
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullLeft) and (not Blocked(Dir_Left)) then Dec(PosX);
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullRight) and (not Blocked(Dir_Right)) then Inc(PosX);
    end
    
    if blocked? DIR_UP and game.fly_time_left == 0 then
      self.vy = 1
      #self.vx /= +2
    end
    
    if vx < 0 then
      vx.abs.times do
        if blocked? DIR_LEFT then
          self.vx = 0
          break
        else
          self.x -= 1
        end
      end
    elsif vx > 0 then
      vx.times do
        if blocked? DIR_RIGHT then
          self.vx = 0
          break
        else
          self.x += 1
        end
      end
    end
    
    if (pmid > ID_PLAYER_MAX or game.fly_time_left == 0) and blocked? DIR_DOWN then
      self.vx -= 1 if vx >  0
      self.vx -= 1 if vx > +1
      self.vx -= 1 if pmid <= ID_ENEMY_MAX and vx > +ObjectDef[pmid].speed
      self.vx += 1 if vx <  0
      self.vx += 1 if vx < -1
      self.vx += 1 if pmid <= ID_ENEMY_MAX and vx < -ObjectDef[pmid].speed
      
      if game.map[x / TILE_SIZE, (y + ObjectDef[pmid].rect.bottom + 1) / TILE_SIZE].between? TILE_SLIME, TILE_SLIME_3 then
        (4 + game.frame % 2).times do
          self.vx -= 1 if vx > 0
          self.vx += 1 if vx < 0
        end
        (2 + game.frame % 2).times do
          self.vx -= 1 if pmid <= ID_ENEMY_MAX and vx > +ObjectDef[pmid].speed
          self.vx += 1 if pmid <= ID_ENEMY_MAX and vx < -ObjectDef[pmid].speed
        end
      end
    end
  end
  
  def fling vx, vy, randomness, fixed, malign
    # TODO the "randomness" here smells because it's only towards the bottom right?!
    
    return if pmid <= ID_PLAYER_MAX and malign and (game.inv_time_left > 0 or pmid == ID_PLAYER_BERSERKER)
    
    randomness += 1 # what
    
    if fixed then
      self.vx = vx + rand(randomness)
      self.vy = vy + rand(randomness)
    else
      self.vx += vx + rand(randomness)
      self.vy += vy + rand(randomness)
    end
  end
  
  def stuck?
    rect = self.rect
    map.solid?(rect.left, rect.top) or map.solid?(rect.right, rect.top) or
      map.solid?(rect.left, rect.bottom) or map.solid?(rect.right, rect.bottom)
  end
  
  def blocked? direction
    rect = ObjectDef[pmid].rect
    case direction
    when DIR_LEFT then
      game.map.solid? x + rect.left - 1, y + rect.top or
      game.map.solid? x + rect.left - 1, y + rect.bottom
    when DIR_RIGHT then
      game.map.solid? x + rect.right + 1, y + rect.top or
      game.map.solid? x + rect.right + 1, y + rect.bottom
    when DIR_UP then
      game.map.solid? x + rect.left,  y + rect.top - 1 or
      game.map.solid? x + rect.right, y + rect.top - 1
    when DIR_DOWN then
      game.map.solid? x + rect.left,  y + rect.bottom + 1 or
      game.map.solid? x + rect.right, y + rect.bottom + 1
    end
  end
  
  def check_tile
    case game.map[x / TILE_SIZE, y / TILE_SIZE]
    when TILE_AIR_ROCKET_UP, TILE_AIR_ROCKET_UP_2, TILE_AIR_ROCKET_UP_3 then
      emit_sound :turbo
      fling 0, -21, 0, true, false
      self.y -= 1 unless blocked? DIR_UP
      self.x = x / 24 * 24 + 11
      self.vx = direction.dir_to_vx if pmid.between? ID_ENEMY, ID_ENEMY_MAX
      game.cast_fx 0, 0, 10, x, y, 24, 24, 0, -10, 1
      # Tile_AirRocketUpLeft: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   if not Blocked(Dir_Up) then Dec(PosY);
      #   Fling(-10, -15, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, -8, -8, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketUpRight: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   if not Blocked(Dir_Up) then Dec(PosY);
      #   Fling(10, -15, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, +8, -8, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketLeft: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   Fling(-20, 2, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, -10, 0, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketRight: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   Fling(20, -2, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, +10, 0, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketDown: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   Fling(0, 15, 0, True, False);
      #   PosX := PosX div 24 * 24 + 11;
      #   if (ID >= ID_Enemy) and (ID <= ID_EnemyMax) then VelX := RealDir(TPMLiving(Self).Direction);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, 0, 8, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_SlowRocketUp: begin
      #   CastFX(0, 0, 1, PosX, PosY, 24, 24, 0, -2, 1, Data.OptEffects, Data.ObjEffects);
      #   VelX := VelX div 2;
      #   Dec(VelY, 4);
      #   if (ID >= ID_Enemy) and (ID <= ID_EnemyMax) then VelX := RealDir(TPMLiving(Self).Direction);
      #   if Self.ClassType = TPMLiving then
      #     TPMLiving(Self).Action := Act_Jump;
      # end;
    when TILE_SPIKES then
      if pmid <= ID_LIVING_MAX and (y + ObjectDef[pmid].rect.bottom) % 24 > 8 then
        hit
        self.vx = 0
        self.vy = -10
      end
    when TILE_SPIKES_TOP then
      if pmid <= ID_LIVING_MAX and (y + ObjectDef[pmid].rect.bottom) % 24 < 14 then
        hit
        self.vx = 0
        self.vy = 5
      end
    end
  end
  
  def explosion x, y, radius, do_score
    # TODO DistSound(Y, Sound_Explosion, Data);
    
    (10 + radius / 2).times do
      angle = Gosu::random(0, 360)
      slowdown = Gosu::random(5, 11)
      fx = game.create_object(ID_FX_SMOKE + rand(2), x, y, nil)
      fx.vx = Gosu::offset_x(angle, radius / slowdown).to_i
      fx.vy = Gosu::offset_y(angle, radius / slowdown).to_i
    end
    
    # Damage livings
    # TempObj := Data.ObjEnemies.Next;
    #     while TempObj <> Data.ObjEffects do begin
    #       if (TempObj.ClassType = TPMLiving) and (TPMLiving(TempObj).Action < Act_Dead) then begin
    #         if Sqrt(Power(Abs(X - TempObj.PosX), 2) + Power(Abs(Y - TempObj.PosY), 2)) <= (Radius / 3) then TPMLiving(TempObj).Hurt(True)
    #           else if Sqrt(Power(Abs(X - TempObj.PosX), 2) + Power(Abs(Y - TempObj.PosY), 2)) <= Radius then TPMLiving(TempObj).Hit;
    #         if DoScore and (TempObj.ID in [ID_Enemy..ID_EnemyMax]) and (TPMLiving(TempObj).Action = Act_Dead) then begin
    #           Inc(Data.Score, Data.Defs[TempObj.ID].Life * 3);
    #           TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TempObj.ID].Life * 3) + ' Punkte!', ID_FXText, TempObj.PosX, TempObj.PosY - 10, 0, -1);
    #         end;
    #       end;
    #       TempObj := TempObj.Next;
    #     end;
    
    # Damage creates
    # for I := (X - Radius) div 24 to (X + Radius) div 24 do
    #       for P := (Y - Radius) div 24 to (Y + Radius) div 24 do begin
    #         if (Sqrt(Power(Abs(X div 24 - I), 2) + Power(Abs(Y div 24 - P), 2)) < Radius / 24)
    #           and (Data.Map.Tile(I * 24, P * 24) in [Tile_BigBlocker, Tile_BigBlocker2])
    #             and (FindObject(Data.ObjEffects, Data.ObjEnd, ID_FXFire, ID_FXFire, Bounds(I * 24 - 1, P * 24 - 1, 2, 2)) = nil) then
    #               TPMEffect.Create(Data.ObjEffects, '', ID_FXFire, I * 24, P * 24, 0, 0);
    #         if Data.Map.Tile(I * 24, P * 24) in [Tile_Blocker..Tile_Blocker3] then begin
    #           if Data.Map.Tile(I * 24, P * 24) in [Tile_Blocker, Tile_Blocker2]
    #             then Data.Map.Tiles[I, P] := Tile_BlockerBroken
    #             else Data.Map.Tiles[I, P] := Tile_Blocker3Broken;
    #           CastObjects(ID_FXBlockerParts, 10, 0, -2, 5, Data.OptEffects, Bounds(I * 24, P * 24, 24, 24), Data.ObjEffects);
    #           DistSound(Y, Sound_BlockerBreak, Data);
    #         end;
    #         if Data.Map.Tile(I * 24, P * 24) = Tile_BigBlocker3 then begin
    #           Data.Map.SetTile(I, P, 0);
    #           DistSound(Y, Sound_Break + Random(2), Data);
    #           CastObjects(ID_FXBreakingParts, 20, 0, 3, 3, Data.OptEffects, Bounds(I * 24, P * 24, 24, 24), Data.ObjEffects);
    #         end;
    #       end;
  end
  
  def collide_with? other
    other = other.rect unless other.is_a? ObjectDef::Rect
    rect.collide_with? other
  end
  
  def rect(extra_width = 0, extra_height = 0)
    rect = ObjectDef[pmid].rect
    ObjectDef::Rect.new(x + rect.left - extra_width, y + rect.top - extra_height,
      rect.width + extra_width * 2, rect.height + extra_height * 2)
  end
end
