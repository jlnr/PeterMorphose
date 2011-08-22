class CollectibleObject < GameObject
  def update
    if not [ID_EDIBLE_FISH, ID_EDIBLE_FISH_2].include? pmid and not xdata.nil? and xdata[1, 1] == '1' then
      fall
      check_tile
    end
    
    # Burn in lava
    if y + ObjectDef[pmid].rect.bottom > game.map.lava_pos then
      # TODO CastFX(2, 2, 0, PosX, PosY, 16, 16, 0, -3, 1, Data.OptEffects, Data.ObjEffects);
      kill
      emit_sound :shshsh
      # game.lose if pmid == ID_CAROLIN TODO
    end
    
    if pmid == ID_CAROLIN and game.frame % 20 == 0 and rand(4) == 0 then
      emit_sound "help#{rand(2) + 1}"
    end
    
    # // Süse fischli`z
    # if ID = ID_EdibleFish then begin
    #   if not InWater then begin
    #     if (Length(ExtraData) > 0) and (ExtraData[1] = '1') then begin Fall; CheckTile; end;
    #   end else begin
    #     Dec(PosX, 2);
    #     if Random(30) = 0 then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 3, 0, 0);
    #     if Blocked(Dir_Left) then ID := ID_EdibleFish2;
    #   end;
    # end else if ID = ID_EdibleFish2 then begin
    #   if not InWater then begin
    #     if (Length(ExtraData) > 0) and (ExtraData[1] = '1') then begin Fall; CheckTile; end;
    #   end else begin
    #     Inc(PosX, 2);
    #     if Random(30) = 0 then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 3, 0, 0);
    #     if Blocked(Dir_Right) then ID := ID_EdibleFish;
    #   end;
    # end;
    
    # Cannot be collected...
    return if game.player.action >= ACT_DEAD
    
    # // Eingesammelt werden, wenn Spieler lebt
    # if TPMLiving(Data.ObjPlayers.Next).Action >= Act_Dead then Exit;
    # if RectCollision(Data.ObjPlayers.Next.GetRect(2, 2)) then case ID of
    #   ID_Carolin: begin
    #     CastObjects(ID_FXFlyingChain, 8, 0, -1, 3, Data.OptEffects, GetRect(1, -1), Data.ObjEffects);
    #     TPMEffect.Create(Data.ObjEffects, '', ID_FXFlyingCarolin, PosX, PosY, -7 + Random(15), -15);
    #     Data.Waves[Sound_Jeepee].Play(False);
    #     Inc(Data.Score, 100);
    #     Kill;
    #   end;
    #   ID_Key: begin
    #     Data.Waves[Sound_KeyCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Schlüssel!', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, 2); Inc(Data.Keys); Kill;
    #   end;
    #   ID_EdibleFish, ID_EdibleFish2: begin
    #     Data.Waves[Sound_HealthCollect].Play(False);
    #     Data.Waves[Sound_Eat].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+1', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     Inc(Data.Score, 2); Inc(TPMLiving(Data.ObjPlayers.Next).Life); Kill;
    #   end;
    #   ID_MoreTime: begin
    #     if Data.ObjPlayers.Next.ID = ID_Player then Exit;
    #     Data.Waves[Sound_Morph].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+1,5 Sekunden', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, 5);
    #     Inc(Data.TimeLeft, 33);
    #     Kill;
    #   end;
    #   ID_MoreTime2: begin
    #     if Data.ObjPlayers.Next.ID = ID_Player then Exit;
    #     Data.Waves[Sound_Morph].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+5 Sekunden', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 3, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, 10);
    #     Inc(Data.TimeLeft, 110);
    #     Kill;
    #   end;
    #   ID_Health: begin
    #     Data.Waves[Sound_HealthCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+1', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, 1); Inc(TPMLiving(Data.ObjPlayers.Next).Life); Kill;
    #   end;
    #   ID_Health2: begin
    #     Data.Waves[Sound_HealthCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+4', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, 4); Inc(TPMLiving(Data.ObjPlayers.Next).Life, 4); Kill;
    #   end;
    #   ID_Star..ID_Star3: begin
    #     Data.Waves[Sound_StarCollect].Play(False);
    #     Inc(Data.Score, 2); Inc(Data.Stars);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Nr. ' + IntToStr(Data.Stars), ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Kill;
    #   end;
    #   ID_Points..ID_PointsMax: begin
    #     Data.Waves[Sound_PointCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '*' + IntToStr(Data.Defs[ID].Life) + '*', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 3, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, Data.Defs[ID].Life); Kill;
    #   end;
    #   ID_MunitionGun, ID_MunitionGun2: begin
    #     Data.Waves[Sound_AmmoCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+' + IntToStr((ID - ID_MunitionGun) * 2 + 1), ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, 1 + (ID - ID_MunitionGun) * 2);
    #     Inc(Data.Ammo,  1 + (ID - ID_MunitionGun) * 2);
    #     Kill;
    #   end;
    #   ID_MunitionBomber, ID_MunitionBomber2: begin
    #     Data.Waves[Sound_AmmoCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, '+' + IntToStr((ID - ID_MunitionBomber) * 2 + 1), ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Inc(Data.Score, 1 + (ID - ID_MunitionBomber) * 2);
    #     Inc(Data.Bombs, 1 + (ID - ID_MunitionBomber) * 2);
    #     Kill;
    #   end;
    #   ID_Cookie: begin
    #     Data.Waves[Sound_Eat].Play(False);
    #     CastObjects(ID_FXSparkle, 1, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     if Length(ExtraData) > 2 then TPMEffect.Create(Data.ObjEffects, Copy(ExtraData, 3, Length(ExtraData) - 2), ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1)
    #     else if Data.OptShowTexts = 1 then case Random(4) of
    #       0: TPMEffect.Create(Data.ObjEffects, 'Komisch, der Keks war leer?', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #       1: TPMEffect.Create(Data.ObjEffects, 'Sowas, der Keks war leer!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #       2: TPMEffect.Create(Data.ObjEffects, 'Och nein, schon wieder ein leerer Keks!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #       3: TPMEffect.Create(Data.ObjEffects, 'Der Keks ist leer.', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     end;
    #     Inc(Data.Score, 10);
    #     Kill;
    #   end;
    #   ID_SlowDown: begin
    #     if (Data.Map.LavaMode = 0) and (Data.Map.LavaSpeed = 48) then Exit;
    #     if (Data.Map.LavaMode = 1) and (Data.Map.LavaSpeed =  1) then begin Data.Map.LavaMode := 0; Data.Map.LavaSpeed := 2; Exit; end;
    #     Data.Waves[Sound_FreezeCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Lava verlangsamt!', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     if Data.Map.LavaMode = 0 then Inc(Data.Map.LavaSpeed)
    #                              else Dec(Data.Map.LavaSpeed);
    #     CastObjects(ID_FXSparkle, 3, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Kill;
    #   end;
    #   ID_Crystal: begin
    #     Data.Waves[Sound_FreezeCollect].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, 'Lava angehalten!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     Inc(Data.Map.LavaTimeLeft, 80);
    #     CastObjects(ID_FXSparkle, 4, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Kill;
    #   end;
    #   ID_MorphFighter..ID_MorphMax: if Data.ObjPlayers.Next.ID <> ID_PlayerFighter + ID - ID_MorphFighter then begin
    #     Data.Waves[Sound_Morph].Play(False);
    #     Data.ObjPlayers.Next.ID := ID_PlayerFighter + ID - ID_MorphFighter;
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[Data.ObjPlayers.Next.ID].Name +  '!', ID_FXText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     TPMLiving(Data.ObjPlayers.Next).Action := Act_Jump;
    #     CastFX(8, 0, 0, PosX, PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
    #     Data.TimeLeft := Data.Defs[Data.ObjPlayers.Next.ID].Life;
    #     CastObjects(ID_FXSparkle, 5, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Kill;
    #   end;
    #   ID_Speed: begin
    #     Data.Waves[Sound_Morph].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     Data.SpeedTimeLeft := 330;
    #     CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY - 10, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Kill;
    #   end;
    #   ID_Jump: begin
    #     Data.Waves[Sound_Morph].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     Data.JumpTimeLeft := 330;
    #     CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY - 10, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Kill;
    #   end;
    #   ID_Fly: begin
    #     Data.Waves[Sound_Morph].Play(False);
    #     if Data.OptShowTexts = 1 then TPMEffect.Create(Data.ObjEffects, Data.Defs[ID].Name + '!', ID_FXSlowText, PosX, Data.ObjPlayers.Next.PosY - 10, 0, -1);
    #     Data.FlyTimeLeft := 88;
    #     CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY - 10, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
    #     CastObjects(ID_FXSparkle, 2, 0, 0, 0, Data.OptEffects, GetRect, Data.ObjEffects);
    #     Kill;
    #   end;
    #   ID_Seamine: begin
    #     Explosion(PosX, PosY, 50, Data^, False);
    #     Kill;
    #   end;
    # end;
  end
end
