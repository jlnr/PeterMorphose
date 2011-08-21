GameObject = Struct.new(:game, :pmid, :xdata, :x, :y, :vx, :vy)

class LivingObject < GameObject
  attr_accessor :life, :action, :direction
  
  def initialize game, pmid, xdata = nil
    super
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
      #if (Data.InvTimeLeft = 0) or (ID = ID_PlayerBerserker) then
      @@player_images ||= Gosu::Image.load_tiles 'media/player.bmp', -ACT_NUM, -10
      @@player_images[ACT_NUM * (direction + (pmid - ID_PLAYER) * 2) + action].draw x - 11, y - 11 - game.view_pos, 0
      #else
      #  Data.Images[Image_Player].Draw(Data.DXDraw.Surface, PosX - 11, PosY - 11 - Data.ViewPos, Act_Num * (Direction + (ID - ID_Player) * 2) + Action), alpha=160
    end
  end
  
end
  
=begin
procedure TPMLiving.Draw;
begin
  case ID of
    ID_Enemy..ID_EnemyFighter, ID_EnemyBerserker..ID_EnemyMax:
      Data.Images[Image_Enemies].Draw(Data.DXDraw.Surface, PosX - 11, PosY - 11 - Data.ViewPos, Act_Num * (Direction + (ID - ID_Enemy) * 2) + Action);
    ID_EnemyGun:
      case Action of
        Act_Dead: Data.Images[Image_Enemies].Draw(Data.DXDraw.Surface, PosX - 11, PosY - 11 - Data.ViewPos, Act_Num * (Direction + 4) + Action);
      else
        if PosX > Data.ObjPlayers.Next.PosX then
          Data.Images[Image_Enemies].Draw(Data.DXDraw.Surface, PosX - 11, PosY - 11 - Data.ViewPos, Act_Num * 4 + Action)
        else
          Data.Images[Image_Enemies].Draw(Data.DXDraw.Surface, PosX - 11, PosY - 11 - Data.ViewPos, Act_Num * 5 + Action);
      end;
  end;
end;

procedure TPMLiving.Update;
var
  Loop: Integer;
  TempDir: Integer;
  Target: Integer;
  TargetObj: TPMObject;
  TargetLiv: TPMLiving;
  procedure BreakFloor(X, Y: Integer);
  begin
    if (Data.Map.Tile(X, Y) in [Tile_Bridge..Tile_Bridge4])
    and (FindObject(Data.ObjEffects, Data.ObjEnd, ID_FXBreak, ID_FXBreak2, Bounds(X div 24 * 24, Y div 24 * 24, 23, 23)) = nil) then begin
      TPMEffect.Create(Data.ObjEffects, '', ID_FXBreak + Random(2), X div 24 * 24 + 11, Y div 24 * 24 + 11, 0, 0);
      DistSound(Y, Sound_Break + Random(2), Data^);
    end;
  end;
