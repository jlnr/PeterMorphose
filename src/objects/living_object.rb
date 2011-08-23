class LivingObject < GameObject
  attr_accessor :life, :action, :direction
  
  def initialize *args
    super
    
    @life = ObjectDef[pmid].life
    @action = 0
    @direction = rand(2)
  end
  
  def act
    return if game.frame == -1
    
    case pmid
    when ID_PLAYER then
      return if busy?
      if game.find_object ID_LEVER, ID_LEVER_RIGHT, rect(10, 3) then
        self.action = ACT_ACTION_1
        self.vx = 0
      end
    when ID_PLAYER_FIGHTER then
      return if action > ACT_LAND
      sound(:sword_whoosh).play
      self.action = ACT_ACTION_1
      tile_x = (x + 10 * direction.dir_to_vx) / TILE_SIZE
      tile_y = y / TILE_SIZE
      if game.map[tile_x, tile_y].between? TILE_BLOCKER, TILE_BLOCKER_3 then
        if game.map[tile_x, tile_y] != TILE_BLOCKER_3 then
          game.map[tile_x, tile_y] = TILE_BLOCKER_BROKEN
        else
          game.map[tile_x, tile_y] = TILE_BLOCKER_3_BROKEN
        end
        game.cast_objects ID_FX_BLOCKER_PARTS, 10, 0, -2, 5,
          ObjectDef::Rect.new(tile_x * TILE_SIZE, tile_y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        sound(:blocker_break).play
      end
    when ID_PLAYER_GUN
      self.action = ACT_ACTION_1 if action < ACT_LAND and game.ammo > 0
    when ID_PLAYER_BOMBER
      self.action = ACT_ACTION_1 if action < ACT_LAND and game.bombs > 0
    end;
  end
  
  def busy?
    not blocked? DIR_DOWN or not action.between? ACT_STAND, ACT_WALK_4
  end
  
  def draw
    return if [ACT_INV_UP, ACT_INV_DOWN].include? action
    
    case pmid
    when ID_PLAYER..ID_PLAYER_BOMBER then
      # Animated wings while flying
      if game.fly_time_left > 0 then
        color = alpha([game.fly_time_left * 2 + 16, 255].min)
        case player.direction
          when DIR_LEFT then
            EffectObject.images[38 + (game.frame / 2) % 4].draw x - 18, y - 12 - game.view_pos, 0.75, 1, color, :additive
            EffectObject.images[42 + (game.frame / 2) % 4].draw x,      y - 12 - game.view_pos, 1.00, 1, color, :additive
          when DIR_RIGHT then
            EffectObject.images[38 + (game.frame / 2) % 4].draw x - 24, y - 12 - game.view_pos, 1.00, 1, color, :additive
            EffectObject.images[42 + (game.frame / 2) % 4].draw x,      y - 12 - game.view_pos, 0.75, 1, color, :additive
        end
      end
      # Transparency while invincible
      if game.inv_time_left == 0 or type = ID_PLAYER_BERSERKER then
        color = 0xffffffff
      else
        color = 0xa0ffffff
      end
      @@player_images ||= Gosu::Image.load_tiles 'media/player.bmp', -ACT_NUM, -10
      @@player_images[ACT_NUM * (direction + (pmid - ID_PLAYER) * 2) + action].draw x - 11, y - 11 - game.view_pos, 0, 1, 1, color
    when ID_ENEMY..ID_ENEMY_MAX then
      if pmid == ID_ENEMY_GUN then
        dir = x > game.player.x ? DIR_LEFT : DIR_RIGHT
      else
        dir = direction
      end
      @@enemy_images ||= Gosu::Image.load_tiles 'media/enemies.bmp', -ACT_NUM, -10
      @@enemy_images[ACT_NUM * (dir + (pmid - ID_ENEMY) * 2) + action].draw x - 11, y - 11 - game.view_pos, 0
    end
  end
  
  def hurt from_explosion
    return if action == ACT_DEAD or pmid == ID_PLAYER_BERSERKER
    damage = 3
    damage -= 1 if pmid == ID_PLAYER_FIGHTER
    if pmid <= ID_PLAYER_MAX then
      if game.inv_time_left > 0 then
        damage = from_explosion ? 1 : 0
      end
      if from_explosion or game.inv_time_left == 0 then
        game.inv_time_left = [25, game.inv_time_left].max
      end
    end
    self.life -= damage
    
    if life < 1 then
      self.action = ACT_DEAD
      self.life = 0
    else
      self.action = ACT_PAIN_1 + rand(2)
    end
    case pmid
      when ID_PLAYER..ID_PLAYER_MAX then
        sound(:player_arg).play
      when ID_ENEMY..ID_ENEMY_MAX then
        emit_sound "arg#{rand(2) + 1}"
        # TODO or Death sound
    end
    
    # if Data.OptBlood = 1 then CastObjects(ID_FXBlood, ToDoDamage * 8, 0, 2, 2, Data.OptEffects, GetRect(0, 0), Data.ObjEffects);
    
    if pmid == ID_ENEMY_BOMBER and action == ACT_DEAD then
      kill
      game.cast_fx 10, 30, 10, x, y, 10, 10, 0, -10, 5
    end
  end
  
  def hit
    return if action == ACT_DEAD or pmid == ID_PLAYER_BERSERKER
    return if pmid == ID_PLAYER_FIGHTER and rand(2) == 0
    
    if pmid <= ID_PLAYER_MAX then
      return if game.inv_time_left > 0
      game.inv_time_left = [25, game.inv_time_left].max
    end
    
    self.life -= 1
    
    if life < 1 then
      self.action = ACT_DEAD
      self.life = 0
    else
      self.action = ACT_PAIN_1 + rand(2)
    end
    case pmid
      when ID_PLAYER..ID_PLAYER_MAX then
        sound(:player_arg).play
      when ID_ENEMY..ID_ENEMY_MAX then
        emit_sound "arg#{rand(2) + 1}"
        # TODO or Death sound
    end
    
    # if Data.OptBlood = 1 then CastObjects(ID_FXBlood, 8, 0, 2, 2, Data.OptEffects, GetRect(0, 0), Data.ObjEffects);
    
    if pmid == ID_ENEMY_BOMBER and action == ACT_DEAD then
      kill
      game.cast_fx 10, 30, 10, x, y, 10, 10, 0, -10, 5
    end
  end
  
  def update
    # Runterfallen
    fall if action < ACT_INV_UP
    
    # Roasted by lava
    if y + ObjectDef[pmid].rect.bottom > game.map.lava_pos then
      game.cast_fx 8, 8, 0, x, y, 16, 16, 0, -4, 1
      kill
      emit_sound :shshsh
      if action != ACT_DEAD then
        emit_sound :player_arg if pmid <= ID_PLAYER_MAX
        emit_sound "arg#{rand(2) + 1}" if pmid.between? ID_ENEMY, ID_ENEMY_MAX
        # TODO bloody: emit_sound :death if pmid.between? ID_ENEMY, ID_ENEMY_MAX
      end
      return
    end
    
    # Ascending staircase
    except_open_doors = (0..TILE_STAIRS_UP_LOCKED).to_a + [TILE_STAIRS_DOWN_LOCKED]
    if action == ACT_INV_UP then
      emit_sound :stairs_steps if rand(8) == 0
      2.times do
        tile_below = game.map[x / TILE_SIZE, (y + 12) / TILE_SIZE]
        tile_above = game.map[x / TILE_SIZE, (y - 9) / TILE_SIZE]
        if except_open_doors.include? tile_below or except_open_doors.include? tile_above then
          self.y -= 2
        else
          self.x = self.x / TILE_SIZE * TILE_SIZE + TILE_SIZE / 2 - 1
        end
      end
      tile_below = game.map[x / TILE_SIZE, (y + 12) / TILE_SIZE]
      tile_above = game.map[x / TILE_SIZE, (y - 9) / TILE_SIZE]
      if except_open_doors.include? tile_below or except_open_doors.include? tile_above then
        self.y -= 2
        return
      else
        self.x = self.x / TILE_SIZE * TILE_SIZE + TILE_SIZE / 2
      end
    elsif action == ACT_INV_DOWN then
      emit_sound :stairs_steps if rand(7) == 0
      3.times do
        tile_below = game.map[x / TILE_SIZE, (y + 12) / TILE_SIZE]
        tile_above = game.map[x / TILE_SIZE, (y - 9) / TILE_SIZE]
        if except_open_doors.include? tile_below or except_open_doors.include? tile_above then
          self.y += 2
        else
          self.x = self.x / TILE_SIZE * TILE_SIZE + TILE_SIZE / 2 - 1
        end
      end
      tile_below = game.map[x / TILE_SIZE, (y + 12) / TILE_SIZE]
      tile_above = game.map[x / TILE_SIZE, (y - 9) / TILE_SIZE]
      if except_open_doors.include? tile_below or except_open_doors.include? tile_above then
        self.y += 2
        return
      else
        self.x = self.x / TILE_SIZE * TILE_SIZE + TILE_SIZE / 2
      end
    end
    
    check_tile if action != ACT_DEAD
    
    # Break tiles where due
    rect = self.rect(0, 2)
    break_floor rect.left,  rect.bottom
    break_floor rect.right, rect.bottom
    
    return if action == ACT_DEAD
    
    if in_water? then
      game.create_object ID_FX_WATER_BUBBLE, x, y - 7, nil if rand(30) == 0
      if pmid == ID_PLAYER_BERSERKER then
        self.pmid = ID_PLAYER
        game.cast_fx 8, 0, 0, x, y, 24, 24, 0, -1, 4
      elsif pmid == ID_ENEMY_BERSERKER then
        self.pmid = ID_ENEMY
        game.cast_fx 8, 0, 0, x, y, 24, 24, 0, -1, 4
      end
    end
    
    # Open doors
    if pmid <= ID_PLAYER_MAX and game.keys > 0 then
      # Left
      tile_x, tile_y = (x + ObjectDef[pmid].rect.left - 1) / TILE_SIZE, y / TILE_SIZE
      if game.map[tile_x, tile_y].between? TILE_CLOSED_DOOR, TILE_CLOSED_DOOR_3 then
        game.map[tile_x, tile_y] -= (TILE_CLOSED_DOOR - TILE_OPEN_DOOR)
        game.keys -= 1
        sound("door#{rand(2) + 1}").play
      end

      # Right
      tile_x, tile_y = (x + ObjectDef[pmid].rect.right + 1) / TILE_SIZE, y / TILE_SIZE
      if game.map[tile_x, tile_y].between? TILE_CLOSED_DOOR, TILE_CLOSED_DOOR_3 then
        game.map[tile_x, tile_y] -= (TILE_CLOSED_DOOR - TILE_OPEN_DOOR)
        game.keys -= 1
        sound("door#{rand(2) + 1}").play
      end

      # Up
      tile_x, tile_y = x / TILE_SIZE, (y + ObjectDef[pmid].rect.top - 1) / TILE_SIZE
      if game.map[tile_x, tile_y].between? TILE_CLOSED_DOOR, TILE_CLOSED_DOOR_3 then
        game.map[tile_x, tile_y] -= (TILE_CLOSED_DOOR - TILE_OPEN_DOOR)
        game.keys -= 1
        sound("door#{rand(2) + 1}").play
      end

      # Down
      tile_x, tile_y = x / TILE_SIZE, (y + ObjectDef[pmid].rect.bottom + 1) / TILE_SIZE
      if game.map[tile_x, tile_y].between? TILE_CLOSED_DOOR, TILE_CLOSED_DOOR_3 then
        game.map[tile_x, tile_y] -= (TILE_CLOSED_DOOR - TILE_OPEN_DOOR)
        game.keys -= 1
        sound("door#{rand(2) + 1}").play
      end
    end
    
    # Special actions
    
    # Plain Peter: Use levers
    if pmid == ID_PLAYER and action == ACT_ACTION_3 and game.frame % 2 == 0 then
      if target = game.find_object(ID_LEVER, ID_LEVER_RIGHT, rect(12, 3)) then
        sound(:lever).play
        target.pmid =
          case target.pmid
          when ID_LEVER then ID_LEVER_DOWN
          when ID_LEVER_LEFT then ID_LEVER_RIGHT
          when ID_LEVER_RIGHT then ID_LEVER_LEFT
          end
        
        if not target.xdata.nil? and not target.xdata.empty? then
          if target.xdata =~ /^[0-9A-F]/ then
            target.xdata[0, 1].to_i(16).times do |i|
              tile_x   = target.xdata[2 + i * 10, 2].to_i(16)
              tile_y   = target.xdata[5 + i * 10, 3].to_i(16)
              new_tile = target.xdata[9 + i * 10, 2].to_i(16)
              old_tile = game.map[tile_x, tile_y]
              game.map[tile_x, tile_y] = new_tile
              target.xdata[9 + i * 10, 2] = '%02X' % old_tile
              game.cast_fx 8, 0, 0, tile_x * TILE_SIZE + 10, tile_y * TILE_SIZE + 12, 24, 24, 0, 0, 2
            end
          else
            game.execute_script xdata[2..-1], 'do'
          end
        end
      end
    end
    
    # Lord Peter: Stab
    if pmid == ID_PLAYER_FIGHTER and action.between? ACT_ACTION_1, ACT_ACTION_5 then
      rect = ObjectDef::Rect.new(x - 11 + direction.dir_to_vx * 6, y - 16, 22, 32)
      if target = game.find_living(ID_ENEMY, ID_ENEMY_MAX, 0, ACT_PAIN_1 - 1, rect) then
        target.hit
        target.fling 5 * direction.dir_to_vx, -4, 1, true, true
        if target.action == ACT_DEAD then
          game.score += score = ObjectDef[target.pmid].life * 3
          target.emit_text "*#{score}*"
        end
      end
    end
    
    # Archer Peter: Shoot at ACT_ACTION_5
    # TODO or better 4, because the "action progress" code translation below is FUBAR
    if pmid == ID_PLAYER_GUN and action == ACT_ACTION_4 and game.frame % 2 == 0 then
      game.ammo -= 1
      if target = game.launch_projectile(x, y + 2, direction, ID_ENEMY, ID_ENEMY_MAX) then
        target.hurt(true)
        target.fling 3 * direction.dir_to_vx * 3, -3, 1, true, true
        if target.action == ACT_DEAD then
          game.score += score = ObjectDef[target.pmid].life * 3
          target.emit_text "*#{score}*"
        end
      end
    end
    
    if pmid == ID_PLAYER_BERSERKER then
      game.cast_fx rand(2), 2 + rand(2), 0, x, y, 18, 24, 0, -3, 2
      rect = self.rect(2, 2)
      game.objects.each do |obj|
        if obj.pmid.between? ID_ENEMY, ID_ENEMY_MAX and obj.action < ACT_DEAD and obj.collide_with? rect then
          obj.hurt(false)
          if obj.action = ACT_DEAD then
            game.score += score = ObjectDef[obj.pmid].life * 3
            obj.emit_text "*#{score}*"
          end
        end
      end
    end
    
    if pmid == ID_ENEMY_BERSERKER then
      game.cast_fx 0, rand(3), 0, x, y, 18, 24, 0, -2, 3
      if game.player.action < ACT_DEAD and game.player.collide_with? rect(5, 2) then
        game.player.hit
        game.player.fling 8 * direction.dir_to_vx * 8, -3, 0, true, true
        self.fling -8 * direction.dir_to_vx * 8, -4, 0, true, false
        return
      end
    end
    
    if pmid == ID_PLAYER_BOMBER and action == ACT_ACTION_4 and game.frame % 3 == 0 then
      game.bombs -= 1
      bomb = game.create_object(ID_FUSING_BOMB, x + direction.dir_to_vx * 5, y + 2, '0')
      bomb.vx = direction.dir_to_vx * 8
      bomb.vy = -3
    end
    
    if pmid <= ID_PLAYER_MAX and not busy? then
      self.direction = DIR_LEFT  if vx < 0
      self.direction = DIR_RIGHT if vx > 0
    end;
    
    if pmid == ID_ENEMY_GUN and action == ACT_ACTION_4 then
      self.action = ACT_ACTION_5 # TODO this was better before?!
      shoot_dir = game.player.x < x ? DIR_LEFT : DIR_RIGHT
      if target = game.launch_projectile(x, y + 2, shoot_dir, ID_PLAYER, ID_PLAYER_MAX) then
        target.hit
        target.fling 3 * shoot_dir.dir_to_vx, -3, 1, true, true
      end
    end
    
    # "AI"
    if pmid >= ID_ENEMY and not busy? then
      self.direction = direction.other_dir if blocked? direction
      
      # Run around
      if pmid == ID_ENEMY_FIGHTER and game.frame % 100 < 70 or
         pmid == ID_ENEMY_GUN and game.frame % 100 > 15 or
         [ID_ENEMY, ID_ENEMY_BERSERKER, ID_ENEMY_BOMBER].include? pmid then
        if game.map.solid?(x + direction.dir_to_vx * 7, y + ObjectDef[pmid].rect.bottom + 1)
          self.vx += ObjectDef[pmid].speed * direction.dir_to_vx
        else
          if xdata and xdata[0, 1] == '1' then
            jump
          else
            self.direction = direction.other_dir
          end
        end
      end
      
      # Occasionally use a floor tile
      return use_tile if rand(100) == 0 and xdata and xdata[2, 1] == '1'
      
      # Ambush player
      if pmid == ID_ENEMY_FIGHTER and
         game.player.action < ACT_DEAD and
         game.player.collide_with? ObjectDef::Rect.new(x - 120 + direction * 120, y - 24, 120, 48) and
         game.map.solid?(x + direction.dir_to_vx * 7, y + ObjectDef[pmid].rect.bottom + 1) then
        self.vx = ObjectDef[pmid].speed * 2 * direction.dir_to_vx
      end
      
      # Shoot player if line of sight is free
      if pmid == ID_ENEMY_GUN and game.player.action < ACT_DEAD and
         rect(320, 1).include? game.player then
        tiles_to_check = (game.player.x - x).abs / TILE_SIZE
        if (0..tiles_to_check).none? { |i| game.map.solid?(i * TILE_SIZE + [game.player.x, x].min, y) } then
          self.action = ACT_ACTION_1
        end
      end
      
      # Collide with player while running
      if game.player.action < ACT_PAIN_1 and collide_with? game.player.rect(1, -1) then
        if pmid == ID_ENEMY_BOMBER then
          game.player.hurt(true)
          game.cast_fx 10, 30, 10, x, y, 10, 20, 0, -10, 5
          kill
        else
          game.player.hit
          fling -6 * direction.dir_to_vx, -2, 0, true, false
        end
        game.player.fling 8 * direction.dir_to_vx, -3, 0, true, true
        return
      end
    end
    
    # Collide with player while airborne
    if pmid >= ID_ENEMY and [ACT_JUMP, ACT_LAND].include? action and
       collide_with? game.player.rect(0, -1) then
      if pmid == ID_ENEMY_BOMBER then
        game.player.hurt(true)
        game.cast_fx 10, 30, 10, x, y, 10, 0, -10, 5
        kill
      else
        game.player.hit
        fling -6 * direction.dir_to_vx, -2, 0, true, false
      end
      game.player.fling 8 * direction.dir_to_vx, -3, 0, true, true
      return
    end
    
    # Fly
    if pmid <= ID_PLAYER_MAX and game.fly_time_left > 0 and not (ACT_ACTION_1..ACT_ACTION_5).include? action then
      self.action = vy < 0 ? ACT_JUMP : ACT_LAND
      return
    end
    
    # Hurt player cannot recover until on the ground
    return if [ACT_PAIN_1, ACT_PAIN_2].include? action and not blocked? DIR_DOWN and not in_water?
    
    # Hingefallen, weiter aufstehen
    if action.between? ACT_IMPACT_1, ACT_IMPACT_5 then
      self.action -= 1 unless game.frame % 2 == 0
      return unless action == ACT_IMPACT_1 and game.frame % 2 == 1
    end
    
    # Continue with special action
    if action.between? ACT_ACTION_1, ACT_ACTION_5 then
      case pmid
      when ID_PLAYER, ID_PLAYER_GUN, ID_ENEMY_FIGHTER then slowness = 2
      when ID_ENEMY_GUN then slowness = 5
      when ID_PLAYER_BOMBER then slowness = 3
      else
        slowness = 1
      end
      
      return if game.frame % slowness != 0
      self.action += 1
      return unless action == ACT_ACTION_5
    end
    
    if not blocked? DIR_DOWN then
      self.action = vy < 0 ? ACT_JUMP : ACT_LAND
      return
    end
    
    # TODO slime
    # // Auf Schleim laufen / Spieler
    # if (ID <= ID_PlayerMax) and Blocked(Dir_Down) and (Data.Map.Tile(PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3])
    #   and ((isLeft in Data.Input.States) or (isRight in Data.Input.States))
    #     then begin
    #       Action := Act_Walk1 + Data.Frame mod 12 div 3;
    #       if isLeft in Data.Input.States then Direction := Dir_Left else Direction := Dir_Right;
    #       if (Abs(Data.ObjPlayers.Next.PosY - PosY) < Data.OptEffectsDistance) and (Random(5) = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXFlyingBlob, PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom, -1 + Random(3), Random(3));
    #       if Random(5) = 0 then DistSound(PosY, Sound_Slime + Random(3), Data^);
    #       Exit;
    #     end;
    # // Auf Schleim laufen / Gegner
    # if Blocked(Dir_Down) and (Data.Map.Tile(PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3])
    #   and (((ID = ID_EnemyFighter) and (Data.Frame mod 100 < 70))
    #        or ((ID = ID_EnemyGun) and (Data.Frame mod 100 > 15))
    #        or (ID in [ID_Enemy, ID_EnemyBerserker, ID_EnemyBomber]))
    #     then begin
    #       Action := Act_Walk1 + Data.Frame mod 12 div 3;
    #       if (Abs(Data.ObjPlayers.Next.PosY - PosY) < Data.OptEffectsDistance) and (Random(5) = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXFlyingBlob, PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom, -1 + Random(3), Random(3));
    #       if Random(5) = 0 then DistSound(PosY, Sound_Slime + Random(3), Data^);
    #       Exit;
    #     end;
    
    # Walking animation
    if blocked? DIR_DOWN and vx.abs > 0 then
      self.action = ACT_WALK_1 + game.frame % 8 / 2
      return
    end
    
    # "idlezeiten von ueber 4 wochen sind absolut eleet"
    self.action = ACT_STAND
  end
  
  def dispose
    return if game.frame == -1 or pmid > ID_PLAYER_MAX
    @pmid = ID_PLAYER
    @action = ACT_JUMP unless action == ACT_DEAD
    game.cast_fx 8, 0, 0, x, y, 24, 24, 0, -1, 4
  end
  
  def jump
    # Cannot jump when dead
    return if action >= ACT_DEAD
    
    if in_water? then
      # Cannot jump when in deep water
      return if ALL_WATER_TILES.include? game.map[x / TILE_SIZE, y / TILE_SIZE]
    else
      # Cannot jump when busy
      return if busy?
    end
    
    dir = DIR_UP
    if pmid <= ID_PLAYER_MAX then
      dir = self.direction = DIR_LEFT if left_pressed?
      dir = self.direction = DIR_RIGHT if right_pressed?
    end
    
    if pmid <= ID_PLAYER_MAX and game.jump_time_left > 0 then
      self.vy = (ObjectDef[pmid].jump_y * 1.5).round - 1
      game.cast_objects ID_FX_SMOKE, 2, 0, 3, 2, rect(1, 0)
      sound(:turbo).play
      dir = DIR_UP
    else
      self.vy = ObjectDef[pmid].jump_y - 1
    end
    
    if dir == DIR_UP then
      self.vx = 0
    else
      self.vx = dir.dir_to_vx * [ObjectDef[pmid].jump_x, vx.abs / 2].max
      
      # TODO Slime tiles
      #if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3])
      #or (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3]) then begin
      #  VelX := VelX div 3;
      #  VelY := Round(VelY / 1.5);
    end
    
    if in_water? then
      self.vx /= 3
      self.vy = (vy / 1.2).round
      emit_sound :water
    end
    
    self.action = ACT_JUMP
    sound(:jump).play if pmid <= ID_PLAYER_MAX
  end
  
  def use_tile
    return if busy?
    
    # Tile below player (magic floor tiles)
    case map_tile = game.map[x / TILE_SIZE, (y + ObjectDef[pmid].rect.bottom + 1) / TILE_SIZE]
    when TILE_ROCKET_UP, TILE_ROCKET_UP_2, TILE_ROCKET_UP_3 then
      sound(:jump).play if pmid <= ID_PLAYER_MAX
      emit_sound :turbo
      self.vx = 0
      self.vy = -20
      self.y -= 1 unless blocked? DIR_UP
      self.action = ACT_JUMP
      # TODO CastFX(0, 0, 10, PosX, PosY, 24, 24, 0, -10, 1, Data.OptEffects, Data.ObjEffects);
      return
    when TILE_ROCKET_UP_LEFT, TILE_ROCKET_UP_LEFT_2, TILE_ROCKET_UP_LEFT_3 then
      sound(:jump).play if pmid <= ID_PLAYER_MAX
      emit_sound :turbo
      self.vx = -15
      self.vy = -15
      self.y -= 1 unless blocked? DIR_UP
      self.action = ACT_JUMP
      self.direction = DIR_LEFT
      # TODO CastFX(0, 0, 10, PosX, PosY, 24, 24, -8, -8, 1, Data.OptEffects, Data.ObjEffects);
      return
    when TILE_ROCKET_UP_RIGHT, TILE_ROCKET_UP_RIGHT_2, TILE_ROCKET_UP_RIGHT_3 then
      sound(:jump).play if pmid <= ID_PLAYER_MAX
      emit_sound :turbo
      self.vx = +15
      self.vy = -15
      self.y -= 1 unless blocked? DIR_UP
      self.action = ACT_JUMP
      self.direction = DIR_RIGHT
      # TODO CastFX(0, 0, 10, PosX, PosY, 24, 24, +8, -8, 1, Data.OptEffects, Data.ObjEffects);
      return
    when TILE_MORPH_FIGHTER..TILE_MORPH_MAX
      if pmid <= ID_PLAYER_MAX then
        sound(:morph).play
        self.pmid = ID_PLAYER_FIGHTER + map_tile - TILE_MORPH_FIGHTER
        game.time_left = ObjectDef[pmid].life unless pmid == ID_PLAYER
        game.cast_fx 8, 0, 0, x, y, 24, 24, 0, -1, 4
        emit_text "#{ObjectDef[pmid].name}!"
        return
      end
    end
    
    # Tile right behind player (doors etc.)
    case game.map[x / TILE_SIZE, y / TILE_SIZE]
    when TILE_STAIRS_UP_LOCKED then
      return if pmid > ID_PLAYER_MAX or game.keys == 0
      game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_STAIRS_UP
      game.keys -= 1
      sound("door#{rand(2) + 1}").play
      use_tile
    when TILE_STAIRS_UP..TILE_STAIRS_UP_2 then
      return if not game.map.stairs_passable? x / TILE_SIZE, y / TILE_SIZE and pmid >= ID_PLAYER_MAX
      self.y = y / TILE_SIZE * TILE_SIZE
      self.action = ACT_INV_UP
      self.vx = self.vy = 0
      emit_sound :stairs
    when TILE_STAIRS_DOWN_LOCKED then
      return if pmid > ID_PLAYER_MAX or game.keys == 0
      game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_STAIRS_DOWN
      game.keys -= 1
      sound("door#{rand(2) + 1}").play
      use_tile
    when TILE_STAIRS_DOWN..TILE_STAIRS_DOWN_2 then
      return if not game.map.stairs_passable? x / TILE_SIZE, y / TILE_SIZE
      self.y = y / TILE_SIZE * TILE_SIZE + 13
      self.action = ACT_INV_DOWN
      self.vx = self.vy = 0
      emit_sound :stairs
    end
  end
  
  private
  
  def break_floor x, y
    debug binding if pmid == ID_PLAYER and $window.button_down? Gosu::KbD
    if (TILE_BRIDGE..TILE_BRIDGE_4).include? game.map[x / TILE_SIZE, y / TILE_SIZE] and
      not game.find_object(ID_FX_BREAK, ID_FX_BREAK_2,
        ObjectDef::Rect.new(x / TILE_SIZE * TILE_SIZE, y / TILE_SIZE * TILE_SIZE, 24, 24)) then
      game.create_object ID_FX_BREAK + rand(2),
                         x / TILE_SIZE * TILE_SIZE + 11,
                         y / TILE_SIZE * TILE_SIZE + 11, nil
      emit_sound "break#{rand(2) + 1}"
    end
  end
end
