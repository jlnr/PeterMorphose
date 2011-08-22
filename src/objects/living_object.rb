class LivingObject < GameObject
  attr_accessor :life, :action, :direction
  
  def initialize *args
    super
    
    @life = ObjectDef[pmid].life
    @action = 0
    @direction = rand(2)
  end
  
  def busy?
    not blocked? DIR_DOWN or not action.between? ACT_STAND, ACT_WALK_4
  end
  
  def draw
    return if [ACT_INV_UP, ACT_INV_UP].include? action
    
    case pmid
    when ID_PLAYER..ID_PLAYER_BOMBER then
      # TODO wings
      # if (Data.FlyTimeLeft > 0) then case Direction of
      #   Dir_Left: begin
      #     Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 18, PosY - 12 - Data.ViewPos, 18, 24), 38 + (Data.Frame div 2) mod 4, Min(Data.FlyTimeLeft * 2 + 16, 255));
      #     Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX, PosY - 12 - Data.ViewPos, 24, 24), 42 + (Data.Frame div 2) mod 4, Min(Data.FlyTimeLeft * 2 + 16, 255));
      #   end;
      #   Dir_Right: begin
      #     Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 24, PosY - 12 - Data.ViewPos, 24, 24), 38 + (Data.Frame div 2) mod 4, Min(Data.FlyTimeLeft * 2 + 16, 255));
      #     Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX, PosY - 12 - Data.ViewPos, 18, 24), 42 + (Data.Frame div 2) mod 4, Min(Data.FlyTimeLeft * 2 + 16, 255));
      #   end;
      # end;
      if game.inv_time_left == 0 or type = ID_PLAYER_BERSERKER then
        color = 0xa0ffffff
      else
        color = 0xffffffff
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
      @@enemy_images[ACT_NUM * (direction + (pmid - ID_ENEMY) * 2) + action].draw x - 11, y - 11 - game.view_pos, 0
    end
  end
  
  def update
    # Runterfallen
    fall if action < ACT_INV_UP

    # Roasted by lava
    if y + ObjectDef[pmid].rect.bottom > game.map.lava_pos then
      # ... CastFX(8, 8, 0, PosX, PosY, 16, 16, 0, -4, 1, Data.OptEffects, Data.ObjEffects);
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
    if action == ACT_INV_UP then
      except_open_doors = (0..TILE_STAIRS_UP_LOCKED).to_a + [TILE_STAIRS_DOWN_LOCKED]
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
    end
    # if Action = Act_InvDown then begin
    #   if Random(7) = 0 then DistSound(PosY, Sound_StairsRnd, Data^);
    #   if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Inc(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    #   if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Inc(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    #   if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Inc(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    #   if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then begin Inc(PosY, 2); Exit; end else PosX := PosX div 24 * 24 + 12;
    # end;
    
    check_tile if action != ACT_DEAD
    
    # // Brüchigen Boden unter den Füßen einstürzen lassen
    # BreakFloor(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 2);
    # BreakFloor(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 2);
    
    return if action == ACT_DEAD
    
    # // In Wasser blubbern
    # if InWater then begin
    #   if (Random(30) = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 7, 0, 0);
    #   if ID = ID_PlayerBerserker then begin ID := ID_Player; CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects); end;
    #   if ID = ID_EnemyBerserker then begin ID := ID_Enemy; CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects); end;
    # end;
    
    # // Türen aufschließen
    # if (ID <= ID_PlayerMax) and (Data.Keys > 0) then with Data^ do begin
    #   // Nach links
    #   Target := Map.Tile(PosX + Defs[ID].Rect.Left - 1, PosY);
    #   if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
    #     Map.Tiles[(PosX + Defs[ID].Rect.Left - 1) div 24, PosY div 24]
    #       := Tile_OpenDoor + Target - Tile_ClosedDoor;
    #     Dec(Data.Keys);
    #     Data.Waves[Sound_Door + Random(2)].Play(False);
    #   end;
    #   // Nach rechts
    #   Target := Map.Tile(PosX + Defs[ID].Rect.Left + Defs[ID].Rect.Right + 1, PosY);
    #   if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
    #     Map.Tiles[(PosX + Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right + 1) div 24, PosY div 24]
    #       := Tile_OpenDoor + Target - Tile_ClosedDoor;
    #     Dec(Data.Keys);
    #     Data.Waves[Sound_Door + Random(2)].Play(False);
    #   end;
    #   // Nach Oben
    #   Target := Map.Tile(PosX, PosY + Defs[ID].Rect.Top - 1);
    #   if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
    #     Map.Tiles[PosX div 24, (PosY + Defs[ID].Rect.Top -1) div 24]
    #       := Tile_OpenDoor + Target - Tile_ClosedDoor;
    #     Dec(Keys);
    #     Data.Waves[Sound_Door + Random(2)].Play(False);
    #   end;
    #   // Nach unten
    #   Target := Map.Tile(PosX, PosY + Defs[ID].Rect.Top + Defs[ID].Rect.Bottom + 1);
    #   if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
    #     Map.Tiles[PosX div 24, (PosY + Defs[ID].Rect.Top + Defs[ID].Rect.Bottom + 1) div 24]
    #       := Tile_OpenDoor + Target - Tile_ClosedDoor;
    #     Dec(Keys);
    #     Data.Waves[Sound_Door + Random(2)].Play(False);
    #   end;
    # end;
    # 
    # // Spezialaktionen von Peter
    # // Player - bei Act_Action3 Schalter umlegen
    # if (ID = ID_Player) and (Action = Act_Action3) and (Data.Frame mod 2 = 0) then begin
    #   TargetObj := FindObject(Data.ObjOther, Data.ObjEnemies, ID_Lever, ID_LeverRight, GetRect(12, 3));
    #   if TargetObj <> nil then begin
    #     Data.Waves[Sound_Lever].Play(False);
    #     case TargetObj.ID of
    #       ID_Lever:      TargetObj.ID := ID_LeverDown;
    #       ID_LeverLeft:  TargetObj.ID := ID_LeverRight;
    #       ID_LeverRight: TargetObj.ID := ID_LeverLeft;
    #     end;
    #     if Length(TargetObj.ExtraData) < 1 then Exit;
    #     if TargetObj.ExtraData[1] in ['0'..'9', 'A'..'F'] then
    #       for Loop := 0 to StrToIntDef('$' + TargetObj.ExtraData[1], 0) - 1 do begin
    #         Target := Data.Map.Tiles[StrToInt('$' + Copy(TargetObj.ExtraData, 3 + Loop * 10, 2)), StrToInt('$' + Copy(TargetObj.ExtraData, 6 + Loop * 10, 3))];
    #         Data.Map.Tiles[StrToInt('$' + Copy(TargetObj.ExtraData, 3 + Loop * 10, 2)), StrToInt('$' + Copy(TargetObj.ExtraData, 6 + Loop * 10, 3))]
    #           := StrToInt('$' + Copy(TargetObj.ExtraData, 10 + Loop * 10, 2));
    #         TargetObj.ExtraData[10 + Loop * 10] := IntToHex(Target, 2)[1];
    #         TargetObj.ExtraData[11 + Loop * 10] := IntToHex(Target, 2)[2];
    #         CastFX(8, 0, 0, StrToInt('$' + Copy(TargetObj.ExtraData, 3 + Loop * 10, 2)) * 24 + 10, StrToInt('$' + Copy(TargetObj.ExtraData, 6 + Loop * 10, 3)) * 24 + 12, 24, 24, 0, 0, 2, Data.OptEffects, Data.ObjEffects);
    #       end
    #     else Data.ExecuteScript(Copy(TargetObj.ExtraData, 3, Length(TargetObj.ExtraData) - 2), 'do');
    #   end;
    # end;
    # // Kampfpeter - zuschlagen
    # if (ID = ID_PlayerFighter) and (Action in [Act_Action1..Act_Action5]) then begin
    #   if Direction = Dir_Left then TargetLiv := FindLiving(Data.ObjEnemies, Data.ObjPlayers, ID_Enemy, ID_EnemyMax, 0, Act_Pain1 - 1, Bounds(PosX - 17, PosY - 16, 22, 32))
    #                           else TargetLiv := FindLiving(Data.ObjEnemies, Data.ObjPlayers, ID_Enemy, ID_EnemyMax, 0, Act_Pain1 - 1, Bounds(PosX -  5, PosY - 16, 22, 32));
    #   if TargetLiv <> nil then begin
    #     TargetLiv.Hit;
    #     TargetLiv.Fling(5 * RealDir(Direction), -4, 1, True, True);
    #     if TargetLiv.Action = Act_Dead then begin
    #       Inc(Data.Score, Data.Defs[TargetLiv.ID].Life * 3);
    #       if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TargetLiv.ID].Life * 3) + ' Punkte!', ID_FXText, TargetLiv.PosX, TargetLiv.PosY - 10, 0, -1);
    #     end;
    #   end;
    # end;
    # // PlayerGun - bei Act_Action 5 schießen
    # if (ID = ID_PlayerGun) and (Action = Act_Action5) then begin
    #   Dec(Data.Ammo);
    #   TargetLiv := TPMLiving(LaunchProjectile(PosX, PosY + 2, Direction, Data.ObjEnemies, Data.ObjPlayers, Data.ObjEffects, Data^));
    #   if TargetLiv <> nil then begin
    #     TargetLiv.Hurt(True);
    #     TargetLiv.Fling(3 * RealDir(Direction), -3, 1, True, True);
    #     if TargetLiv.Action = Act_Dead then begin
    #       Inc(Data.Score, Data.Defs[TargetLiv.ID].Life * 3);
    #       if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TargetLiv.ID].Life * 3) + ' Punkte!', ID_FXText, TargetLiv.PosX, TargetLiv.PosY - 10, 0, -1);
    #     end;
    #   end;
    # end;
    # // Feuerpeter - BRUZZELN!!!11 >>>>>:::::------))))))999
    # if ID = ID_PlayerBerserker then begin
    #   // FX (harlow flekso *rofz)
    #   CastFX(Random(2), 2 + Random(2), 0, PosX, PosY, 18, 24, 0, -3, 2, Data.OptEffects, Data.ObjEffects);
    #   // Gegner fer brenen (höhöhö</köps>)
    #   TargetObj := Data.ObjEnemies.Next;
    #   while TargetObj <> Data.ObjPlayers do begin
    #     if (TPMLiving(TargetObj).Action < Act_Dead) and TargetObj.RectCollision(GetRect(2, 2)) then begin
    #       TPMLiving(TargetObj).Hurt(False);
    #       if TPMLiving(TargetObj).Action = Act_Dead then begin
    #         Inc(Data.Score, Data.Defs[TargetObj.ID].Life * 3);
    #         if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TargetObj.ID].Life * 3) + ' Punkte!', ID_FXText, TargetObj.PosX, TargetObj.PosY - 10, 0, -1);
    #       end;
    #     end;
    #     TargetObj := TargetObj.Next;
    #   end;
    # end;
    # 
    # // Feuergegner - KONTERBRUZZELN!!!!11
    # if ID = ID_EnemyBerserker then begin
    #   // EFIX
    #   CastFX(0, Random(3), 0, PosX, PosY, 18, 24, 0, -2, 3, Data.OptEffects, Data.ObjEffects);
    #   // Spiler fer brenen (höhöhö</köps>)
    #   if (TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead) and Data.ObjPlayers.Next.RectCollision(GetRect(5, 2)) then begin
    #     TPMLiving(Data.ObjPlayers.Next).Hit;
    #     Data.ObjPlayers.Next.Fling(8 * RealDir(Direction), -3, 0, True, True);
    #     Fling(-8 * RealDir(Direction), -4, 0, True, False);
    #     Exit;
    #   end;
    # end;
    # 
    # // Bombenleger - bei Act_Action4 Bombe hinlegen =)))))9999
    # if (ID = ID_PlayerBomber) and (Action = Act_Action4) and (Data.Frame mod 3 = 0) then begin
    #   Dec(Data.Bombs);
    #   TPMObject.Create(Data.ObjOther, '0', ID_FusingBomb, PosX + RealDir(Direction) * 5, PosY + 2, RealDir(Direction) * 8, -3);
    # end;
    
    if pmid <= ID_PLAYER_MAX and not busy? then
      self.direction = DIR_LEFT  if vx < 0
      self.direction = DIR_RIGHT if vx > 0
    end;

    # // Schießen bei Enemy_Gun
    # if (ID = ID_EnemyGun) and (Action = Act_Action5) then begin
    #   if PosX <= Data.ObjPlayers.Next.PosX then TempDir := Dir_Right else TempDir := Dir_Left;
    #   TargetLiv := TPMLiving(LaunchProjectile(PosX, PosY + 2, TempDir, Data.ObjPlayers, Data.ObjEffects, Data.ObjEffects, Data^));
    #   if TargetLiv <> nil then begin
    #     TargetLiv.Hit;
    #     TargetLiv.Fling(3 * RealDir(TempDir), -3, 1, True, True);
    #   end;
    # end;
    # 
    # // Gegner-"KI"
    # if (ID > ID_PlayerMax) and not Busy then begin
    #   // Wände = Hindernis; Hindernis = Umdrehen
    #   if Blocked(Direction) then Direction := OtherDir(Direction);
    #   // Die Gegner sind f0l schlau und rennen _nicht_ in Abgründe...
    #   // Durch die Gegend rennen
    #   if (((ID = ID_EnemyFighter) and (Data.Frame mod 100 < 70))
    #   or ((ID = ID_EnemyGun) and (Data.Frame mod 100 > 15))
    #   or (ID in [ID_Enemy, ID_EnemyBerserker, ID_EnemyBomber]))
    #   and not Data.Map.Solid(PosX + RealDir(Direction) * 7,
    #                         PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) then
    #     if (Length(ExtraData) > 0) and (ExtraData[1] = '1') then Jump
    #         else Direction := OtherDir(Direction);
    #   // Spezialtiles aktivieren (manchmal und wenn ExtraData[3] = 1)
    #   if (Random(100) = 0) and (Length(ExtraData) > 2) and (ExtraData[3] = '1') then begin UseTile; Exit; end;
    #   // Durch die Gegend rennen
    #   if ((ID = ID_EnemyFighter) and (Data.Frame mod 100 < 70))
    #   or ((ID = ID_EnemyGun) and (Data.Frame mod 100 > 15))
    #   or (ID in [ID_Enemy, ID_EnemyBerserker, ID_EnemyBomber])
    #     then Inc(VelX, Data.Defs[ID].Speed * RealDir(Direction));
    #   // Spieler in Sicht, ATTACKKKÄÄÄÄHHH!
    #   if (ID = ID_EnemyFighter) and Data.ObjPlayers.Next.RectCollision(Bounds(PosX - 120 + (Ord(Direction) * 120), PosY - 24, 120, 48))
    #     and Data.Map.Solid(PosX + RealDir(Direction) * 7, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) and (TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead)
    #       then VelX := Data.Defs[ID].Speed * 2 * RealDir(Direction);
    #   // Spieler in Sicht, TOTSNIPEX0RN !!!11
    #   if (ID = ID_EnemyGun) and PointInRect(Point(Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY), GetRect(320, 1)) and (TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead)then begin
    #     Target := 1;
    #     for Loop := 0 to Abs(Data.ObjPlayers.Next.PosX - PosX) div 24 do
    #       if Data.Map.Solid(Loop * 24 + Min(Data.ObjPlayers.Next.PosX, PosX), PosY) then Target := 0;
    #     if Target = 1 then begin Action := Act_Action1; Exit; end;
    #   end;
    #   // Spieler umrempeln
    #   if RectCollision(Data.ObjPlayers.Next.GetRect(1, -1))
    #     and not (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Pain1, Act_Pain2, Act_Dead, Act_InvUp, Act_InvDown]) then begin
    #       if ID = ID_EnemyBomber then TPMLiving(Data.ObjPlayers.Next).Hurt(True)
    #                                 else TPMLiving(Data.ObjPlayers.Next).Hit;
    #       Data.ObjPlayers.Next.Fling(8 * RealDir(Direction), -3, 0, True, True);
    #       Fling(-6 * RealDir(Direction), -2, 0, True, False);
    #       if ID = ID_EnemyBomber then begin
    #         Kill;
    #         CastFX(10, 30, 10, PosX, PosY, 10, 10, 0, -10, 5, Data.OptEffects, Data.ObjEffects);
    #       end;
    #       Exit;
    #     end;
    # end;
    # 
    # // Spieler auch im Sprung umrempeln
    # if (ID > ID_PlayerMax) and (Action in [Act_Jump, Act_Land]) and RectCollision(Data.ObjPlayers.Next.GetRect(0, -1))
    #   and not (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Pain1, Act_Pain2, Act_Dead, Act_InvUp, Act_InvDown]) then begin
    #     if ID = ID_EnemyBomber then TPMLiving(Data.ObjPlayers.Next).Hurt(True)
    #                            else TPMLiving(Data.ObjPlayers.Next).Hit;
    #     Data.ObjPlayers.Next.Fling(8 * RealDir(Direction), -4, 0, True, True);
    #     Fling(-7 * RealDir(Direction), 4, 1, True, False);
    #     if ID = ID_EnemyBomber then begin
    #       Kill;
    #       CastFX(10, 30, 10, PosX, PosY, 10, 10, 0, -10, 5, Data.OptEffects, Data.ObjEffects);
    #     end;
    #     Exit;
    #   end;
    # 
    
    # Fly
    if pmid <= ID_PLAYER_MAX and game.fly_time_left > 0 and not (ACT_ACTION_1..ACT_ACTION_5).include? action then
      self.action = vy < 0 ? ACT_JUMP : ACT_LAND
      return
    end
    
    # Hurt player cannot recover until on the ground
    return if [ACT_PAIN_1, ACT_PAIN_2].include? action and not blocked? DIR_DOWN and not in_water?
    
    # // Hingefallen, weiter aufstehen
    # if (Action >= Act_Impact1) and (Action <= Act_Impact5) and (Data.Frame mod 2 = 0) then Exit;
    # if (Action >  Act_Impact1) and (Action <= Act_Impact5) then begin Dec(Action); Exit; end;
    # // Spezialaktion - einfach weitermachen... (Player + PlayerGun nur alle 2 Frames!)
    # if (Action >= Act_Action1) and (Action < Act_Action5)
    #   and (ID in [ID_Player, ID_PlayerGun, ID_EnemyFighter]) and (Data.Frame mod 2 = 0) then Exit;
    # if (Action >= Act_Action1) and (Action < Act_Action5)
    #   and (ID = ID_PlayerBomber) and (Data.Frame mod 3 <> 0) then Exit;
    # if (Action >= Act_Action1) and (Action < Act_Action5)
    #   and (ID = ID_EnemyGun) and (Data.Frame mod 5 <> 0) then Exit;
    # if (Action >= Act_Action1) and (Action < Act_Action5) then begin Inc(Action); Exit; end;
    
    if not blocked? DIR_DOWN then
      self.action = vy < 0 ? ACT_JUMP : ACT_LAND
      return
    end
    
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
    self.pmid = ID_PLAYER
    self.action = ACT_JUMP unless action == ACT_DEAD
    # TODO CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
  end
  
  def jump
    # Cannot jump when dead
    return if action >= ACT_DEAD
    
    if in_water? then
      # Cannot jump when in deep water
      return if ALL_WATER_TILES.include? data.map[x / TILE_SIZE, y / TILE_SIZE]
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
      self.vy = (ObjectDef[pmid].jump_y * 1.5).round
      # TODO CastObjects(ID_FXSmoke, 2, 0, 3, 2, Data.OptEffects, GetRect(1, 0), Data.ObjEffects);
      sound(:turbo).play
      dir = DIR_UP
    else
      self.vy = ObjectDef[pmid].jump_y
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
    end;
    
    self.action = ACT_JUMP
    sound(:jump).play if pmid <= ID_PLAYER_MAX
  end;
  
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
      if id <= ID_PLAYER_MAX then
        sound(:morph).play
        self.pmid = ID_PLAYER_FIGHTER + map_tile - TILE_MORPH_FIGHTER
        game.time_left = ObjectDefs[pmid].life unless pmid == ID_PLAYER
        # TODO CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
        # if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXText, PosX, PosY - 10, 0, -1);
        return
      end
    end
    
    # Tile right behind player (doors etc.)
    case game.map[x / TILE_SIZE, y / TILE_SIZE]
    when TILE_STAIRS_UP_LOCKED then
      return if pmid > ID_PLAYER_MAX or game.keys == 0
      game.map[x / TILE_SIZE, y / TILE_SIZE] = TILE_STAIRS_UP
      game.keys -= 1
      sample("door#{rand(2) + 1}").play
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
      sample("door#{rand(2) + 1}").play
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
    # if (Data.Map.Tile(X, Y) in [Tile_Bridge..Tile_Bridge4])
    # and (FindObject(Data.ObjEffects, Data.ObjEnd, ID_FXBreak, ID_FXBreak2, Bounds(X div 24 * 24, Y div 24 * 24, 23, 23)) = nil) then begin
    #   TPMEffect.Create(Data.ObjEffects, '', ID_FXBreak + Random(2), X div 24 * 24 + 11, Y div 24 * 24 + 11, 0, 0);
    #   DistSound(Y, Sound_Break + Random(2), Data^);
    # end;
  end
