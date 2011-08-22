class Game < State
  attr_reader :player, :map
  attr_reader :view_pos, :frame
  attr_reader :inv_time_left, :speed_time_left, :jump_time_left, :fly_time_left
  attr_reader :obj_vars
  
  def initialize level_info
    @view_pos = TILES_Y * TILE_SIZE - HEIGHT # TODO
    
    @player_top_pos = 1024
    @lava_top_pos = 1024
    @message_text = ''
    @message_opacity = 0
    @frame = -1
    @frame_fading_box = 16
    @inv_time_left = @speed_time_left = @jump_time_left = @fly_time_left = 0
    @keys = @stars = @ammo = @bombs = 0
    @score = 0
    
    @lava_frame = 0
    @lava_time_left = 0
    
    @objects = []
    @obj_vars = [nil] * 16
    
=begin
      // Wenn ¸berladen, dann schonmal Kopie der alten speichern
      OverloadedTiles := TStringList.Create;
      Level_pml.ReadSection('Tiles', OverloadedTiles);
      if OverloadedTiles.Count > 0 then begin
        // Originaltiles speichern
        DXImageListPack.Items[Image_Tiles].Picture.SaveToFile(TempPath + '\PMTempOV.bmp');
        // Originaltiles in NewTiles laden
        NewTiles := TBitmap.Create;
        NewTiles.LoadFromFile(TempPath + '\PMTempOV.bmp');
        // ‹berladene Tiles einlesen
        for LoopT := 0 to 255 do begin
          Row := Level_pml.ReadString('Tiles', IntToHex(LoopT, 2), '');
          if Length(Row) = 3456 then begin
            Log.Add('Tile ' + IntToHex(LoopT, 2) + ' ¸berladen.');
            for LoopY := 0 to 23 do
              for LoopX := 0 to 23 do
                NewTiles.Canvas.Pixels[(LoopT mod 16) * 24 + LoopX, (LoopT div 16) * 24 + LoopY]
                  := StringToColor('$02' + Copy(Row, 5 + 6 * (LoopY + LoopX * 24), 2) + Copy(Row, 3 + 6 * (LoopY + LoopX * 24), 2) + Copy(Row, 1 + 6 * (LoopY + LoopX * 24), 2));
          end;
        end;
        // Datei speichern und wieder einladen
        NewTiles.SaveToFile(TempPath + '\PMTempOV.bmp');
        DXImageListPack.Items[Image_Tiles].Picture.LoadFromFile(TempPath + '\PMTempOV.bmp');
        DXImageListPack.Items[Image_Tiles].Restore;
        // Newtiles und tempor‰re Datei lˆschen
        NewTiles.Free;
        DeleteFile(TempPath + '\PMTempOV.bmp');
      end;
      OverLoadedTiles.Free;
