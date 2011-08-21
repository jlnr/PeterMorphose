require 'rubygems'
require 'gosu'

# TODO Menu
# TODO Game
# TODO High Scores
# TODO SCript
# TODO Proper scaling
# TODO Packaging as gem
# TODO Deployment tasks

# What is a better way to do this?
File.dirname(File.dirname(__FILE__)).tap do |root|
  Dir.chdir root
  $LOAD_PATH << "#{root}/src"
end

require 'gosu-preview' # upcoming Gosu 0.8 interface wrapper
require 'const'
require 'title'

# Not yet part of gosu-preview
Gosu::enable_undocumented_retrofication rescue nil

# Simple implementation of the Gosu "State-Based" pattern
class Window < Gosu::Window
  # TODO move these variables somewhere
  # TempPath: string;
  #   Log: TStringList;
  #   QuickStart: Boolean;
  #   PlayerTopPos, LavaTopPos, LevelBottom: Integer;
  #   MessageText: string;
  #   MessageOpacity: Integer;
  #   Data: TPMData;
  #   CurrentTheme: string;
  #   LevelList: TList;
  #   SelectedLevel: Integer;
  #   LevelListTop: Integer;
  #   SelectedMenuItem: Integer;
  #   SelectedOptionItem: Integer;
  #   PseudoMusic: Integer;
  #   OldHiscore: Integer;
  
  def initialize
    super 640*3/2, 480*3/2
    
    self.caption = "Peter Morphose"
    
    @state = Title.new
    
    # TODO convert to states
    # // Log erstellen
    # Log := TStringList.Create;
    # Log.Add('Peter Morphose Logfile vom ' + DateToStr(Date) + '.');
    # Log.Add('Kommandozeile: ' + CmdLine);
    # Log.Add('');
    # Log.Add('');
    # Log.Add('Spiel gestartet. Version: ' + PMVersion + '.');
    # 
    # // PeterM.ini ˆffnen
    # PeterM_ini := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
    # // Timer einstellen
    # DXTimer.Interval := PeterM_ini.ReadInteger('Options', 'RefreshInterval', 45);
    # // Anderen Spielkrams einlesen
    # with Data do begin
    #   OptMusic := PeterM_ini.ReadInteger('Options', 'Music', 1);
    #   PseudoMusic := OptMusic;
    #   OptEffects := PeterM_ini.ReadInteger('Options', 'Effects', 100);
    #   OptEffects := Min(Max(Data.OptEffects, 0), 250);
    #   OptQuality := PeterM_ini.ReadInteger('Options', 'Quality', 1);
    #   OptEffectsDistance := PeterM_ini.ReadInteger('Options', 'EffectsDistance', 800);
    #   OptBlood := PeterM_ini.ReadInteger('Options', 'Blood', 0);
    #   OptOldJumping := PeterM_ini.ReadInteger('Options', 'OldJumping', 0);
    #   OptATI := PeterM_ini.ReadInteger('Options', 'IHateFuchsia', 0);
    #   OptShowStatus := PeterM_ini.ReadInteger('Options', 'ShowStatus', 0);
    #   OptShowTexts := PeterM_ini.ReadInteger('Options', 'ShowTexts', 1);
    #   OptLog := PeterM_ini.ReadInteger('Options', 'Log', 0);
    # end;
    # // PeterM.ini schlieﬂen
    # PeterM_ini.Free;
    # 
    # // Data initialisieren
    # Data.Images := DXImageListPack.Items;
    # Data.Waves := DXWaveListPack.Items;
    # Data.FontPic := DXImageList.Items[Image_Font];
    # Data.DXDraw := DXDraw;
    # Data.Input := DXInput;
    # Data.Map := TPMMap.Create;
    # // Objektlistenplatzhalter einrichten
    # Data.ObjCollectibles := TPMObjBreak.Create(nil, 'Einsammelbare Objekte', ID_Break, 0, 0, 0, 0);
    # Data.ObjEnd := TPMObjBreak.Create(nil, 'Objektlistenende', ID_Break, 0, 0, 0, 0);
    # Data.ObjCollectibles.Data := @Data;
    # Data.ObjCollectibles.Next := Data.ObjEnd;
    # Data.ObjEnd.Last := Data.ObjCollectibles;
    # Data.ObjOther := TPMObjBreak.Create(Data.ObjCollectibles, 'Andere Objekte', ID_Break, 0, 0, 0, 0);
    # Data.ObjEnemies := TPMObjBreak.Create(Data.ObjOther, 'Gegner', ID_Break, 0, 0, 0, 0);
    # Data.ObjPlayers := TPMObjBreak.Create(Data.ObjEnemies, 'Spieler', ID_Break, 0, 0, 0, 0);
    # Data.ObjEffects := TPMObjBreak.Create(Data.ObjPlayers, 'Effekte', ID_Break, 0, 0, 0, 0);
    # Data.ExecuteScript := ES;
    # 
    # // Quickstart?
    # if ParamStr(1) <> '' then begin
    #   QuickStart := True;
    #   StartGame(ParamStr(1));
    #   if Data.OptMusic = 1 then begin
    #     MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\' + CurrentTheme + '.mid';
    #     MediaPlayer.Open;
    #     MediaPlayer.Play;
    #   end;
    #   Log.Add('Schnellstart von ' + ParamStr(1));
    #   Exit;
    # end else Data.State := State_Welcome;
    # 
    # // Wenn nicht, dann Levelinfoliste erstellen
    # LevelList := TList.Create;
    # // Levelliste laden
    # if FindFirst(ExtractFileDir(ParamStr(0)) + '\*.pml', faAnyFile, SearchRec) = 0 then begin
    #   LevelList.Add(TPMLevelInfo.Create(ExtractFileDir(ParamStr(0)) + '\' + SearchRec.Name));
    #   while FindNext(SearchRec) = 0 do begin
    #     LevelList.Add(TPMLevelInfo.Create(ExtractFileDir(ParamStr(0)) + '\' + SearchRec.Name));
    #   end;
    #   FindClose(SearchRec);
    # end;
    # // Levelliste sortieren
    # LevelList.Sort(LevelComp);
    # 
    # // Musik starten
    # if Data.OptMusic = 1 then begin
    #   MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\Menu.mid';
    #   MediaPlayer.Open;
    #   MediaPlayer.Play;
    # end;
    
  end
  
  def update
    # TODO split into states
    # // Musikverwaltung
    # if Data.OptMusic = 1 then begin
    #   if (Data.State in [0..99, 200..255]) and (MediaPlayer.FileName <> ExtractFileDir(ParamStr(0)) + '\Menu.mid')
    #     then begin
    #       MediaPlayer.Stop;
    #       MediaPlayer.Close;
    #       MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\Menu.mid';
    #       MediaPlayer.Open;
    #       MediaPlayer.Play;
    #     end;
    #   if (Data.State in [100..199]) and (MediaPlayer.FileName <> ExtractFileDir(ParamStr(0)) + '\' + CurrentTheme + '.mid')
    #     then begin
    #       MediaPlayer.Stop;
    #       MediaPlayer.Close;
    #       MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\' + CurrentTheme + '.mid';
    #       MediaPlayer.Open;
    #       MediaPlayer.Play;
    #     end;
    #   if MediaPlayer.Position = MediaPlayer.Length then begin MediaPlayer.Rewind; MediaPlayer.Play; end; 
    # end;
    # // Rest
    # case Data.State of
    #   State_Welcome: begin
    #     // Introbild malen
    #     if not (DXDraw.CanDraw and Application.Active) then Exit;
    #     DXImageList.Items[Image_Title].Draw(DXDraw.Surface, 0, 0, 0);
    #     DrawBMPText('Version: 1.02.     http://www.petermorphose.de/', 109, 440, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    #     DXDraw.Flip;
    #   end;
    #   State_MainMenu: begin
    #     if not (DXDraw.CanDraw and Application.Active) then Exit;
    #     DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);
    # 
    #     DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120,  20, 0 + Integer(SelectedMenuItem = 0));
    #     DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120,  90, 2 + Integer(SelectedMenuItem = 1));
    #     DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120, 160, 4 + Integer(SelectedMenuItem = 2));
    #     DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120, 230, 6 + Integer(SelectedMenuItem = 3));
    #     DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120, 300, 8 + Integer(SelectedMenuItem = 4));
    # 
    #     DrawBMPText('W‰hle mit den Pfeiltasten aus, was du tun willst und dr¸cke Enter.', 23, 435, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
    #     DXDraw.Flip;
    #   end;
    #   State_LevelSelection: begin
    #     // Levelauswahl anzeigen
    #     if not (DXDraw.CanDraw and Application.Active) then Exit;
    #     DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);
    #     for LoopY := 0 to Min(4, LevelList.Count) - 1 do
    #       TPMLevelInfo(LevelList.Items[LoopY + LevelListTop]).Draw(LoopY * 100, LoopY + LevelListTop = SelectedLevel, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     DXDraw.Surface.FillRect(Bounds(631, 0,  1, 400), DXDraw.Surface.ColorMatch($003010));
    #     DXDraw.Surface.FillRect(Bounds(632, 0, 16, 400), DXDraw.Surface.ColorMatch($004020));
    #     if LevelList.Count > 4 then DXImageList.Items[Image_Font].DrawAdd(DXDraw.Surface, Bounds(632, Round(384 * ((LevelListTop) / (LevelList.Count - 4))), 8, 16), 95, 128);
    #     DrawBMPText('W‰hle mit den Pfeiltasten ein Level aus und starte es mit Enter.', 32, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
    #     DrawBMPText('Willst du zur¸ck zum Hauptmen¸, dr¸cke Escape.', 113, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
    #     DXDraw.Flip;
    #   end;
    #   State_WonInfo: begin
    #     if not (DXDraw.CanDraw and Application.Active) then Exit;
    #     DXDraw.Surface.Fill(0);
    #     DXImageList.Items[Image_Won].Draw(DXDraw.Surface, 0, 0, 0);
    #     DrawBMPText('‹brige Lebensenergie (je Punkt 5 Punkte):              ' + IntToStr(TPMLiving(Data.ObjPlayers.Next).Life),             40, 150, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     DrawBMPText('‹brige Schl¸ssel (je Schl¸ssel 25 Punkte):             ' + IntToStr(Data.Keys),                                        40, 180, 245, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     DrawBMPText('‹brige Sterne (je Stern 3 Punkte):                     ' + IntToStr(Data.Stars - Data.StarsGoal),                      40, 210, 235, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     DrawBMPText('‹brige Munition (je Schuss 2 Punkte):                  ' + IntToStr(Data.Ammo),                                        40, 240, 225, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     DrawBMPText('‹brige Bomben (je Bombe 5 Punkte):                     ' + IntToStr(Data.Bombs),                                       40, 270, 215, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     if Data.Map.LavaScore = 1 then begin
    #       DrawBMPText('‹brige Lava-Einfrierzeit (pro Bild 1 Punkt):           ' + IntToStr(Data.Map.LavaTimeLeft) + ' Bilder',                40, 300, 205, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #       DrawBMPText('Abstand zur Lava bei Spielende (pro Pixel 0.1 Punkte): ' + IntToStr(Data.Map.LavaPos - Data.Map.LevelTop) + ' Pixel',  40, 330, 195, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     end;
    #     DrawBMPText('Gesamtpunktestand:                                    ' + IntToStr(Data.Score) + ' Punkte!',                          40, 380, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     DrawBMPText('(Taste dr¸cken)', 252, 440, 128, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
    #     DXDraw.Flip;
    #   end;
    #   State_Paused, State_Game, State_Dead, State_Won: begin
    #     // W‰re State_Dead nicht doch passender?
    #     if (Data.State = State_Game) and ((Data.ObjPlayers.Next = Data.ObjEffects) or (TPMLiving(Data.ObjPlayers.Next).Action = Act_Dead)) then
    #       begin Data.State := State_Dead; Log.Add('Spieler gestorben.'); end;
    #     // Gewonnen?
    #     if (Data.State = State_Game) and (Data.ObjPlayers.Next.PosY < Data.Map.LevelTop) then
    #       if (Data.Stars >= Data.StarsGoal) and (FindObject(Data.ObjCollectibles, Data.ObjOther, ID_Carolin, ID_Carolin, Bounds(0, 0, 576, 24576)) = nil) then begin
    #         Data.State := State_Won; Log.Add('Gewonnen!');
    #         Log.Add('Es ist ' + TimeToStr(Time) + '.');
    #         Log.Add('‹brige Lebensenergie (je Punkt 5 Punkte):              ' + IntToStr(TPMLiving(Data.ObjPlayers.Next).Life));
    #         Inc(Data.Score, TPMLiving(Data.ObjPlayers.Next).Life * 5);
    #         Log.Add('‹brige Schl¸ssel (je Schl¸ssel 25 Punkte):             ' + IntToStr(Data.Keys));
    #         Inc(Data.Score, Data.Keys * 25);
    #         Log.Add('‹brige Sterne (je Sterne 3 Punkte):                    ' + IntToStr(Data.Stars - Data.StarsGoal));
    #         Inc(Data.Score, (Data.Stars - Data.StarsGoal) * 3);
    #         Log.Add('‹brige Munition (je Schuss 2 Punkte):                  ' + IntToStr(Data.Ammo));
    #         Inc(Data.Score, Data.Ammo * 2);
    #         Log.Add('‹brige Bomben (je Bombe 5 Punkte):                     ' + IntToStr(Data.Bombs));
    #         Inc(Data.Score, Data.Bombs * 5);
    #         if Data.Map.LavaScore = 1 then begin
    #           Log.Add('‹brige Lava-Einfrierzeit (pro Bild 1 Punkt):           ' + IntToStr(Data.Map.LavaTimeLeft) + ' Bilder');
    #           Inc(Data.Score, Data.Map.LavaTimeLeft);
    #           Log.Add('Abstand zur Lava bei Spielende (pro Pixel 0.1 Punkte): ' + IntToStr(Data.Map.LavaPos - Data.Map.LevelTop) + ' Pixel');
    #           Inc(Data.Score, (Data.Map.LavaPos - Data.Map.LevelTop) div 10);
    #         end;
    #         Log.Add('Gesamtpunktestand:                                     ' + IntToStr(Data.Score) + ' Punkte!');
    #       end else begin
    #         Data.State := State_Dead; Log.Add('Zu wenig Sterne oder Geiseln ¸brig - verloren.');
    #       end;
    #     // Normaler Verlauf
    #     if Data.State = State_Game then begin
    #       // Bildz‰hler erhˆhen
    #       Inc(Data.Frame);
    #       if Data.Frame = 2400 then Data.Frame := 0;
    #       if MessageOpacity > 0 then Dec(MessageOpacity, 3);
    # 
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
    # 
    #       // Lava steigen lassen
    #       if (Data.Map.LavaTimeLeft = 0) then begin if (Data.Map.LavaSpeed <> 0) then begin
    #         if (Data.Map.LavaMode = 0) and ((Data.Frame mod Data.Map.LavaSpeed) = 0) then Dec(Data.Map.LavaPos);
    #         if (Data.Map.LavaMode = 1) then Dec(Data.Map.LavaPos, Data.Map.LavaSpeed);
    #         Inc(Data.Map.LavaFrame);
    #         if Data.Map.LavaFrame = 120 then Data.Map.LavaFrame := 0;
    #         if (Data.Frame mod 10 = 0) and (Random(10) = 0) then DistSound(Data.Map.LavaPos, Sound_Lava, Data);
    #       end; end else Dec(Data.Map.LavaTimeLeft);
    #       // Spezialpeterzeit ablaufen lassen
    #       if Data.ObjPlayers.Next.ID > ID_Player then begin
    #         Dec(Data.TimeLeft);
    #         if Data.TimeLeft = 0 then begin
    #           Data.ObjPlayers.Next.ID := ID_Player;
    #           CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
    #         end;
    #       end;
    #       if Data.InvTimeLeft > 0 then Dec(Data.InvTimeLeft);
    #       // Bestimmen, welcher Teil des Levels angezeigt wird
    #       Data.ViewPos := Max(Min(Min(Data.Map.LavaPos - 432, Data.ObjPlayers.Next.PosY - 240), 24096), Data.Map.LevelTop);
    #     end;
    #     if Data.State = State_Game then begin
    #       // Spielersteuerung
    #       DXInput.Update;
    #       // Steuerung f¸r normalen Peter
    #       if (Data.FlyTimeLeft = 0) and (not Data.ObjPlayers.Next.InWater) then begin
    #         // Nach links bewegen
    #         if isLeft in DXInput.States then with TPMLiving(Data.ObjPlayers.Next) do begin
    #           if (not Busy) and (VelX > -Round(Data.Defs[ID].Speed * 1.75)) then Dec(VelX, Data.Defs[ID].Speed + Integer(Data.SpeedTimeLeft > 0) * 6);
    #           if Data.OptOldJumping = 1 then begin
    #             if (Action = Act_Jump) or (Action = Act_Land)
    #             or (Action = Act_Pain1) or (Action = Act_Pain2) then begin
    #               if not Blocked(Dir_Left) then Dec(PosX);
    #               if not Blocked(Dir_Left) then Dec(PosX);
    #               if not Blocked(Dir_Left) and (Action = Act_Land) then Dec(PosX);
    #               if not Blocked(Dir_Left) and (Action = Act_Land) then Dec(PosX);
    #             end;
    #           end else begin
    #             if (Action in [Act_Jump, Act_Pain1, Act_Pain2]) and (VelX > -Data.Defs[ID].JumpX - 2) then Dec(VelX);
    #             if (Action = Act_Land) and (VelX > -Data.Defs[ID].JumpX - 3) then Dec(VelX);
    #           end;
    #         end else
    #           if (Data.OptOldJumping = 0) and (Data.Frame mod 3 = 0) and (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Jump, Act_Land]) and (Data.ObjPlayers.Next.VelX < -1) then Inc(Data.ObjPlayers.Next.VelX);
    #         // Nach rechts bewegen
    #         if isRight in DXInput.States then with TPMLiving(Data.ObjPlayers.Next) do begin
    #           if (not Busy) and (VelX < +Round(Data.Defs[ID].Speed * 1.75)) then Inc(VelX, Data.Defs[ID].Speed + Integer(Data.SpeedTimeLeft > 0) * 6);
    #           if Data.OptOldJumping = 1 then begin
    #             if (Action = Act_Jump) or (Action = Act_Land)
    #             or (Action = Act_Pain1) or (Action = Act_Pain2) then begin
    #               if not Blocked(Dir_Right) then Inc(PosX);
    #               if not Blocked(Dir_Right) then Inc(PosX);
    #               if not Blocked(Dir_Right) and (Action = Act_Land) then Inc(PosX);
    #               if not Blocked(Dir_Right) and (Action = Act_Land) then Inc(PosX);
    #             end;
    #           end else begin
    #             if (Action in [Act_Jump, Act_Pain1, Act_Pain2]) and (VelX < +Data.Defs[ID].JumpX + 2) then Inc(VelX);
    #             if (Action = Act_Land) and (VelX < +Data.Defs[ID].JumpX + 3) then Inc(VelX);
    #           end;
    #         end else
    #           if (Data.OptOldJumping = 0) and (Data.Frame mod 3 = 0) and (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Jump, Act_Land]) and (Data.ObjPlayers.Next.VelX > 1) then Dec(Data.ObjPlayers.Next.VelX);
    #       end else with TPMLiving(Data.ObjPlayers.Next) do begin
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
    #       if Data.SpeedTimeLeft > 0 then begin
    #         Dec(Data.SpeedTimeLeft);
    #         CastObjects(ID_FXSpark, Random(2), 0, 0, 1, Data.OptEffects, Data.ObjPlayers.Next.GetRect(1, 1), Data.ObjEffects);
    #       end;
    #       if Data.JumpTimeLeft > 0 then Dec(Data.JumpTimeLeft);
    #       if Data.FlyTimeLeft > 0 then Dec(Data.FlyTimeLeft);
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
    # 
    #       // Objekte berechnen
    #       TempObj := Data.ObjCollectibles.Next;
    #       while TempObj <> Data.ObjEnd do begin
    #         TempObj.Update;
    #         TempObj := TempObj.Next;
    #       end;
    #       // Jetzt noch die kaputten lˆschen
    #       TempObj := Data.ObjCollectibles.Next;
    #       while TempObj <> nil do begin
    #         if TempObj.Last.Marked then TempObj.Last.ReallyKill;
    #         TempObj := TempObj.Next;
    #       end;
    #       // Ab und zu mal ein Rauchwˆlkchen und Flammen aus der Lava steigen lassen...
    #       if Data.Map.LavaTimeLeft = 0 then begin
    #         CastFX(Random(2) + 1, Random(2) + 1, 0, 288, Data.Map.LavaPos, 576, 8, 1, -4, 1, Data.OptEffects, Data.ObjEffects);
    #         if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
    #         if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
    #         if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
    #       end;
    #     end;
    
    @state.update
  end
  
  def draw
    # TODO split into states
    # // Alles zeichnen
    # if not (DXDraw.CanDraw and Application.Active) then Exit;
    #                                                                                
    # // Erstmal den Hintergrund
    # case Data.Map.Sky of
    #   0: for LoopY := 0 to 3 do
    #        for LoopX := 0 to 3 do
    #          DXImageListPack.Items[Image_Sky].Draw(DXDraw.Surface, LoopX * 144, LoopY * 120, Data.Map.Sky);
    #   else
    #     for LoopY := 0 to 4 do
    #       for LoopX := 0 to 3 do
    #         DXImageListPack.Items[Image_Sky].Draw(DXDraw.Surface, LoopX * 144, LoopY * 120 - Data.ViewPos mod 120, Data.Map.Sky);
    # end;
    # // Danach die Karte
    # YTop := Data.ViewPos mod 24; YRow := Data.ViewPos div 24;
    # for LoopY := 0 to 20 do for LoopX := 0 to 23 do
    #   if Data.Map.Tiles[LoopX, YRow + LoopY] <> 0 then DXImageListPack.Items[Image_Tiles].Draw(DXDraw.Surface, LoopX * 24, LoopY * 24 - YTop, Data.Map.Tiles[LoopX, YRow + LoopY]);
    # 
    # // Objekte zeichnen
    # TempObj := Data.ObjCollectibles.Next;
    # while TempObj <> Data.ObjEnd do begin
    #   TempObj.Draw;
    #   TempObj := TempObj.Next;
    # end;
    # 
    # // Zum Schluss die bˆhze Gefahr, die von unten aufsteigt
    # for LoopX := -1 to 4 do
    #   DXImageListPack.Items[Image_Danger].Draw(DXDraw.Surface, LoopX * 120 + Data.Map.LavaFrame, Data.Map.LavaPos - Data.ViewPos + Integer(Data.Map.LavaTimeLeft = 0) * ((Data.Frame div 2) mod 2), Min(1, Data.Map.LavaTimeLeft));
    # if Data.Map.LavaPos < Data.Map.LevelTop + 432 then
    #   for LoopX := -1 to 4 do
    #     for LoopY := 0 to (Data.Map.LevelTop + 432 - Data.Map.LavaPos) div 48 + 1 do
    #   DXImageListPack.Items[Image_Danger].Draw(DXDraw.Surface, LoopX * 120 + Data.Map.LavaFrame, Data.Map.LavaPos - Data.ViewPos + 48 + LoopY * 48 + Integer(Data.Map.LavaTimeLeft = 0) * ((Data.Frame div 2) mod 2), Min(1, Data.Map.LavaTimeLeft) + 2);
    # 
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
    
    scale(1.5) do
      @state.draw
    end
  end
  
  def button_down id
    # TODO split into states
    # procedure TFormPeterM.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    # var
    #   OptionFile: TIniFile32;
    # begin
    #   // Escape: Beenden oder Status wechseln
    #   if Key = VK_Escape then begin
    #     if Data.State in [State_LevelSelection, State_Credits, State_ReadMe1..State_ReadMe8] then begin
    #       DXWaveList.Items[Sound_WooshBack].Play(False);
    #       Data.State := State_MainMenu;
    #       Exit;
    #     end;
    #     if Data.State in [State_Game, State_Paused, State_Dead] then begin
    #       if Data.State in [State_Game, State_Paused] then Log.Add('Level abgebrochen.');
    #       if QuickStart then Close else DXWaveList.Items[Sound_WooshBack].Play(False);
    #       Data.State := State_LevelSelection;
    #       Exit;
    #     end;
    #     if Data.State in [State_Options, State_Options2] then begin
    #       DXWaveList.Items[Sound_WooshBack].Play(False);
    #       Data.State := State_MainMenu;
    #       OptionFile := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
    #       OptionFile.WriteInteger('Options', 'Music', PseudoMusic);
    #       OptionFile.WriteInteger('Options', 'ShowStatus', Data.OptShowStatus);
    #       OptionFile.WriteInteger('Options', 'ShowTexts', Data.OptShowTexts);
    #       OptionFile.WriteInteger('Options', 'Effects', Data.OptEffects);
    #       OptionFile.WriteInteger('Options', 'Quality', Data.OptQuality);
    #       OptionFile.WriteInteger('Options', 'Blood', Data.OptBlood);
    #       OptionFile.WriteInteger('Options', 'OldJumping', Data.OptOldJumping);
    #       OptionFile.WriteInteger('Options', 'IHateFuchsia', Data.OptATI);
    #       OptionFile.Free;
    #       Exit;
    #     end;
    #   end;
    # 
    #   // P: Pause an/aus
    #   if Key = Ord('P') then begin
    #     if Data.State = State_Paused then begin Data.State := State_Game; Exit; end else
    #       if Data.State = State_Game then begin Data.State := State_Paused; Exit; end;
    #   end;
    # 
    #   // Andere Knˆpfe je nach Status auswerten
    #   case Data.State of
    #     State_Welcome: if not (ssAlt in Shift) then begin Data.State := State_MainMenu; DXWaveList.Items[Sound_Woosh].Play(False); end;
    #     State_MainMenu: case Key of
    #       VK_Up, VK_Left: if SelectedMenuItem > 0 then Dec(SelectedMenuItem);
    #       VK_Down, VK_Right: if SelectedMenuItem < 4 then Inc(SelectedMenuItem);
    #       VK_Return, VK_Space: if not (ssAlt in Shift) then case SelectedMenuItem of
    #                                                           0: begin Data.State := State_LevelSelection; DXWaveList.Items[Sound_Woosh].Play(False); end;
    #                                                           1: begin DXWaveList.Items[Sound_Woosh].Play(False); DXDraw.Surface.Fill(0); DrawBMPText('Hilfe wird geladen...', 225, 230, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality); DXDraw.Flip; DXImageListPack.Items.LoadFromFile(ExtractFileDir(ParamStr(0)) + '\Ritter.pmt'); Data.State := State_ReadMe1; end;
    #                                                           2: begin Data.State := State_Options; DXWaveList.Items[Sound_Woosh].Play(False); end;
    #                                                           3: begin Data.State := State_Credits; DXWaveList.Items[Sound_Woosh].Play(False); end;
    #                                                           4: begin DXWaveList.Items[Sound_WooshBack].Play(True); Close; end;
    #                                                         end;
    #                     end;
    #     State_Options: case Key of
    #       VK_Up: if SelectedOptionItem > 0 then Dec(SelectedOptionItem);
    #       VK_Down: if SelectedOptionItem < 4 then Inc(SelectedOptionItem);
    #       VK_Left: case SelectedOptionItem of
    #         0: PseudoMusic := 0;
    #         1: Data.OptBlood := 0;
    #         2: Data.OptShowStatus := 0;
    #         3: Data.OptATI := 0;
    #                end;
    #       VK_Right: case SelectedOptionItem of
    #         0: PseudoMusic := 1;
    #         1: Data.OptBlood := 1;
    #         2: Data.OptShowStatus := 1;
    #         3: Data.OptATI := 1;
    #         4: Data.State := State_Options2;
    #                 end;
    #                    end;
    #     State_Options2: case Key of
    #       VK_Up: if SelectedOptionItem > 0 then Dec(SelectedOptionItem);
    #       VK_Down: if SelectedOptionItem < 4 then Inc(SelectedOptionItem);
    #       VK_Left: case SelectedOptionItem of
    #         0: if Data.OptQuality > 0 then Dec(Data.OptQuality);
    #         1: if Data.OptEffects > 4 then Dec(Data.OptEffects, 5);
    #         2: Data.OptOldJumping := 1;
    #         3: Data.OptShowTexts := 0;
    #         4: Data.State := State_Options;
    #                end;
    #       VK_Right: case SelectedOptionItem of
    #         0: if Data.OptQuality < 2 then Inc(Data.OptQuality);
    #         1: if Data.OptEffects < 246 then Inc(Data.OptEffects, 5);
    #         2: Data.OptOldJumping := 0;
    #         3: Data.OptShowTexts := 1;
    #                 end;
    #                    end;
    #     State_ReadMe1..State_ReadMe8: case Key of
    #       VK_Up, VK_Left: if Data.State > State_ReadMe1 then Dec(Data.State);
    #       VK_Down, VK_Right: if Data.State < State_ReadMe8 then Inc(Data.State);
    #                                   end;
    #     State_LevelSelection: case Key of
    #       VK_Up, VK_Left: if SelectedLevel > 0 then begin
    #                         Dec(SelectedLevel);
    #                         if SelectedLevel < LevelListTop then Dec(LevelListTop);
    #                       end;
    #       VK_Down, VK_Right: if SelectedLevel < LevelList.Count - 1 then begin
    #                         Inc(SelectedLevel);
    #                         if SelectedLevel > LevelListTop + 3 then Inc(LevelListTop);
    #                       end;
    #       VK_Return, VK_Space: if not (ssAlt in Shift) then begin DXWaveList.Items[Sound_Woosh].Play(False); DXDraw.Surface.Fill(0); DrawBMPText('Level wird geladen...', 225, 230, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality); DXDraw.Flip; StartGame(TPMLevelInfo(LevelList.Items[SelectedLevel]).Location); end;
    #     end;
    #     State_Game: case Key of
    #       VK_Up:    if Data.FlyTimeLeft = 0 then TPMLiving(Data.ObjPlayers.Next).Jump;
    #       VK_Down:  if Data.FlyTimeLeft = 0 then TPMLiving(Data.ObjPlayers.Next).UseTile;
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
    #   end;
    # end;
    
    @state.button_down id
  end
  
  def button_up id
    @state.button_up id
  end
  
  def needs_cursor?
    @state.needs_cursor?
  end
end

Window.new.show