end
  
=begin
procedure TPMLiving.Hit;
begin
  // Tote und Brenntypen verprügeln bringtz nich
  if (Action = Act_Dead) or (ID = ID_PlayerBerserker) then Exit;
  // Ritter kommen manchmal mit dem Schrecken davon
  if (ID = ID_PlayerFighter) and (Random(2) = 0) then Exit;
  // Keinen Spieler hauen, wenn er noch unverwundbar ist || Unverwundbar machen
  if ID <= ID_PlayerMax then begin
    if Data.InvTimeLeft > 0 then Exit;
    Data.InvTimeLeft := Max(25, Data.InvTimeLeft);
  end;
  // Immer druff da
  Dec(Life);
  // Action setzen
  if Life < 1 then begin
    Action := Act_Dead; Life := 0;
    if ID <= ID_PlayerMax then Data.Waves.Items[Sound_PlayerArg].Play(False);
    if (ID in [ID_Enemy..ID_EnemyMax]) and (Data.OptBlood = 0)
      then DistSound(PosY, Sound_Arg + Random(2), Data^);
    if (ID in [ID_Enemy..ID_EnemyMax]) and (Data.OptBlood = 1)
      then DistSound(PosY, Sound_Death, Data^);
  end else begin
    Action := Act_Pain1 + Random(2);
    if ID <= ID_PlayerMax then Data.Waves.Items[Sound_PlayerArg].Play(False);
    if ID in [ID_Enemy..ID_EnemyMax] then DistSound(PosY, Sound_Arg + Random(2), Data^);
  end;
  // B1U7F15CH r0lz
  if Data.OptBlood = 1 then CastObjects(ID_FXBlood, 8, 0, 2, 2, Data.OptEffects, GetRect(0, 0), Data.ObjEffects);
  // Kamikazehonks: Explodieren
  if (ID = ID_EnemyBomber) and (Action = Act_Dead) then begin
    Kill;
    CastFX(10, 30, 10, PosX, PosY, 10, 10, 0, -10, 5, Data.OptEffects, Data.ObjEffects);
  end;