=end
    
    @map = Map.new(self, level_info.ini_file)
    
    player_x = (level_info.ini_file['Objects', 'PlayerX'] || 288).to_i
    player_y = (level_info.ini_file['Objects', 'PlayerY'] || 24515).to_i
    @player = LivingObject.new(self, ID_PLAYER, player_x, player_y, nil)
    @player.vx = (level_info.ini_file['Objects', 'PlayerVX'] || 0).to_i
    @player.vy = (level_info.ini_file['Objects', 'PlayerVY'] || 0).to_i
    @player.life = (level_info.ini_file['Objects', 'PlayerLife'] || ObjectDef[ID_PLAYER].life).to_i
    @player.direction = (level_info.ini_file['Objects', 'PlayerDirection'] || rand(2)).to_i
    @player.action = ACT_STAND
    @objects << @player
    
    # If the player starts as a Special Peter, give him some time
    @time_left = @player.pmid == ID_PLAYER ? 0 : ObjectDef[@player.pmid].life
    
    i = 0
    while obj_string = level_info.ini_file['Objects', i] do
      pmid, x, y = obj_string.split('|').map { |str| str.to_i(16) }
      GameObject.create self, pmid, x, y, level_info.ini_file['Objects', "#{x}Y"]
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
    
    if @player.pmid != ID_PLAYER then
      @time_left -= 1
      if @time_left == 0 then
        @player.pmid = ID_PLAYER
        # TODO CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
      end
    end
    @inv_time_left -= 1 if @inv_time_left > 0
    @view_pos = [[map.lava_pos - 432, @player.y - 240, 24096].min, map.level_top].max
    #     end;

    # if Data.State = State_Game then begin
    if fly_time_left == 0 and not @player.in_water? then
      if left_pressed? then
        @player.instance_eval do
          if not busy? and vx > -ObjectDef[pmid].speed * 1.75 then
            self.vx -= ObjectDef[pmid].speed# + (@speed_time_left > 0 ? 6 : 0).round
          end
          if [ACT_JUMP, ACT_LAND, ACT_PAIN_1, ACT_PAIN_2].include? action then
            (ObjectDef[pmid].jump_x * 2).times { self.x -= 1 unless blocked? DIR_LEFT }
          end
        end
      end
      if right_pressed? then
        @player.instance_eval do
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
    
    @player.jump     if jump_pressed?
    @player.use_tile if use_pressed?
    @player.action   if action_pressed?
    
    
    #       if DXInput.Keyboard.Keys[VK_Up] or DXInput.Joystick.Buttons[0] and (Data.FlyTimeLeft = 0) then TPMLiving(Data.ObjPlayers.Next).Jump;
    #       if DXInput.Keyboard.Keys[VK_Down] or DXInput.Joystick.Buttons[2] and (Data.FlyTimeLeft = 0) then TPMLiving(Data.ObjPlayers.Next).UseTile;
    #       if DXInput.Keyboard.Keys[VK_Space] or DXInput.Joystick.Buttons[1] then TPMLiving(Data.ObjPlayers.Next).Special;
    #       if DXInput.Joystick.Buttons[3] then begin
    #         if (Data.Frame = -1) or (Data.ObjPlayers.Next.ID = ID_Player) then Exit;
    #         Data.ObjPlayers.Next.ID := ID_Player;
    #         if TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead then TPMLiving(Data.ObjPlayers.Next).Action := Act_Jump;
    #         CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
    #         Exit;
    #       end;
    
    @objects.each &:update
    @objects.reject! &:marked?
    #  // Jetzt noch die kaputten lˆschen
    #  TempObj := Data.ObjCollectibles.Next;
    #  while TempObj <> nil do begin
    #    if TempObj.Last.Marked then TempObj.Last.ReallyKill;
    #    TempObj := TempObj.Next;
    #  end;
       
    #  // Ab und zu mal ein Rauchwˆlkchen und Flammen aus der Lava steigen lassen...
    #  if Data.Map.LavaTimeLeft = 0 then begin
    #    CastFX(Random(2) + 1, Random(2) + 1, 0, 288, Data.Map.LavaPos, 576, 8, 1, -4, 1, Data.OptEffects, Data.ObjEffects);
    #    if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
    #    if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
    #    if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
    #  end;
    
  end
  
  def draw
    @map.draw
    @objects.each &:draw
    
    # Lava
    @@danger ||= Gosu::Image.load_tiles 'media/danger.png', -2, -2
    offset = if map.lava_time_left == 0 then frame / 2 % 2 else 0 end
    -1.upto(4) do |x|
      @@danger[map.lava_time_left == 0 ? 0 : 1].draw x * 120 + map.lava_frame, map.lava_pos - view_pos + 0, 0
    end
    if map.lava_pos < map.level_top + 432 then
      #   for LoopX := -1 to 4 do
      #     for LoopY := 0 to (Data.Map.LevelTop + 432 - Data.Map.LavaPos) div 48 + 1 do
      #   DXImageListPack.Items[Image_Danger].Draw(DXDraw.Surface, LoopX * 120 + Data.Map.LavaFrame, Data.Map.LavaPos - Data.ViewPos + 48 + LoopY * 48 + Integer(Data.Map.LavaTimeLeft = 0) * ((Data.Frame div 2) mod 2), Min(1, Data.Map.LavaTimeLeft) + 2);
    end
    
    # // Dann noch die Leiste dr¸ber
    # // Das gˆttliche P
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 0, 0);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 0, 1);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 0, 2);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 0, 3);
    # // Leerzeile
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 48, 4);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 48, 5);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 48, 6);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 48, 7);
    # // Energie
    # if Data.ObjPlayers.Next <> Data.ObjEffects then begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 96, 8);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 96, 9);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 96, Min(TPMLiving(Data.ObjPlayers.Next).Life, 99) div 10 * 2 + 20);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 96, Min(TPMLiving(Data.ObjPlayers.Next).Life, 99) mod 10 * 2 + 21);
    # end else begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 96, 8);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 96, 9);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 96, 20);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 96, 21);
    # end;
    # // Schl¸ssel
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 144, 10);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 144, 11);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 144, Min(Data.Keys, 99) div 10 * 2 + 20);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 144, Min(Data.Keys, 99) mod 10 * 2 + 21);
    # // Sterne
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 192, 12);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 192, 13);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 192, Min(Data.Stars, 99) div 10 * 2 + 20);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 192, Min(Data.Stars, 99) mod 10 * 2 + 21);
    # // Wenn genug, dann H‰kchen
    # if Data.Stars >= Data.StarsGoal then begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 192, 42);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 192, 43);
    # end;
    # // Wenn gar keine benˆtigt, dann nix
    # if Data.StarsGoal = 0 then begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 192, 4);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 192, 5);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 192, 6);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 192, 7);
    # end;
    # // ‹brige Spezialpeterzeit
    # if Data.ObjPlayers.Next.ID < 1 then begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 240, 4);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 240, 5);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 240, 6);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 240, 7);
    # end else begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 240, 14);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 240, 15);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 240, (Data.TimeLeft div 20) div 10 * 2 + 20);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 240, Data.TimeLeft div 20 mod 10 * 2 + 21);
    # end;
    # // Munition
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 288, 16);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 288, 17);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 288, Min(Data.Ammo, 99) div 10 * 2 + 20);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 288, Min(Data.Ammo, 99) mod 10 * 2 + 21);
    # // Bomben
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 336, 18);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 336, 19);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 336, Min(Data.Bombs, 99) div 10 * 2 + 20);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 336, Min(Data.Bombs, 99) mod 10 * 2 + 21);
    # // ‹brige Lavafrierzeit
    # if Data.Map.LavaTimeLeft = 0 then begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 384, 4);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 384, 5);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 384, 6);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 384, 7);
    # end else begin
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 384, 40);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 384, 41);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 384, Min(Data.Map.LavaTimeLeft div 20, 99) div 10 * 2 + 20);
    #   DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 384, Min(Data.Map.LavaTimeLeft div 20, 99) mod 10 * 2 + 21);
    # end;
    # 
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 432, 4);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 432, 5);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 432, 6);
    # DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 432, 7);
    # 
    # // Levelfortschrittsanzeige (wenn aktiviert)
    # if Data.OptShowStatus = 1 then begin
    #   DXDraw.Surface.FillRectAlpha(Bounds(2, 38, 8, 404), clGray, 64);
    #   if Data.ObjPlayers.Next.ID > -1 then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.ObjPlayers.Next.PosY / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clNavy, 192);
    #   if (Data.Map.LavaPos <= 24576) and (Data.Map.LavaTimeLeft = 0) then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.Map.LavaPos / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clYellow, 128);
    #   if (Data.Map.LavaPos <= 24576) and (Data.Map.LavaTimeLeft > 0) then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.Map.LavaPos / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clAqua, 128);
    # end;
    # 
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
    # 
    # // Und noch die Punkte
    # DrawBMPText('Punkte: ' + IntToStr(Data.Score), 320 - Round((Length(IntToStr(Data.Score)) + 8) * 4.5), 25, 160, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    # DXDraw.Flip;
  end
  
  def button_down id
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
    @player.jump     if jump?   id and fly_time_left == 0
    @player.use_tile if use?    id and fly_time_left == 0
    @player.action   if action? id
    #       VK_Space: TPMLiving(Data.ObjPlayers.Next).Special;
    #       VK_Delete, VK_Return: begin
    #                    if (Data.Frame = -1) or (Data.ObjPlayers.Next.ID = ID_Player) then Exit;
    #                    Data.ObjPlayers.Next.ID := ID_Player;
    #                    if TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead then TPMLiving(Data.ObjPlayers.Next).Action := Act_Jump;
    #                    CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
    #                    Exit;
    #                  end;
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
  
end
