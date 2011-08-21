=begin
TODO Translate to Ruby

procedure TFormPeterM.ExecuteScript(Script, Caller: string);
var
  CommandList: TStringList;
  Cmd: string; Cond: Boolean; I: Integer;
  // Objekt kriegen und so
  function GetObjVar(VarStr: string): TPMObject;
  begin
    if VarStr[1] <> '$' then begin Result := nil; Exit; end;
    if VarStr = '$P' then Result := Data.ObjPlayers.Next else
      Result := TPMObject(Data.ObjVars[StrToIntDef('$' + VarStr[2], 0)]);
  end;
  // Objektpointer setzen und so
  procedure SetObjVar(VarStr: string; Obj: TPMObject);
  begin
    if VarStr = 'no' then Exit;
    Data.ObjVars[StrToIntDef('$' + VarStr[2], 0)] := Obj;
  end;
  // Gibt den Wert einer vierstelligen GameVar zur¸ck
  function GetVar(VarStr: string): Integer;
  begin
    Result := 0;
    if Copy(VarStr, 1, 3) = 'var' then Result := Data.Map.ScriptVars[StrToIntDef('$' + VarStr[4], 0)];

    if VarStr[1] = '?' then Result := Random(StrToIntDef('$' + Copy(VarStr, 2, 3), 0) + 1);

    if VarStr[1] = '$' then begin
      Result := -1;
      if Copy(VarStr, 3, 2) = 'ex' then Result := Integer(GetObjVar(Copy(VarStr, 1, 2)) <> TPMObject(nil));
      if (VarStr[2] <> 'P') and (Data.ObjVars[StrToIntDef('$' + VarStr[2], 0)] = nil) then Exit;
      if Copy(VarStr, 3, 2) = 'px' then Result := GetObjVar(Copy(VarStr, 1, 2)).PosX;
      if Copy(VarStr, 3, 2) = 'py' then Result := GetObjVar(Copy(VarStr, 1, 2)).PosY;
      if Copy(VarStr, 3, 2) = 'vx' then Result := GetObjVar(Copy(VarStr, 1, 2)).VelX;
      if Copy(VarStr, 3, 2) = 'vy' then Result := GetObjVar(Copy(VarStr, 1, 2)).VelY;
      if Copy(VarStr, 3, 2) = 'id' then Result := GetObjVar(Copy(VarStr, 1, 2)).ID;
      if (VarStr[2] <> 'P') and (Data.ObjVars[StrToIntDef('$' + VarStr[2], 0)].ClassType <> TPMLiving) then Exit;
      if Copy(VarStr, 3, 2) = 'lf' then Result := TPMLiving(GetObjVar(Copy(VarStr, 1, 2))).Life;
      if Copy(VarStr, 3, 2) = 'ac' then Result := TPMLiving(GetObjVar(Copy(VarStr, 1, 2))).Action;
      if Copy(VarStr, 3, 2) = 'dr' then Result := TPMLiving(GetObjVar(Copy(VarStr, 1, 2))).Direction;
    end;

    if VarStr = 'keys' then Result := Data.Keys;
    if VarStr = 'ammo' then Result := Data.Ammo;
    if VarStr = 'bomb' then Result := Data.Bombs;
    if VarStr = 'star' then Result := Data.Stars;
    if VarStr = 'scor' then Result := Data.Score;

    if VarStr = 'time' then Result := Data.TimeLeft;
    if VarStr = 'tspd' then Result := Data.SpeedTimeLeft;
    if VarStr = 'tjmp' then Result := Data.JumpTimeLeft;
    if VarStr = 'tfly' then Result := Data.FlyTimeLeft;

    if VarStr = 'lpos' then Result := Data.Map.LavaPos;
    if VarStr = 'lspd' then Result := Data.Map.LavaSpeed;
    if VarStr = 'lmod' then Result := Data.Map.LavaMode;
  end;
  // Setzt den Wert einer GameVar
  procedure SetVar(VarStr: string; Val: Integer);
  begin
    if Copy(VarStr, 1, 3) = 'var' then Data.Map.ScriptVars[StrToIntDef('$' + VarStr[4], 0)] := Val;

    if VarStr[1] = '$' then begin
      if (VarStr[2] <> 'P') and (GetObjVar(Copy(VarStr, 1, 2)) = nil) then Exit;
      if Copy(VarStr, 3, 2) = 'px' then GetObjVar(Copy(VarStr, 1, 2)).PosX := Val;
      if Copy(VarStr, 3, 2) = 'py' then GetObjVar(Copy(VarStr, 1, 2)).PosY := Val;
      if Copy(VarStr, 3, 2) = 'vx' then GetObjVar(Copy(VarStr, 1, 2)).VelX := Val;
      if Copy(VarStr, 3, 2) = 'vy' then GetObjVar(Copy(VarStr, 1, 2)).VelY := Val;
      if Copy(VarStr, 3, 2) = 'id' then GetObjVar(Copy(VarStr, 1, 2)).ID := Val;
      if (VarStr[2] <> 'P') and (GetObjVar(Copy(VarStr, 1, 2)).ClassType <> TPMLiving) then Exit;
      if (Copy(VarStr, 3, 2) = 'lf') then TPMLiving(GetObjVar(Copy(VarStr, 1, 2))).Life := Val;
      if (Copy(VarStr, 3, 2) = 'ac') then TPMLiving(GetObjVar(Copy(VarStr, 1, 2))).Action := Val;
      if (Copy(VarStr, 3, 2) = 'dr') then TPMLiving(GetObjVar(Copy(VarStr, 1, 2))).Direction := Val;
    end;

    if VarStr = 'keys' then Data.Keys := Val;
    if VarStr = 'ammo' then Data.Ammo := Val;
    if VarStr = 'bomb' then Data.Bombs := Val;
    if VarStr = 'star' then Data.Stars := Val;
    if VarStr = 'scor' then Data.Score := Val;

    if VarStr = 'time' then Data.TimeLeft := Val;
    if VarStr = 'tspd' then Data.SpeedTimeLeft := Val;
    if VarStr = 'tjmp' then Data.JumpTimeLeft := Val;
    if VarStr = 'tfly' then Data.FlyTimeLeft := Val;

    if VarStr = 'lpos' then Data.Map.LavaPos := Val;
    if VarStr = 'lspd' then Data.Map.LavaSpeed := Val;
    if VarStr = 'lmod' then Data.Map.LavaMode := Val;
  end;
  // Wandelt Strings der Form 4626 und -var6 in einen Integer um
  function ParamToInt(ParamList: string; S, L: Integer): Integer;
  var
    RealPar: string;
  begin
    Result := 0;
    if not L in [4, 5] then begin Log.Add('Fehler: Ung¸ltige Parameter in ' + ParamList); Exit; end;
    if S + L - 1 > Length(ParamList) then begin Log.Add('Fehler: Zu wenig Parameter in ' + ParamList); Exit; end;
    RealPar := Copy(ParamList, S, L);
    if L = 4 then begin
      Result := StrToIntDef('$' + RealPar, 70000);
      if Result = 70000 then Result := GetVar(RealPar);
    end else begin
      Result := StrToIntDef(RealPar[1] + '1', 1) * StrToIntDef('$' + Copy(RealPar, 2, 4), 70000);
      if Abs(Result) = 70000 then Result := StrToIntDef(RealPar[1] + '1', 1) * GetVar(Copy(RealPar, 2, 4));
    end;
  end;
  // Bedingung testen
  function ConditionIsTrue(Condition: string): Boolean;
  var
    LeftVar, RightVar: Integer;
  begin
    if (Condition = 'always') then begin Result := True; Exit; end;
    if Length(Condition) <> 9 then begin Log.Add('Falsche Bedingung in ' + Script + '! Bedingung: ' + Condition); Result := False; Exit; end;
    LeftVar := ParamToInt(Condition, 1, 4);
    RightVar := ParamToInt(Condition, 6, 4);
    Result := False;
    if (Condition[5] = '=') and (LeftVar = RightVar) then Result := True;
    if (Condition[5] = '!') and (LeftVar <> RightVar) then Result := True;
    if (Condition[5] = '<') and (LeftVar < RightVar) then Result := True;
    if (Condition[5] = '>') and (LeftVar > RightVar) then Result := True;
    if (Condition[5] = '"') and (Abs(LeftVar - RightVar) <= 16) then Result := True;
    if (Condition[5] = '''') and (Abs(LeftVar - RightVar) > 16) then Result := True;
    if (Condition[5] = '{') and (LeftVar <= RightVar) then Result := True;
    if (Condition[5] = '}') and (LeftVar >= RightVar) then Result := True;
  end;
  // Befehl ausf¸hren
  procedure ExecuteCommand(Command: string);
  var
    ParserPos, J, K, H: Integer;
    TempCond: string;
  begin
    // Nur, wenn Script <> ''
    if Command = '' then Exit;

    // Wenn Aufrufer stimmt, dann...
    if Command[1] = '_' then begin
      if Cond then ParserPos := 2 else Exit;
    end else begin
      // Nur wenn Caller richtig
      if Caller + '(' <> Copy(Command, 1, Length(Caller) + 1) then begin Cond := False; Exit; end;
      // ...Bedingung herausfiltern...
      TempCond := ''; ParserPos := Length(Caller) + 2;
      while Command[ParserPos] <> ')' do begin
        TempCond := TempCond + Command[ParserPos];
        Inc(ParserPos);
      end;
      // ...und Parserposition setzen.
      Inc(ParserPos, 2);
      // Jede Bedingung auswerten
      Cond := True;
      for J := 0 to ((Length(TempCond) + 1) div 10) - 1 do begin
        Cond := Cond and ConditionIsTrue(Copy(TempCond, J * 10 + 1, 9));
      end;
    end;
    if not Cond then Exit;

    // Bedingung ist wahr: Befehl ausf¸hren

    // set - Spielvariable setzen
    if Copy(Command, ParserPos, 4) = 'set ' then begin
      if Length(Command) - ParserPos < 13 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      SetVar(Copy(Command, ParserPos + 4, 4), ParamToInt(Command, ParserPos + 9, 5));
      Exit;
    end;

    // add - Zu Spielvariable addieren
    if Copy(Command, ParserPos, 4) = 'add ' then begin
      if Length(Command) - ParserPos < 13 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end; 
      SetVar(Copy(Command, ParserPos + 4, 4), GetVar(Copy(Command, ParserPos + 4, 4)) + ParamToInt(Command, ParserPos + 9, 5));
      Exit;
    end;

    // mul - Spielvariable multiplizieren
    if Copy(Command, ParserPos, 4) = 'mul ' then begin
      if Length(Command) - ParserPos < 13 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      SetVar(Copy(Command, ParserPos + 4, 4), GetVar(Copy(Command, ParserPos + 4, 4)) * ParamToInt(Command, ParserPos + 9, 5));
      Exit;
    end;

    // div - Spielvariable dividieren
    if Copy(Command, ParserPos, 4) = 'div ' then begin
      if Length(Command) - ParserPos < 13 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      SetVar(Copy(Command, ParserPos + 4, 4), GetVar(Copy(Command, ParserPos + 4, 4)) div ParamToInt(Command, ParserPos + 9, 5));
      Exit;
    end;

    // mapsolid - Spielvariable auf 0 oder 1 setzen, je nachdem
    if Copy(Command, ParserPos, 9) = 'mapsolid ' then begin
      if Length(Command) - ParserPos < 22 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      SetVar(Copy(Command, ParserPos + 9, 4), Integer(Data.Map.Solid(ParamToInt(Command, ParserPos + 14, 4), ParamToInt(Command, ParserPos + 19, 4))));
      Exit;
    end;

    // hit - Objektvariable verletzen und so
    if Copy(Command, ParserPos, 4) = 'hit ' then begin
      if Length(Command) - ParserPos < 5 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      if (GetObjVar(Copy(Command, ParserPos + 4, 2)) <> nil) and (GetObjVar(Copy(Command, ParserPos + 4, 2)).ClassType = TPMLiving) then
        TPMLiving(GetObjVar(Copy(Command, ParserPos + 4, 2))).Hit;
      Exit;
    end;

    // hurt - Objektvariable richtig bummen und so
    if Copy(Command, ParserPos, 5) = 'hurt ' then begin
      if Length(Command) - ParserPos < 6 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      if (GetObjVar(Copy(Command, ParserPos + 5, 2)) <> nil) and (GetObjVar(Copy(Command, ParserPos + 5, 2)).ClassType = TPMLiving) then
        TPMLiving(GetObjVar(Copy(Command, ParserPos + 5, 2))).Hurt(False);
      Exit;
    end;

    // kill - Objektvariable lˆschen
    if Copy(Command, ParserPos, 5) = 'kill ' then begin
      if Length(Command) - ParserPos < 6 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      if (GetObjVar(Copy(Command, ParserPos + 5, 2)) <> nil) and (GetObjVar(Copy(Command, ParserPos + 5, 2)) <> Data.ObjPlayers.Next) then
        GetObjVar(Copy(Command, ParserPos + 5, 2)).Kill;
      Exit;
    end;

    // find - Objektvariable setzen
    if Copy(Command, ParserPos, 5) = 'find ' then begin
      if Length(Command) - ParserPos < 36 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      SetObjVar(Copy(Command, ParserPos + 5, 2), FindObject(Data.ObjCollectibles, Data.ObjEnd,
                                                            ParamToInt(Command, ParserPos + 8, 4),
                                                            ParamToInt(Command, ParserPos + 13, 4), Bounds(
                                                            ParamToInt(Command, ParserPos + 18, 4),
                                                            ParamToInt(Command, ParserPos + 23, 4),
                                                            ParamToInt(Command, ParserPos + 28, 4),
                                                            ParamToInt(Command, ParserPos + 33, 4)
                                                            )));
      Exit;
    end;

    // setxd - ExtraData eines Objekts ‰ndern
    if Copy(Command, ParserPos, 6) = 'setxd ' then begin
      if GetObjVar(Copy(Command, ParserPos + 6, 2)) <> nil then
        GetObjVar(Copy(Command, ParserPos + 6, 2)).ExtraData := Copy(Command, ParserPos + 9, Length(Command) - ParserPos - 8);
      Exit;
    end;

    // message - Nachricht auf dem Bildschirm darstellen
    if Copy(Command, ParserPos, 8) = 'message ' then begin
      MessageText := Copy(Command, ParserPos + 8, Length(Command) - ParserPos - 7);
      MessageOpacity := 255;
      Exit;
    end;

    // message2 - Nachricht auf dem Bildschirm darstellen, dabei Variablen ersetzen
    if Copy(Command, ParserPos, 9) = 'message2 ' then begin
      MessageText := Copy(Command, ParserPos + 9, Length(Command) - ParserPos - 8);
      for K := 1 to Length(MessageText) - 4 do
        if MessageText[K] = '^' then begin
          H := Length(IntToStr(ParamToInt(MessageText, K + 1, 4)));
          Insert(IntToStr(ParamToInt(MessageText, K + 1, 4)), MessageText, K);
          Delete(MessageText, K + H, 5);
        end;
      MessageOpacity := 255;
      Exit;
    end;

    // sound - Einfach einen Sound abspielen
    if Copy(Command, ParserPos, 6) = 'sound ' then begin
      DXWaveListPack.Items.Find(Copy(Command, ParserPos + 6, Length(Command) - ParserPos - 5)).Play(False);
      Exit;
    end;

    // createobject - Objekt erstellen
    if Copy(Command, ParserPos, 13) = 'createobject ' then begin
      if Length(Command) - ParserPos < 29 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      SetObjVar(Copy(Command, ParserPos + 28, 2),
        CreateObject(Data, '',
                     ParamToInt(Command, ParserPos + 13, 4), // ID
                     ParamToInt(Command, ParserPos + 18, 4), // X
                     ParamToInt(Command, ParserPos + 23, 4), // Y
                     0, 0));
      Exit;
    end;

    // casteffects - Effekte erstellen
    if Copy(Command, ParserPos, 12) = 'casteffects ' then begin
      if Length(Command) - ParserPos < 35 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      CastFX(ParamToInt(Command, ParserPos + 12, 4), // Rauch
             ParamToInt(Command, ParserPos + 17, 4), // Feuer
             ParamToInt(Command, ParserPos + 22, 4), // Funkn
             ParamToInt(Command, ParserPos + 27, 4), // X
             ParamToInt(Command, ParserPos + 32, 4), // Y
             24, 24, 0, 0, 5, Data.OptEffects, Data.ObjEffects);
      Exit;
    end;

    // casteffects2 - Effekte erstellen, aber mit Stil
    if Copy(Command, ParserPos, 13) = 'casteffects2 ' then begin
      if Length(Command) - ParserPos < 63 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      CastFX(ParamToInt(Command, ParserPos + 13, 4), // Rauch
             ParamToInt(Command, ParserPos + 18, 4), // Feuer
             ParamToInt(Command, ParserPos + 23, 4), // Funkn
             ParamToInt(Command, ParserPos + 28, 4), // X
             ParamToInt(Command, ParserPos + 33, 4), // Y
             ParamToInt(Command, ParserPos + 38, 4), // Breite
             ParamToInt(Command, ParserPos + 43, 4), // Hˆhe
             ParamToInt(Command, ParserPos + 48, 5), // XDir
             ParamToInt(Command, ParserPos + 54, 5), // YDir
             ParamToInt(Command, ParserPos + 60, 4), // Rnd
             Data.OptEffects, Data.ObjEffects);
      Exit;
    end;

    // changetile - Kartenteil ver‰ndern
    if Copy(Command, ParserPos, 11) = 'changetile ' then begin
      if Length(Command) - ParserPos < 24 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      Data.Map.SetTile(ParamToInt(Command, ParserPos + 11, 4),  // X
                       ParamToInt(Command, ParserPos + 16, 4),  // Y
                       ParamToInt(Command, ParserPos + 21, 4)); // Tile
      Exit;
    end;

    // explosion - FOL EKSBLODIRREN MAAAAAHN
    if Copy(Command, ParserPos, 10) = 'explosion ' then begin
      if Length(Command) - ParserPos < 23 then begin Log.Add('Zu wenig Parameter in ' + Command + '!'); Exit; end;
      Explosion(ParamToInt(Command, ParserPos + 10, 4),
                ParamToInt(Command, ParserPos + 15, 4),
                ParamToInt(Command, ParserPos + 20, 4), Data, False);
      Exit;
    end;
  end;
begin
  Cond := True;
  CommandList := TStringList.Create;
  for I := 1 to Length(Script) do if Script[I] = '\' then begin
    CommandList.Add(Cmd); Cmd := '';
  end else Cmd := Cmd + Script[I];
  CommandList.Add(Cmd);
  for I := 0 to CommandList.Count - 1 do
    ExecuteCommand(CommandList.Strings[I]);
  CommandList.Free;
end;
=end