end;

procedure TPMLiving.Hurt(Explosion: Boolean);
var
  ToDoDamage: Integer;
begin
  // Tote und Brenntypen verprügeln bringtz nich
  if (Action = Act_Dead) or (ID = ID_PlayerBerserker) then Exit;
  // Normaler Schaden: 3 Punkte
  ToDoDamage := 3;
  // Ritter kommen selten mit dem Schrecken davon
  if (ID = ID_PlayerFighter) and (Random(6) = 0) then Dec(ToDoDamage);
  // Keinen Spieler hauen, wenn er noch unverwundbar ist || Unverwundbar machen
  if ID <= ID_PlayerMax then begin
    if Data.InvTimeLeft > 0 then ToDoDamage := Integer(Explosion);
    if Explosion or (Data.InvTimeLeft = 0) then Data.InvTimeLeft := Max(25, Data.InvTimeLeft);
  end;
  // Immer druff da
  Dec(Life, ToDoDamage);
  // Action setzen
  if Life < 1 then begin
    Action := Act_Dead; Life := 0;
    if ID <= ID_PlayerMax then Data.Waves.Items[Sound_PlayerArg].Play(False);
    if (ID in [ID_Enemy..ID_EnemyMax]) and (Data.OptBlood = 0)
      then DistSound(PosY, Sound_Arg + Random(2), Data^);
    if (ID in [ID_Enemy..ID_EnemyMax]) and (Data.OptBlood = 1)
      then DistSound(PosY, Sound_Death, Data^);
  end else begin
    Action := Act_Pain1 + Random(2);
    if (ID <= ID_PlayerMax) and (ToDoDamage > 0) then Data.Waves.Items[Sound_PlayerArg].Play(False);
    if ID in [ID_Enemy..ID_EnemyMax] then DistSound(PosY, Sound_Arg + Random(2), Data^);
  end;
  // B1U7F15CH r0lz
  if Data.OptBlood = 1 then CastObjects(ID_FXBlood, ToDoDamage * 8, 0, 2, 2, Data.OptEffects, GetRect(0, 0), Data.ObjEffects);
  // Kamikazehonks: Explodieren
  if (ID = ID_EnemyBomber) and (Action = Act_Dead) then begin
    Kill;
    CastFX(10, 30, 10, PosX, PosY, 10, 10, 0, -10, 5, Data.OptEffects, Data.ObjEffects);
  end;