begin
  // Runterfallen
  if Action < Act_InvUp then Fall;

  // In Lava verbrennen
  if PosY + Data.Defs[ID].Rect.Top +  Data.Defs[ID].Rect.Bottom > Data.Map.LavaPos then begin
    CastFX(8, 8, 0, PosX, PosY, 16, 16, 0, -4, 1, Data.OptEffects, Data.ObjEffects);
    Kill;

    DistSound(PosY, Sound_Shshsh, Data^);
    if Action <> Act_Dead then begin
      if ID <= ID_PlayerMax then DistSound(PosY, Sound_PlayerArg, Data^);
      if (ID in [ID_Enemy..ID_EnemyMax]) and (Data.OptBlood = 0)
        then DistSound(PosY, Sound_Arg + Random(2), Data^);
      if (ID in [ID_Enemy..ID_EnemyMax]) and (Data.OptBlood = 1)
        then DistSound(PosY, Sound_Death, Data^);
    end;
  end;

  // Im Treppenhaus?
  if Action = Act_InvUp then begin
    if Random(8) = 0 then DistSound(PosY, Sound_StairsRnd, Data^);
    if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Dec(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Dec(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then begin Dec(PosY, 2); Exit; end else PosX := PosX div 24 * 24 + 12;
  end;
  if Action = Act_InvDown then begin
    if Random(7) = 0 then DistSound(PosY, Sound_StairsRnd, Data^);
    if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Inc(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Inc(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then Inc(PosY, 2) else PosX := PosX div 24 * 24 + 11;
    if (Data.Map.Tile(PosX, PosY + 12) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) or (Data.Map.Tile(PosX, PosY - 9) in [0..Tile_StairsUpLocked, Tile_StairsDownLocked]) then begin Inc(PosY, 2); Exit; end else PosX := PosX div 24 * 24 + 12;
  end;

  // Wandteile (nur if alive)
  if Action <> Act_Dead then CheckTile;

  // Brüchigen Boden unter den Füßen einstürzen lassen
  BreakFloor(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 2);
  BreakFloor(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 2);

  // Der Rest nur, wenn nich tot
  if Action = Act_Dead then Exit;

  // In Wasser blubbern
  if InWater then begin
    if (Random(30) = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 7, 0, 0);
    if ID = ID_PlayerBerserker then begin ID := ID_Player; CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects); end;
    if ID = ID_EnemyBerserker then begin ID := ID_Enemy; CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects); end;
  end;

  // Türen aufschließen
  if (ID <= ID_PlayerMax) and (Data.Keys > 0) then with Data^ do begin
    // Nach links
    Target := Map.Tile(PosX + Defs[ID].Rect.Left - 1, PosY);
    if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
      Map.Tiles[(PosX + Defs[ID].Rect.Left - 1) div 24, PosY div 24]
        := Tile_OpenDoor + Target - Tile_ClosedDoor;
      Dec(Data.Keys);
      Data.Waves[Sound_Door + Random(2)].Play(False);
    end;
    // Nach rechts
    Target := Map.Tile(PosX + Defs[ID].Rect.Left + Defs[ID].Rect.Right + 1, PosY);
    if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
      Map.Tiles[(PosX + Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right + 1) div 24, PosY div 24]
        := Tile_OpenDoor + Target - Tile_ClosedDoor;
      Dec(Data.Keys);
      Data.Waves[Sound_Door + Random(2)].Play(False);
    end;
    // Nach Oben
    Target := Map.Tile(PosX, PosY + Defs[ID].Rect.Top - 1);
    if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
      Map.Tiles[PosX div 24, (PosY + Defs[ID].Rect.Top -1) div 24]
        := Tile_OpenDoor + Target - Tile_ClosedDoor;
      Dec(Keys);
      Data.Waves[Sound_Door + Random(2)].Play(False);
    end;
    // Nach unten
    Target := Map.Tile(PosX, PosY + Defs[ID].Rect.Top + Defs[ID].Rect.Bottom + 1);
    if (Target >= Tile_ClosedDoor) and (Target <= Tile_ClosedDoor3) then begin
      Map.Tiles[PosX div 24, (PosY + Defs[ID].Rect.Top + Defs[ID].Rect.Bottom + 1) div 24]
        := Tile_OpenDoor + Target - Tile_ClosedDoor;
      Dec(Keys);
      Data.Waves[Sound_Door + Random(2)].Play(False);
    end;
  end;

  // Spezialaktionen von Peter
  // Player - bei Act_Action3 Schalter umlegen
  if (ID = ID_Player) and (Action = Act_Action3) and (Data.Frame mod 2 = 0) then begin
    TargetObj := FindObject(Data.ObjOther, Data.ObjEnemies, ID_Lever, ID_LeverRight, GetRect(12, 3));
    if TargetObj <> nil then begin
      Data.Waves[Sound_Lever].Play(False);
      case TargetObj.ID of
        ID_Lever:      TargetObj.ID := ID_LeverDown;
        ID_LeverLeft:  TargetObj.ID := ID_LeverRight;
        ID_LeverRight: TargetObj.ID := ID_LeverLeft;
      end;
      if Length(TargetObj.ExtraData) < 1 then Exit;
      if TargetObj.ExtraData[1] in ['0'..'9', 'A'..'F'] then
        for Loop := 0 to StrToIntDef('$' + TargetObj.ExtraData[1], 0) - 1 do begin
          Target := Data.Map.Tiles[StrToInt('$' + Copy(TargetObj.ExtraData, 3 + Loop * 10, 2)), StrToInt('$' + Copy(TargetObj.ExtraData, 6 + Loop * 10, 3))];
          Data.Map.Tiles[StrToInt('$' + Copy(TargetObj.ExtraData, 3 + Loop * 10, 2)), StrToInt('$' + Copy(TargetObj.ExtraData, 6 + Loop * 10, 3))]
            := StrToInt('$' + Copy(TargetObj.ExtraData, 10 + Loop * 10, 2));
          TargetObj.ExtraData[10 + Loop * 10] := IntToHex(Target, 2)[1];
          TargetObj.ExtraData[11 + Loop * 10] := IntToHex(Target, 2)[2];
          CastFX(8, 0, 0, StrToInt('$' + Copy(TargetObj.ExtraData, 3 + Loop * 10, 2)) * 24 + 10, StrToInt('$' + Copy(TargetObj.ExtraData, 6 + Loop * 10, 3)) * 24 + 12, 24, 24, 0, 0, 2, Data.OptEffects, Data.ObjEffects);
        end
      else Data.ExecuteScript(Copy(TargetObj.ExtraData, 3, Length(TargetObj.ExtraData) - 2), 'do');
    end;
  end;
  // Kampfpeter - zuschlagen
  if (ID = ID_PlayerFighter) and (Action in [Act_Action1..Act_Action5]) then begin
    if Direction = Dir_Left then TargetLiv := FindLiving(Data.ObjEnemies, Data.ObjPlayers, ID_Enemy, ID_EnemyMax, 0, Act_Pain1 - 1, Bounds(PosX - 17, PosY - 16, 22, 32))
                            else TargetLiv := FindLiving(Data.ObjEnemies, Data.ObjPlayers, ID_Enemy, ID_EnemyMax, 0, Act_Pain1 - 1, Bounds(PosX -  5, PosY - 16, 22, 32));
    if TargetLiv <> nil then begin
      TargetLiv.Hit;
      TargetLiv.Fling(5 * RealDir(Direction), -4, 1, True, True);
      if TargetLiv.Action = Act_Dead then begin
        Inc(Data.Score, Data.Defs[TargetLiv.ID].Life * 3);
        if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TargetLiv.ID].Life * 3) + ' Punkte!', ID_FXText, TargetLiv.PosX, TargetLiv.PosY - 10, 0, -1);
      end;
    end;
  end;
  // PlayerGun - bei Act_Action 5 schießen
  if (ID = ID_PlayerGun) and (Action = Act_Action5) then begin
    Dec(Data.Ammo);
    TargetLiv := TPMLiving(LaunchProjectile(PosX, PosY + 2, Direction, Data.ObjEnemies, Data.ObjPlayers, Data.ObjEffects, Data^));
    if TargetLiv <> nil then begin
      TargetLiv.Hurt(True);
      TargetLiv.Fling(3 * RealDir(Direction), -3, 1, True, True);
      if TargetLiv.Action = Act_Dead then begin
        Inc(Data.Score, Data.Defs[TargetLiv.ID].Life * 3);
        if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TargetLiv.ID].Life * 3) + ' Punkte!', ID_FXText, TargetLiv.PosX, TargetLiv.PosY - 10, 0, -1);
      end;
    end;
  end;
  // Feuerpeter - BRUZZELN!!!11 >>>>>:::::------))))))999
  if ID = ID_PlayerBerserker then begin
    // FX (harlow flekso *rofz)
    CastFX(Random(2), 2 + Random(2), 0, PosX, PosY, 18, 24, 0, -3, 2, Data.OptEffects, Data.ObjEffects);
    // Gegner fer brenen (höhöhö</köps>)
    TargetObj := Data.ObjEnemies.Next;
    while TargetObj <> Data.ObjPlayers do begin
      if (TPMLiving(TargetObj).Action < Act_Dead) and TargetObj.RectCollision(GetRect(2, 2)) then begin
        TPMLiving(TargetObj).Hurt(False);
        if TPMLiving(TargetObj).Action = Act_Dead then begin
          Inc(Data.Score, Data.Defs[TargetObj.ID].Life * 3);
          if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TargetObj.ID].Life * 3) + ' Punkte!', ID_FXText, TargetObj.PosX, TargetObj.PosY - 10, 0, -1);
        end;
      end;
      TargetObj := TargetObj.Next;
    end;
  end;

  // Feuergegner - KONTERBRUZZELN!!!!11
  if ID = ID_EnemyBerserker then begin
    // EFIX
    CastFX(0, Random(3), 0, PosX, PosY, 18, 24, 0, -2, 3, Data.OptEffects, Data.ObjEffects);
    // Spiler fer brenen (höhöhö</köps>)
    if (TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead) and Data.ObjPlayers.Next.RectCollision(GetRect(5, 2)) then begin
      TPMLiving(Data.ObjPlayers.Next).Hit;
      Data.ObjPlayers.Next.Fling(8 * RealDir(Direction), -3, 0, True, True);
      Fling(-8 * RealDir(Direction), -4, 0, True, False);
      Exit;
    end;
  end;

  // Bombenleger - bei Act_Action4 Bombe hinlegen =)))))9999
  if (ID = ID_PlayerBomber) and (Action = Act_Action4) and (Data.Frame mod 3 = 0) then begin
    Dec(Data.Bombs);
    TPMObject.Create(Data.ObjOther, '0', ID_FusingBomb, PosX + RealDir(Direction) * 5, PosY + 2, RealDir(Direction) * 8, -3);
  end;

  // Spielerrichtungen bestimmen
  if ID <= ID_PlayerMax then begin
    if (VelX < 0) and not Busy then Direction := Dir_Left;
    if (VelX > 0) and not Busy then Direction := Dir_Right;
  end;

  // Schießen bei Enemy_Gun
  if (ID = ID_EnemyGun) and (Action = Act_Action5) then begin
    if PosX <= Data.ObjPlayers.Next.PosX then TempDir := Dir_Right else TempDir := Dir_Left;
    TargetLiv := TPMLiving(LaunchProjectile(PosX, PosY + 2, TempDir, Data.ObjPlayers, Data.ObjEffects, Data.ObjEffects, Data^));
    if TargetLiv <> nil then begin
      TargetLiv.Hit;
      TargetLiv.Fling(3 * RealDir(TempDir), -3, 1, True, True);
    end;
  end;

  // Gegner-"KI"
  if (ID > ID_PlayerMax) and not Busy then begin
    // Wände = Hindernis; Hindernis = Umdrehen
    if Blocked(Direction) then Direction := OtherDir(Direction);
    // Die Gegner sind f0l schlau und rennen _nicht_ in Abgründe...
    // Durch die Gegend rennen
    if (((ID = ID_EnemyFighter) and (Data.Frame mod 100 < 70))
    or ((ID = ID_EnemyGun) and (Data.Frame mod 100 > 15))
    or (ID in [ID_Enemy, ID_EnemyBerserker, ID_EnemyBomber]))
    and not Data.Map.Solid(PosX + RealDir(Direction) * 7,
                          PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) then
      if (Length(ExtraData) > 0) and (ExtraData[1] = '1') then Jump
          else Direction := OtherDir(Direction);
    // Spezialtiles aktivieren (manchmal und wenn ExtraData[3] = 1)
    if (Random(100) = 0) and (Length(ExtraData) > 2) and (ExtraData[3] = '1') then begin UseTile; Exit; end;
    // Durch die Gegend rennen
    if ((ID = ID_EnemyFighter) and (Data.Frame mod 100 < 70))
    or ((ID = ID_EnemyGun) and (Data.Frame mod 100 > 15))
    or (ID in [ID_Enemy, ID_EnemyBerserker, ID_EnemyBomber])
      then Inc(VelX, Data.Defs[ID].Speed * RealDir(Direction));
    // Spieler in Sicht, ATTACKKKÄÄÄÄHHH!
    if (ID = ID_EnemyFighter) and Data.ObjPlayers.Next.RectCollision(Bounds(PosX - 120 + (Ord(Direction) * 120), PosY - 24, 120, 48))
      and Data.Map.Solid(PosX + RealDir(Direction) * 7, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) and (TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead)
        then VelX := Data.Defs[ID].Speed * 2 * RealDir(Direction);
    // Spieler in Sicht, TOTSNIPEX0RN !!!11
    if (ID = ID_EnemyGun) and PointInRect(Point(Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY), GetRect(320, 1)) and (TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead)then begin
      Target := 1;
      for Loop := 0 to Abs(Data.ObjPlayers.Next.PosX - PosX) div 24 do
        if Data.Map.Solid(Loop * 24 + Min(Data.ObjPlayers.Next.PosX, PosX), PosY) then Target := 0;
      if Target = 1 then begin Action := Act_Action1; Exit; end;
    end;
    // Spieler umrempeln
    if RectCollision(Data.ObjPlayers.Next.GetRect(1, -1))
      and not (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Pain1, Act_Pain2, Act_Dead, Act_InvUp, Act_InvDown]) then begin
        if ID = ID_EnemyBomber then TPMLiving(Data.ObjPlayers.Next).Hurt(True)
                                  else TPMLiving(Data.ObjPlayers.Next).Hit;
        Data.ObjPlayers.Next.Fling(8 * RealDir(Direction), -3, 0, True, True);
        Fling(-6 * RealDir(Direction), -2, 0, True, False);
        if ID = ID_EnemyBomber then begin
          Kill;
          CastFX(10, 30, 10, PosX, PosY, 10, 10, 0, -10, 5, Data.OptEffects, Data.ObjEffects);
        end;
        Exit;
      end;
  end;

  // Spieler auch im Sprung umrempeln
  if (ID > ID_PlayerMax) and (Action in [Act_Jump, Act_Land]) and RectCollision(Data.ObjPlayers.Next.GetRect(0, -1))
    and not (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Pain1, Act_Pain2, Act_Dead, Act_InvUp, Act_InvDown]) then begin
      if ID = ID_EnemyBomber then TPMLiving(Data.ObjPlayers.Next).Hurt(True)
                             else TPMLiving(Data.ObjPlayers.Next).Hit;
      Data.ObjPlayers.Next.Fling(8 * RealDir(Direction), -4, 0, True, True);
      Fling(-7 * RealDir(Direction), 4, 1, True, False);
      if ID = ID_EnemyBomber then begin
        Kill;
        CastFX(10, 30, 10, PosX, PosY, 10, 10, 0, -10, 5, Data.OptEffects, Data.ObjEffects);
      end;
      Exit;
    end;

  // Fliegen
  if (ID <= ID_PlayerMax) and (Data.FlyTimeLeft > 0) and not (Action in [Act_Action1..Act_Action5]) then
    begin if VelY < 0 then Action := Act_Jump else Action := Act_Land; Exit; end;
  // Verwundet bleibt verwundet, bis wieder Boden unter den Füßen ist
  if ((Action = Act_Pain1) or (Action = Act_Pain2)) and (not Blocked(Dir_Down)) and (not InWater) then Exit;
  // Hingefallen, weiter aufstehen
  if (Action >= Act_Impact1) and (Action <= Act_Impact5) and (Data.Frame mod 2 = 0) then Exit;
  if (Action >  Act_Impact1) and (Action <= Act_Impact5) then begin Dec(Action); Exit; end;
  // Spezialaktion - einfach weitermachen... (Player + PlayerGun nur alle 2 Frames!)
  if (Action >= Act_Action1) and (Action < Act_Action5)
    and (ID in [ID_Player, ID_PlayerGun, ID_EnemyFighter]) and (Data.Frame mod 2 = 0) then Exit;
  if (Action >= Act_Action1) and (Action < Act_Action5)
    and (ID = ID_PlayerBomber) and (Data.Frame mod 3 <> 0) then Exit;
  if (Action >= Act_Action1) and (Action < Act_Action5)
    and (ID = ID_EnemyGun) and (Data.Frame mod 5 <> 0) then Exit;
  if (Action >= Act_Action1) and (Action < Act_Action5) then begin Inc(Action); Exit; end;
  // Springen und fallen
  if not Blocked(Dir_Down) then begin
    if VelY < 0 then Action := Act_Jump else Action := Act_Land; Exit; end;
  // Auf Schleim laufen / Spieler
  if (ID <= ID_PlayerMax) and Blocked(Dir_Down) and (Data.Map.Tile(PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3])
    and ((isLeft in Data.Input.States) or (isRight in Data.Input.States))
      then begin
        Action := Act_Walk1 + Data.Frame mod 12 div 3;
        if isLeft in Data.Input.States then Direction := Dir_Left else Direction := Dir_Right;
        if (Abs(Data.ObjPlayers.Next.PosY - PosY) < Data.OptEffectsDistance) and (Random(5) = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXFlyingBlob, PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom, -1 + Random(3), Random(3));
        if Random(5) = 0 then DistSound(PosY, Sound_Slime + Random(3), Data^);
        Exit;
      end;
  // Auf Schleim laufen / Gegner
  if Blocked(Dir_Down) and (Data.Map.Tile(PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3])
    and (((ID = ID_EnemyFighter) and (Data.Frame mod 100 < 70))
         or ((ID = ID_EnemyGun) and (Data.Frame mod 100 > 15))
         or (ID in [ID_Enemy, ID_EnemyBerserker, ID_EnemyBomber]))
      then begin
        Action := Act_Walk1 + Data.Frame mod 12 div 3;
        if (Abs(Data.ObjPlayers.Next.PosY - PosY) < Data.OptEffectsDistance) and (Random(5) = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXFlyingBlob, PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom, -1 + Random(3), Random(3));
        if Random(5) = 0 then DistSound(PosY, Sound_Slime + Random(3), Data^);
        Exit;
      end;
  // Laufen
  if Blocked(Dir_Down) and (Abs(VelX) > 0) then
    begin Action := Act_Walk1 + Data.Frame mod 8 div 2; Exit; end;
  // "idlezeiten von ueber 4 wochen sind absolut eleet"
  Action := Act_Stand;
