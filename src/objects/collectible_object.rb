class CollectibleObject < GameObject
  def update
    if not [ID_EDIBLE_FISH, ID_EDIBLE_FISH_2].include? pmid and not xdata.nil? and xdata[1, 1] == '1' then
      fall
      check_tile
    end
    
    # Burn in lava
    if y + ObjectDef[pmid].rect.bottom > game.map.lava_pos then
      game.cast_fx 2, 2, 0, x, y, 16, 16, 0, -3, 1
      kill
      emit_sound :shshsh
      game.lose if pmid == ID_CAROLIN
    end
    
    if pmid == ID_CAROLIN and game.frame % 20 == 0 and rand(4) == 0 then
      emit_sound "help#{rand(2) + 1}"
    end
    
    if [ID_EDIBLE_FISH, ID_EDIBLE_FISH_2].include? pmid then
      if not in_water? then
        if xdata.is_a? String and xdata[0, 1] == '1' then
          fall
          check_tile
        end
      else
        if pmid == ID_EDIBLE_FISH then
          self.x -= 2
          self.pmid = ID_EDIBLE_FISH_2 if blocked? DIR_LEFT
        else
          self.x += 2
          self.pmid = ID_EDIBLE_FISH if blocked? DIR_RIGHT
        end
        game.create_object ID_FX_WATER_BUBBLE, x, y - 3, nil if rand(30) == 0
      end
    end
    
    # Cannot be collected...
    return if game.player.action >= ACT_DEAD
    
    if collide_with? game.player.rect(2, 2) then
      case pmid
      when ID_CAROLIN then
        game.cast_objects ID_FX_FLYING_CHAIN, 8, 0, -1, 3, rect(1, -1)
        fc = game.create_object ID_FX_FLYING_CAROLIN, x, y, nil
        fc.vx, fc.vy = -7 + rand(15), -15, 
        sound(:yippie).play
        game.score += 100
        kill
      when ID_KEY then
        sound(:collect_key).play
        game.player.emit_text "#{ObjectDef[pmid].name}!"
        game.cast_objects ID_FX_SPARKLE, 2, 0, 0, 0, rect
        game.score += 2
        game.keys += 1
        kill
      when ID_EDIBLE_FISH, ID_EDIBLE_FISH_2 then
        sound(:collect_health).play
        sound(:eat).play
        game.player.emit_text '+1'
        game.score += 2
        game.player.life += 1
        kill
      when ID_MORE_TIME, ID_MORE_TIME_2 then
        return if game.player.pmid == ID_PLAYER
        sound(:morph).play
        game.cast_objects ID_FX_SPARKLE, 2, 0, 0, 0, rect
        if pmid == ID_MORE_TIME then
          game.player.emit_text '+1 Sekunde'
          game.score += 5
          game.time_left += 30
        else
          game.player.emit_text '+3,5 Sekunden'
          game.score += 10
          game.time_left += 110
        end
        kill
      when ID_HEALTH, ID_HEALTH_2 then
        if pmid == ID_HEALTH then amount = 1 else amount = 4 end
        sound(:collect_health).play
        game.player.emit_text '+1'
        game.cast_objects ID_FX_SPARKLE, 2, 0, 0, 0, rect
        game.score += amount
        game.player.life += amount
        kill
      when ID_STAR..ID_STAR_3 then
        sound(:collect_star).play Gosu::random(0.5, 0.7), Gosu::random(0.9, 1.1)
        game.score += 2
        game.stars += 1
        if game.stars < game.stars_goal then
          game.player.emit_text "Noch #{game.stars_goal - game.stars}"
        elsif game.stars == game.stars_goal then
          game.player.emit_text "Genug gesammelt!"
        end
        game.cast_objects ID_FX_SPARKLE, 2, 0, 0, 0, rect
        kill
      when ID_POINTS..ID_POINTS_MAX then
        sound(:collect_points).play
        game.player.emit_text "*#{ObjectDef[pmid].life}*"
        game.cast_objects ID_FX_SPARKLE, 3, 0, 0, 0, rect
        game.score += ObjectDef[pmid].life
        kill
      when ID_MUNITION_GUN, ID_MUNITION_GUN_2 then
        sound(:collect_ammo).play
        amount = 1 + (pmid - ID_MUNITION_GUN) * 2
        game.player.emit_text "+#{amount}"
        game.cast_objects ID_FX_SPARKLE, 2, 0, 0, 0, rect
        game.score += amount
        game.ammo  += amount
        kill
      when ID_MUNITION_BOMBER, ID_MUNITION_BOMBER_2 then
        sound(:collect_ammo).play
        amount = 1 + (pmid - ID_MUNITION_BOMBER) * 2
        game.player.emit_text "+#{amount}"
        game.cast_objects ID_FX_SPARKLE, 2, 0, 0, 0, rect
        game.score += amount
        game.bombs += amount
        kill
      when ID_COOKIE then
        sound(:eat).play
        game.cast_objects ID_FX_SPARKLE, 1, 0, 0, 0, rect
        if xdata.nil? or xdata.length <= 2 then
          xdata = case rand(4)
          when 0 then '|Komisch, der Keks war leer?'
          when 1 then '|Sowas, der Keks war leer!'
          when 2 then '|Och nein, schon wieder ein leerer Keks!'
          when 3 then '|Der Keks ist leer.'
          end
        end
        emit_text xdata.split('|')[1], :slow
        game.score += 10
        kill
      when ID_SLOW_DOWN then
        if game.map.lava_mode == 0 and game.map.lava_speed == 48 then
        elsif game.map.lava_mode == 1 and game.map.lava_speed == 1 then
          game.map.lava_mode = 0
          game.map.lava_speed = 2
        elsif game.map.lava_mode == 0 then
          game.map.lava_speed += 1
        else
          game.map.lava_speed -= 1
        end
        sound(:collect_freeze).play
        game.player.emit_text 'Lava verlangsamt!'
        game.cast_objects ID_FX_SPARKLE, 3, 0, 0, 0, rect
        kill
      when ID_CRYSTAL then
        sound(:collect_freeze).play
        game.player.emit_text 'Lava angehalten!', :slow
        game.map.lava_time_left += 80
        game.cast_objects ID_FX_SPARKLE, 4, 0, 0, 0, rect
        kill
      when ID_MORPH_FIGHTER..ID_MORPH_MAX then
        target_id = ID_PLAYER_FIGHTER + pmid - ID_MORPH_FIGHTER
        if game.player.pmid != target_id then
          sound(:morph).play
          game.player.pmid = target_id
          game.player.emit_text "#{ObjectDef[game.player.pmid].name}!"
          game.player.action = ACT_JUMP
          game.cast_fx 8, 0, 0, x, y, 24, 24, 0, -1, 4
          game.time_left = ObjectDef[game.player.pmid].life
          game.cast_objects ID_FX_SPARKLE, 5, 0, 0, 0, rect
          kill
        end
      when ID_SPEED, ID_JUMP, ID_FLY then
        sound(:morph).play
        game.player.emit_text "#{ObjectDef[pmid].name}!", :slow
        case pmid
        when ID_SPEED then game.speed_time_left = 330
        when ID_JUMP  then game.jump_time_left  = 330
        when ID_FLY   then game.fly_time_left   =  88
        end
        game.cast_fx 8, 0, 0, game.player.x, game.player.y - 10, 24, 24, 0, -1, 4
        game.cast_objects ID_FX_SPARKLE, 2, 0, 0, 0, rect
        kill
      when ID_SEAMINE then
        game.explosion x, y, 50, false
        kill
      end
    end
  end
end