end;

procedure TPMLiving.Special;
var
  Target: TPMObject;
begin
  case ID of
    ID_Player: begin
      if Busy then Exit;
      Target := FindObject(Data.ObjOther, Data.ObjEnemies, ID_Lever, ID_LeverRight, GetRect(10, 3));
      if Target <> nil then begin Action := Act_Action1; VelX := 0; end;
    end;
    ID_PlayerFighter: begin
      if Action > Act_Land then Exit;
      Data.Waves[Sound_SwordWoosh].Play(False);
      Action := Act_Action1;
      if Data.Map.Tile(PosX + (10 * RealDir(Direction)), PosY) in [Tile_Blocker..Tile_Blocker3] then begin
        if Data.Map.Tiles[(PosX + (10  * RealDir(Direction))) div 24, PosY div 24] in [Tile_Blocker, Tile_Blocker2]
          then Data.Map.Tiles[(PosX + (10  * RealDir(Direction))) div 24, PosY div 24] := Tile_BlockerBroken
          else Data.Map.Tiles[(PosX + (10  * RealDir(Direction))) div 24, PosY div 24] := Tile_Blocker3Broken;
        CastObjects(ID_FXBlockerParts, 10, 0, -2, 5, Data.OptEffects, Bounds((PosX + (10 * RealDir(Direction))) div 24 * 24, PosY div 24 * 24, 24, 24), Data.ObjEffects);
        Data.Waves[Sound_BlockerBreak].Play(False);
      end;
    end;
    ID_PlayerGun: if (Action <= Act_Land) and (Data.Ammo > 0) then Action := Act_Action1;
    ID_PlayerBomber: if (Action <= Act_Land) and (Data.Bombs > 0) then Action := Act_Action1;
  end;
end;
=end