end;

procedure TPMLiving.Jump;
var
  DirToJump: Integer;
begin
  if Action >= Act_Dead then Exit;
  if InWater then
    begin if Data.Map.Tile(PosX, PosY - 3) in [Tile_Water..Tile_Water4, Tile_Water5] then Exit; end
  else
    if Busy then Exit;
  DirToJump := Dir_Up;
  if ID <= ID_PlayerMax then begin
    Data.Input.Update;
    if isLeft in Data.Input.States  then begin DirToJump := Dir_Left;  Direction := DirToJump; end;
    if isRight in Data.Input.States then begin DirToJump := Dir_Right; Direction := DirToJump; end;
  end;
  if (ID <= ID_PlayerMax) and (Data.JumpTimeLeft > 0) then begin
    VelY := Round(Data.Defs[ID].JumpY * 1.5);
    CastObjects(ID_FXSmoke, 2, 0, 3, 2, Data.OptEffects, GetRect(1, 0), Data.ObjEffects);
    Data.Waves[Sound_Turbo].Play(False);
    DirToJump := Dir_Up;
  end else VelY := Data.Defs[ID].JumpY;
  if DirToJump = Dir_Up then VelX := 0 else 
    VelX := RealDir(DirToJump) * Max(Data.Defs[ID].JumpX, Abs(VelX) div 2);
  if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3])
  or (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3]) then begin
    VelX := VelX div 3;
    VelY := Round(VelY / 1.5);
  end;
  if InWater then begin
    VelX := VelX div 3;
    VelY := Round(VelY / 1.2);
    DistSound(PosY, Sound_Water + Random(2), Data^);
  end;

  Action := Act_Jump;
  if ID <= ID_PlayerMax then Data.Waves[Sound_Jump].Play(False);
