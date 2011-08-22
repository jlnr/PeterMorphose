class Game < State
  attr_reader :player, :map, :objects
  attr_reader :view_pos, :frame
  attr_accessor :time_left, :inv_time_left, :speed_time_left, :jump_time_left, :fly_time_left
  attr_accessor :score, :keys, :stars, :ammo, :bombs
  attr_reader :stars_goal
  attr_reader :obj_vars
  
  def inspect
    "#<Game>"
  end
  
  def initialize level_info
    @view_pos = TILES_Y * TILE_SIZE - HEIGHT # TODO
    
    @player_top_pos = 1024
    @lava_top_pos = 1024
    @message_text = ''
    @message_opacity = 0
    @frame = -1
    @frame_fading_box = 16
    @time_left = @inv_time_left = @speed_time_left = @jump_time_left = @fly_time_left = 0
    @score = @keys = @stars = @ammo = @bombs = 0
    
    @lava_frame = 0
    @lava_time_left = 0
    
    @objects = []
    @obj_vars = [nil] * 16
    
    @map = Map.new(self, level_info.ini_file)
    @stars_goal = (level_info.ini_file['Map', 'StarsGoal'] || 100).to_i
    
    player_id = (level_info.ini_file['Objects', 'PlayerID'] || 0).to_i
    player_x = (level_info.ini_file['Objects', 'PlayerX'] || 288).to_i
    player_y = (level_info.ini_file['Objects', 'PlayerY'] || 24515).to_i
    @player = LivingObject.new(self, player_id, player_x, player_y, nil)
    player.vx = (level_info.ini_file['Objects', 'PlayerVX'] || 0).to_i
    player.vy = (level_info.ini_file['Objects', 'PlayerVY'] || 0).to_i
    player.life = (level_info.ini_file['Objects', 'PlayerLife'] || ObjectDef[ID_PLAYER].life).to_i
    player.direction = (level_info.ini_file['Objects', 'PlayerDirection'] || rand(2)).to_i
    player.action = ACT_STAND
    @objects << player
    
    # If the player starts as a Special Peter, give him some time
    @time_left = player.pmid == ID_PLAYER ? 0 : ObjectDef[player.pmid].life
    
    i = 0
    while obj_string = level_info.ini_file['Objects', i] do
      pmid, x, y = obj_string.split('|').map { |str| str.to_i(16) }
      create_object pmid, x, y, level_info.ini_file['Objects', "#{x}Y"]
      i += 1
    end
  end
  
  def update
    #   State_Paused, State_Game, State_Dead, State_Won: begin
    #     // W‰re State_Dead nicht doch passender?
    #     if (Data.State = State_Game) and ((Data.ObjPlayers.Next = Data.ObjEffects) or (TPMLiving(Data.ObjPlayers.Next).Action = Act_Dead)) then
    #       begin Data.State := State_Dead; Log.Add('Spieler gestorben.'); end;
    #     // Gewonnen?
    #     if (Data.State = State_Game) and (Data.ObjPlayers.Next.PosY < Data.Map.LevelTop) then
    #       if (Data.Stars >= Data.StarsGoal) and (FindObject(Data.ObjCollectibles, Data.ObjOther, ID_Carolin, ID_Carolin, Bounds(0, 0, 576, 24576)) = nil) then begin
    #         Data.State := State_Won;                          ' + IntToStr(Data.Score) + ' Punkte!');
    #       end else begin
    #         Data.State := State_Dead; Log.Add('Zu wenig Sterne oder Geiseln ¸brig - verloren.');
    #       end;
    #     // Normaler Verlauf
    #     if Data.State = State_Game then begin
    @frame = (@frame + 1) % 2400
    @message_opacity -= 3 if @message_opacity > 0
    
    #       // Jetzt schon das Skript ausf¸hren (damit Zeile 0 ber¸cksichtigt wird)
    #       if Data.Map.LavaPos div 24 < LavaTopPos then begin // Hˆchstwert ¸berschritten
    #         LavaTopPos := Data.Map.LavaPos div 24;
    #         ExecuteScript(Data.Map.Scripts[LavaTopPos], 'lava');
    #       end;
    #       // Auﬂerdem Spielerskript ausf¸hren
    #       if Data.ObjPlayers.Next.PosY div 24 < PlayerTopPos then begin // Hˆchstwert ¸berschritten
    #         PlayerTopPos := Data.ObjPlayers.Next.PosY div 24;
    #         ExecuteScript(Data.Map.Scripts[PlayerTopPos], 'player');
    #       end;
    #       // Und nu die Timerz
    #       ExecuteScript(Data.Map.ScriptTimers[Data.Frame mod 10], 'do');
    #       ExecuteScript(Data.Map.ScriptTimers[10], 'do');
    
    # Rising lava
    if map.lava_time_left == 0 then
      if map.lava_speed != 0 then
        map.lava_pos -= 1 if map.lava_mode == 0 and frame % map.lava_speed == 0
        map.lava_pos -= map.lava_speed if map.lava_mode == 1
        map.lava_frame = (map.lava_frame + 1) % 120
        # if (Data.Frame mod 10 = 0) and (Random(10) = 0) then DistSound(Data.Map.LavaPos, Sound_Lava, Data);
      end
    else
      map.lava_time_left -= 1
    end
    
    if player.pmid != ID_PLAYER then
      @time_left -= 1
      if @time_left == 0 then
        player.pmid = ID_PLAYER
        # TODO CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
      end
    end
    @inv_time_left -= 1 if @inv_time_left > 0
    @view_pos = [[map.lava_pos - 432, player.y - 240, 24096].min, map.level_top].max
    #     end;

    # if Data.State = State_Game then begin
    if fly_time_left == 0 and not player.in_water? then
      if left_pressed? then
        player.instance_eval do
          if not busy? and vx > -ObjectDef[pmid].speed * 1.75 then
            self.vx -= ObjectDef[pmid].speed# + (@speed_time_left > 0 ? 6 : 0).round
          end
          if [ACT_JUMP, ACT_LAND, ACT_PAIN_1, ACT_PAIN_2].include? action then
            (ObjectDef[pmid].jump_x * 2).times { self.x -= 1 unless blocked? DIR_LEFT }
          end
        end
      end
      if right_pressed? then
        player.instance_eval do
          if not busy? and vx < +ObjectDef[pmid].speed * 1.75 then
            self.vx += ObjectDef[pmid].speed# + (@speed_time_left > 0 ? 6 : 0).round
          end
          if [ACT_JUMP, ACT_LAND, ACT_PAIN_1, ACT_PAIN_2].include? action then
            (ObjectDef[pmid].jump_x * 2).times { self.x += 1 unless blocked? DIR_RIGHT }
          end
        end
      end
    end
    # Water and flying controls
    #       ...else with TPMLiving(Data.ObjPlayers.Next) do begin
    #         if (isUp in DXInput.States)    and (VelY > -5) then Dec(VelY);
    #         if (isUp in DXInput.States)    and (VelY > -5) then Dec(VelY);
    #         if (isDown in DXInput.States)  and (VelY < +5) then Inc(VelY);
    #         if (isDown in DXInput.States)  and (VelY < +5) then Inc(VelY);
    #         if (isLeft in DXInput.States)  and (VelX > -4) then Dec(VelX);
    #         if (isRight in DXInput.States) and (VelX < +4) then Inc(VelX);
    #         if (isLeft in DXInput.States)  and (VelX > -4) then Dec(VelX);
    #         if (isRight in DXInput.States) and (VelX < +4) then Inc(VelX);
    #         if not InWater then begin
    #           if VelY < 0 then Inc(VelY); if VelY > 0 then Dec(VelY);
    #           if VelX < 0 then Inc(VelX); if VelX > 0 then Dec(VelX);
    #         end;
    #         if InWater and (VelX + VelY > 1) and (Data.Frame mod 3 = 0) and (Random(5) = 0) then Data.Waves[Sound_Water + Random(2)].Play(False);
    #         if VelX < 0 then Direction := Dir_Left;
    #         if VelX > 0 then Direction := Dir_Right;
    #       end;
    
    if @speed_time_left > 0 then
      @speed_time_left -= 1
      # TODO CastObjects(ID_FXSpark, Random(2), 0, 0, 1, Data.OptEffects, Data.ObjPlayers.Next.GetRect(1, 1), Data.ObjEffects);
    end
    @jump_time_left -= 1 if @jump_time_left > 0
    @fly_time_left -= 1 if @fly_time_left > 0
    
    player.jump     if jump_pressed?
    player.use_tile if use_pressed?
    player.action   if action_pressed?
    player.dispose  if dispose_pressed?
    
    @objects.each &:update
    @objects.reject! &:marked?
    
    if map.lava_time_left == 0 then
      cast_fx rand(2) + 1, rand(2) + 1, 0, 288, map.lava_pos, 576, 8, 1, -3, 1
      #    if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
      #    if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
      #    if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
    end
  end
  
  def draw
    @map.draw
    @objects.each &:draw
    
    # Lava
    @@danger ||= Gosu::Image.load_tiles 'media/danger.png', -2, -2
    offset = if map.lava_time_left == 0 then frame / 2 % 2 else 0 end
    -1.upto(4) do |x|
      @@danger[map.lava_time_left == 0 ? 0 : 1].draw x * 120 + map.lava_frame, map.lava_pos - view_pos + 0, Z_LAVA
    end
    if map.lava_pos < map.level_top + 432 then
      #   for LoopX := -1 to 4 do
      #     for LoopY := 0 to (Data.Map.LevelTop + 432 - Data.Map.LavaPos) div 48 + 1 do
      #   DXImageListPack.Items[Image_Danger].Draw(DXDraw.Surface, LoopX * 120 + Data.Map.LavaFrame, Data.Map.LavaPos - Data.ViewPos + 48 + LoopY * 48 + Integer(Data.Map.LavaTimeLeft = 0) * ((Data.Frame div 2) mod 2), Min(1, Data.Map.LavaTimeLeft) + 2);
    end
    
    draw_status_bar
    
    # Optional progress indicator
    # if Data.OptShowStatus = 1 then begin
    #   DXDraw.Surface.FillRectAlpha(Bounds(2, 38, 8, 404), clGray, 64);
    #   if Data.ObjPlayers.Next.ID > -1 then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.ObjPlayers.Next.PosY / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clNavy, 192);
    #   if (Data.Map.LavaPos <= 24576) and (Data.Map.LavaTimeLeft = 0) then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.Map.LavaPos / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clYellow, 128);
    #   if (Data.Map.LavaPos <= 24576) and (Data.Map.LavaTimeLeft > 0) then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.Map.LavaPos / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clAqua, 128);
    # end;
    
    # // Scriptmessages
    # if (Data.State in [State_Game, State_Paused]) and (MessageOpacity > 0) then
    #   DrawBMPText(MessageText, (640 - Length(MessageText) * 9) div 2, 230, MessageOpacity, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    # 
    # // Game-Over-Schild 
    # if (Data.State = State_Dead) or (Data.State = State_Won) then begin
    #   Inc(Data.FrameFadingBox);
    #   if Data.FrameFadingBox = 33 then Data.FrameFadingBox := 1;
    #   DXImageList.Items[Image_GameDialogs].DrawAdd(DXDraw.Surface, Bounds(200, 160, 240, 120), Data.State - State_Dead, Abs(16 - Data.FrameFadingBox) * 16);
    #   if Data.State = State_Won then begin
    #     if Data.Score > OldHiscore then
    #       DrawBMPText('Punkte: ' + IntToStr(Data.Score) + ' (neuer Hiscore)', 320 - Round((Length(IntToStr(Data.Score)) + 24) * 4.5), 220, 255 - Min(Abs(16 - Data.FrameFadingBox) * 16, 255), DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality)
    #     else
    #       DrawBMPText('Punkte: ' + IntToStr(Data.Score), 320 - Round((Length(IntToStr(Data.Score)) + 8) * 4.5), 220, 255 - Min(Abs(16 - Data.FrameFadingBox) * 16, 255), DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #   end;
    # end;
    # 
    # // Pause-Schriftzug
    # if Data.State = State_Paused then begin
    #   DXImageList.Items[Image_GameDialogs].DrawAdd(DXDraw.Surface, Bounds(200, 120, 240, 120), 2, 255);
    # end;
    
    draw_centered_string "Punkte: #{score}", WIDTH / 2, 5
  end
  
  def button_down id
    return State.current = LevelSelection.new if id == Gosu::KbEscape
    
    #     if Data.State in [State_Game, State_Paused, State_Dead] then begin
    #       if Data.State in [State_Game, State_Paused] then Log.Add('Level abgebrochen.');
    #       if QuickStart then Close else DXWaveList.Items[Sound_WooshBack].Play(False);
    #       Data.State := State_LevelSelection;
    #       Exit;
    #     end;
    #   // P: Pause an/aus
    #   if Key = Ord('P') then begin
    #     if Data.State = State_Paused then begin Data.State := State_Game; Exit; end else
    #       if Data.State = State_Game then begin Data.State := State_Paused; Exit; end;
    #   end;
    #     State_Game: case Key of
    player.jump     if jump?    id and fly_time_left == 0
    player.use_tile if use?     id and fly_time_left == 0
    player.action   if action?  id
    player.dispose  if dispose? id
    #     end;
    #     State_Dead: if Key = VK_Return then
    #       begin if QuickStart then StartGame(ParamStr(1)) else StartGame(TPMLevelInfo(LevelList.Items[SelectedLevel]).Location); DXWaveList.Items[Sound_Woosh].Play(False); end;
    #     State_Won: if Key = VK_Return then begin
    #                  Data.State := State_WonInfo;
    #                  if Data.Score > OldHiscore then begin
    #                    OptionFile := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
    #                    if QuickStart then
    #                      OptionFile.WriteString('Hiscore', ExtractFileName(ExtractShortPathName(ParamStr(1))), Muesli(Data.Score))
    #                    else
    #                      OptionFile.WriteString('Hiscore', ExtractFileName(ExtractShortPathName(TPMLevelInfo(LevelList[SelectedLevel]).Location)), Muesli(Data.Score));
    #                    OptionFile.Free;
    #                    if not QuickStart then TPMLevelInfo(LevelList[SelectedLevel]).Hiscore := Data.Score;
    #                  end;
    #                  Log.Add('Level beendet.');
    #                  if QuickStart then Close else DXWaveList.Items[Sound_Woosh].Play(False);
    #                end;
    #     State_WonInfo: if not (ssAlt in Shift) then begin Data.State := State_LevelSelection; DXWaveList.Items[Sound_Woosh].Play(False); end;
    
  end
  
  def cast_objects pmid, num, vx, vy, randomness, rect
    num.times do
      obj = create_object pmid, rect.left + rand(rect.width), rect.top + rand(rect.height), nil
      obj.vx = vx - randomness + rand(randomness * 2 + 1)
      obj.vy = vy - randomness + rand(randomness * 2 + 1)
    end
  end
  
  def cast_fx smoke, flames, sparks, x, y, *args
    return if (view_pos + HEIGHT / 2 - y).abs > HEIGHT
    
    cast_single_fx ID_FX_SMOKE, smoke,  x, y, *args
    cast_single_fx ID_FX_FLAME, flames, x, y, *args
    cast_single_fx ID_FX_SPARK, sparks, x, y, *args
  end

  def create_object pmid, x, y, xdata
    cls = case pmid
      when 0..ID_LIVING_MAX then LivingObject
      when ID_OTHER_OBJECTS_MIN..ID_OTHER_OBJECTS_MAX then GameObject
      when ID_COLLECTIBLE_MIN..ID_COLLECTIBLE_MAX then CollectibleObject
      when ID_FX_MIN..ID_FX_MAX then EffectObject
    end
    
    obj = cls.new(self, pmid, x, y, xdata)
    @objects << obj
    obj
  end
  
  def find_object min_id, max_id, rect
    @objects.find { |o| o.pmid >= min_id and o.pmid <= max_id and rect.include? o }
  end
  
  private
  
  def draw_status_bar
    @@gui ||= Gosu::Image.load_tiles 'media/gui.bmp', -4, -11
    Gosu::translate(576, 0) do
      tile_w = @@gui.first.width
      tile_h = @@gui.first.height
      
      draw_digits = lambda do |num, row|
        left_digit  = [num, 99].min / 10 * 2 + 20
        right_digit = [num, 99].min % 10 * 2 + 21
        @@gui[left_digit].draw  tile_w * 2, tile_h * row, Z_UI
        @@gui[right_digit].draw tile_w * 3, tile_h * row, Z_UI
      end

      # Game logo and spacing
      0.upto(3) do |x|
        @@gui[x + 0].draw tile_w * x, tile_h * 0, Z_UI
        @@gui[x + 4].draw tile_w * x, tile_h * 1, Z_UI
      end
      # Health
      if true then # TODO player.alive?
        @@gui[8].draw tile_w * 0, tile_h * 2, Z_UI
        @@gui[9].draw tile_w * 1, tile_h * 2, Z_UI
        draw_digits.call player.life, 2
      else
        0.upto(3) { |x| @@gui[x + 4].draw tile_w * x, tile_h * 2, Z_UI }
      end
      # Keys
      @@gui[10].draw tile_w * 0, tile_h * 3, Z_UI
      @@gui[11].draw tile_w * 1, tile_h * 3, Z_UI
      draw_digits.call keys, 3
      # Stars
      @@gui[12].draw tile_w * 0, tile_h * 4, Z_UI
      @@gui[13].draw tile_w * 1, tile_h * 4, Z_UI
      draw_digits.call stars, 4
      if stars > stars_goal then
        # Enough stars - draw checkmark
        @@gui[42].draw tile_w * 2, tile_h * 4, Z_UI
        @@gui[43].draw tile_w * 3, tile_h * 4, Z_UI
      end
      if stars_goal == 0 then
        # Or blank the line out of no stars are needed
        0.upto(3) { |x| @@gui[x + 4].draw tile_w * x, tile_h * 4, Z_UI }
      end
      # Remaining special peter time
      if player.pmid == ID_PLAYER then
        0.upto(3) { |x| @@gui[x + 4].draw tile_w * x, tile_h * 5, Z_UI }
      else
        @@gui[14].draw tile_w * 0, tile_h * 5, Z_UI
        @@gui[15].draw tile_w * 1, tile_h * 5, Z_UI
        draw_digits.call time_left / TARGET_FPS, 5
      end
      # Ammo
      @@gui[16].draw tile_w * 0, tile_h * 6, Z_UI
      @@gui[17].draw tile_w * 1, tile_h * 6, Z_UI
      draw_digits.call ammo, 6
      # Bombs
      @@gui[18].draw tile_w * 0, tile_h * 7, Z_UI
      @@gui[19].draw tile_w * 1, tile_h * 7, Z_UI
      draw_digits.call bombs, 7
      # Remaining time for frozen lava
      if map.lava_time_left == 0 then
        0.upto(3) { |x| @@gui[x + 4].draw tile_w * x, tile_h * 8, 0 }
      else
        @@gui[40].draw tile_w * 0, tile_h * 8, Z_UI
        @@gui[41].draw tile_w * 1, tile_h * 8, Z_UI
        draw_digits.call map.lava_time_left / TARGET_FPS, 8
      end
      # Spacing
      0.upto(3) { |x| @@gui[x + 4].draw tile_w * x, tile_h * 9, Z_UI }
    end
  end
  
  # TODO Merge into cast_objects
  def cast_single_fx pmid, num, x, y, w, h, vx, vy, randomness
    num.times do
      x = [[x - w / 2 + rand(w + 1), 0].max, 575].min
      y =   y - h / 2 + rand(h + 1)
      fx = create_object(pmid, x, y, nil)
      fx.vx = vx - randomness + rand(randomness * 2 + 1)
      fx.vy = vy - randomness + rand(randomness * 2 + 1)
    end
  end  
end