end;

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

procedure TPMLiving.UseTile;
begin
  // Nur, wenn Objekt Lust hat
  if Busy then Exit;
  case Data.Map.Tile(PosX, PosY + Data.Defs[ID].Rect.Bottom + 1) of
    Tile_RocketUp, Tile_RocketUp2, Tile_RocketUp3: begin
      if ID <= ID_PlayerMax then Data.Waves[Sound_Jump].Play(False);
      DistSound(PosY, Sound_Turbo, Data^);
      VelX := 0;
      VelY := -20;
      if not Blocked(Dir_Up) then Dec(PosY);
      Action := Act_Jump;
      CastFX(0, 0, 10, PosX, PosY, 24, 24, 0, -10, 1, Data.OptEffects, Data.ObjEffects);
      if ID <= ID_PlayerMax then Data.Waves[Sound_Jump].Play(False);
      Exit;
    end;
    Tile_RocketUpLeft, Tile_RocketUpLeft2, Tile_RocketUpLeft3: begin
      if ID <= ID_PlayerMax then Data.Waves[Sound_Jump].Play(False);
      DistSound(PosY, Sound_Turbo, Data^);
      VelX := -15;
      VelY := -15;
      if not Blocked(Dir_Up) then Dec(PosY);
      Action := Act_Jump;
      Direction := Dir_Left;
      CastFX(0, 0, 10, PosX, PosY, 24, 24, -8, -8, 1, Data.OptEffects, Data.ObjEffects);
      if ID <= ID_PlayerMax then Data.Waves[Sound_Jump].Play(False);
      Exit;
    end;
    Tile_RocketUpRight, Tile_RocketUpRight2, Tile_RocketUpRight3: begin
      if ID <= ID_PlayerMax then Data.Waves[Sound_Jump].Play(False);
      DistSound(PosY, Sound_Turbo, Data^);
      VelX := 15;
      VelY := -15;
      if not Blocked(Dir_Up) then Dec(PosY);
      Action := Act_Jump;
      Direction := Dir_Right;
      CastFX(0, 0, 10, PosX, PosY, 24, 24, +8, -8, 1, Data.OptEffects, Data.ObjEffects);
      if ID <= ID_PlayerMax then Data.Waves[Sound_Jump].Play(False);
      Exit;
    end;
    Tile_MorphFighter..Tile_MorphMax: if ID <= ID_PlayerMax then begin
      Data.Waves[Sound_Morph].Play(False);
      ID := ID_PlayerFighter + (Data.Map.Tile(PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) - Tile_MorphFighter);
      Data.Map.Tiles[PosX div 24, (PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) div 24] := Tile_MorphEmpty;
      if ID <> ID_Player then Data.TimeLeft := Data.Defs[ID].Life;
      CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXText, PosX, PosY - 10, 0, -1);
      Exit;
    end;
  end;
  case Data.Map.Tile(PosX, PosY) of
    Tile_StairsUpLocked: begin
      if (ID > ID_PlayerMax) or (Data.Keys = 0) then Exit;
      Data.Map.Tiles[PosX div 24, PosY div 24] := Tile_StairsUp;
      Dec(Data.Keys);
      Data.Waves[Sound_Door + Random(2)].Play(False);
      UseTile;
    end;
    Tile_StairsUp..Tile_StairsUp2: begin
      if (not Data.Map.StairsEnd(PosX div 24, PosY div 24)) and (ID > ID_PlayerMax) then Exit;
      PosY := PosY div 24 * 24;
      Action := Act_InvUp;
      VelX := 0;
      VelY := 0;
      DistSound(PosY, Sound_Stairs, Data^);
      Exit;
    end;
    Tile_StairsDownLocked: begin
      if (ID > ID_PlayerMax) or (Data.Keys = 0) then Exit;
      Data.Map.Tiles[PosX div 24, PosY div 24] := Tile_StairsDown;
      Dec(Data.Keys);
      Data.Waves[Sound_Door + Random(2)].Play(False);
      UseTile;
    end;
    Tile_StairsDown..Tile_StairsDown2: begin
      if not Data.Map.StairsEnd(PosX div 24, PosY div 24) then Exit;
      PosY := PosY div 24 * 24 + 13;
      Action := Act_InvDown;
      VelX := 0;
      VelY := 0;
      DistSound(PosY, Sound_Stairs, Data^);
      Exit;
    end;
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

function TPMLiving.Busy: Boolean;
begin
  Result := not (Blocked(Dir_Down) and (Action in [Act_Stand..Act_Walk4]));
end;

procedure TPMCollectible.Update;
begin
  // Fallen + Tile abfragen
  if (not (ID in [ID_EdibleFish, ID_EdibleFish2])) and (Length(ExtraData) > 0) and (ExtraData[1] = '1') then begin Fall; CheckTile; end;
  // In Lava verbrennen
  if PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom > Data.Map.LavaPos then begin CastFX(2, 2, 0, PosX, PosY, 16, 16, 0, -3, 1, Data.OptEffects, Data.ObjEffects); Kill; DistSound(PosY, Sound_Shshsh, Data^); if ID = ID_Carolin then Data.State := State_Dead; end;
  // HHIIIIILFE RÄTET MISCH
  if (ID = ID_Carolin) and (Data.Frame mod 20 = 0) and (Random(4) = 0) then
    DistSound(PosY, Sound_Help + Random(2), Data^);
  // Süse fischli`z
  if ID = ID_EdibleFish then begin
    if not InWater then begin
      if (Length(ExtraData) > 0) and (ExtraData[1] = '1') then begin Fall; CheckTile; end;
    end else begin
      Dec(PosX, 2);
      if Random(30) = 0 then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 3, 0, 0);
      if Blocked(Dir_Left) then ID := ID_EdibleFish2;
    end;
  end else if ID = ID_EdibleFish2 then begin
    if not InWater then begin
      if (Length(ExtraData) > 0) and (ExtraData[1] = '1') then begin Fall; CheckTile; end;
    end else begin
      Inc(PosX, 2);
      if Random(30) = 0 then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 3, 0, 0);
      if Blocked(Dir_Right) then ID := ID_EdibleFish;
    end;
  end;

  // Eingesammelt werden, wenn Spieler lebt
  if TPMLiving(Data.ObjPlayers.Next).Action >= Act_Dead then Exit;
  if RectCollision(Data.ObjPlayers.Next.GetRect(2, 2)) then case ID of
    ID_Carolin: begin
      CastObjects(ID_FXFlyingChain, 8, 0, -1, 3, Data.OptEffects, GetRect(1, -1), Data.ObjEffects);
      TPMEffect.Create(Data.ObjEffects, '', ID_FXFlyingCarolin, PosX, PosY, -7 + Random(15), -15);
      Data.Waves[Sound_Jeepee].Play(False);
      Inc(Data.Score, 100);
      Kill;
    end;
    ID_Key: begin
      Data.Waves[Sound_KeyCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Schlüssel!', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, 2); Inc(Data.Keys); Kill;
    end;
    ID_EdibleFish, ID_EdibleFish2: begin
      Data.Waves[Sound_HealthCollect].Play(False);
      Data.Waves[Sound_Eat].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+1', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      Inc(Data.Score, 2); Inc(TPMLiving(Data.ObjPlayers.Next).Life); Kill;
    end;
    ID_MoreTime: begin
      if Data.ObjPlayers.Next.ID = ID_Player then Exit;
      Data.Waves[Sound_Morph].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+1,5 Sekunden', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, 5);
      Inc(Data.TimeLeft, 33);
      Kill;
    end;
    ID_MoreTime2: begin
      if Data.ObjPlayers.Next.ID = ID_Player then Exit;
      Data.Waves[Sound_Morph].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+5 Sekunden', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 3, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, 10);
      Inc(Data.TimeLeft, 110);
      Kill;
    end;
    ID_Health: begin
      Data.Waves[Sound_HealthCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+1', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, 1); Inc(TPMLiving(Data.ObjPlayers.Next).Life); Kill;
    end;
    ID_Health2: begin
      Data.Waves[Sound_HealthCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+4', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, 4); Inc(TPMLiving(Data.ObjPlayers.Next).Life, 4); Kill;
    end;
    ID_Star..ID_Star3: begin
      Data.Waves[Sound_StarCollect].Play(False);
      Inc(Data.Score, 2); Inc(Data.Stars);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Nr. ' + IntToStr(Data.Stars), ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Kill;
    end;
    ID_Points..ID_PointsMax: begin
      Data.Waves[Sound_PointCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '*' + IntToStr(Data.Defs[ID].Life) + '*', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 3, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, Data.Defs[ID].Life); Kill;
    end;
    ID_MunitionGun, ID_MunitionGun2: begin
      Data.Waves[Sound_AmmoCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+' + IntToStr((ID - ID_MunitionGun) * 2 + 1), ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, 1 + (ID - ID_MunitionGun) * 2);
      Inc(Data.Ammo,  1 + (ID - ID_MunitionGun) * 2);
      Kill;
    end;
    ID_MunitionBomber, ID_MunitionBomber2: begin
      Data.Waves[Sound_AmmoCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+' + IntToStr((ID - ID_MunitionBomber) * 2 + 1), ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Inc(Data.Score, 1 + (ID - ID_MunitionBomber) * 2);
      Inc(Data.Bombs, 1 + (ID - ID_MunitionBomber) * 2);
      Kill;
    end;
    ID_Cookie: begin
      Data.Waves[Sound_Eat].Play(False);
      CastObjects(ID_FXSparkle, 1, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      if Length(ExtraData) > 2 then TPMEffect.Create(Data.ObjEffects, Copy(ExtraData, 3, Length(ExtraData) - 2), ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1)
      else if Data.OptShowTexts = 1 then case Random(4) of
        0: TPMEffect.Create(Data.ObjEffects, 'Komisch, der Keks war leer?', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
        1: TPMEffect.Create(Data.ObjEffects, 'Sowas, der Keks war leer!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
        2: TPMEffect.Create(Data.ObjEffects, 'Och nein, schon wieder ein leerer Keks!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
        3: TPMEffect.Create(Data.ObjEffects, 'Der Keks ist leer.', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      end;
      Inc(Data.Score, 10);
      Kill;
    end;
    ID_SlowDown: begin
      if (Data.Map.LavaMode = 0) and (Data.Map.LavaSpeed = 48) then Exit;
      if (Data.Map.LavaMode = 1) and (Data.Map.LavaSpeed =  1) then begin Data.Map.LavaMode := 0; Data.Map.LavaSpeed := 2; Exit; end;
      Data.Waves[Sound_FreezeCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Lava verlangsamt!', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      if Data.Map.LavaMode = 0 then Inc(Data.Map.LavaSpeed)
                               else Dec(Data.Map.LavaSpeed);
      CastObjects(ID_FXSparkle, 3, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Kill;
    end;
    ID_Crystal: begin
      Data.Waves[Sound_FreezeCollect].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Lava angehalten!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      Inc(Data.Map.LavaTimeLeft, 80);
      CastObjects(ID_FXSparkle, 4, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Kill;
    end;
    ID_MorphFighter..ID_MorphMax: if Data.ObjPlayers.Next.ID <> ID_PlayerFighter + ID - ID_MorphFighter then begin
      Data.Waves[Sound_Morph].Play(False);
      Data.ObjPlayers.Next.ID := ID_PlayerFighter + ID - ID_MorphFighter;
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[Data.ObjPlayers.Next.ID].Name +  '!', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      TPMLiving(Data.ObjPlayers.Next).Action := Act_Jump;
      CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
      Data.TimeLeft := Data.Defs[Data.ObjPlayers.Next.ID].Life;
      CastObjects(ID_FXSparkle, 5, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Kill;
    end;
    ID_Speed: begin
      Data.Waves[Sound_Morph].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      Data.SpeedTimeLeft := 330;
      CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY - 10, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Kill;
    end;
    ID_Jump: begin
      Data.Waves[Sound_Morph].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      Data.JumpTimeLeft := 330;
      CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY - 10, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Kill;
    end;
    ID_Fly: begin
      Data.Waves[Sound_Morph].Play(False);
      if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
      Data.FlyTimeLeft := 88;
      CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY - 10, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
      CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
      Kill;
    end;
    ID_Seamine: begin
      Explosion(PosX, PosY, 50, Data^, False);
      Kill;
    end;
  end;
end;
=end
