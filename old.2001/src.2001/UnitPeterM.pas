////////////////////////////////////////////////////////////
// Peter Morphose - von Julian Raschke, julian@raschke.de //
////////////////////////////////////////////////////////////

unit UnitPeterM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, DXDraws, DXInput, DXClass, DXSounds,
  IniFiles32, PMObjects, PMMaps, PMConst, MPlayer;

const
  // Systembilder
  Image_Font           = 0;
  Image_Title          = 1;
  Image_TitleDark      = 2;
  Image_GameDialogs    = 3;
  Image_Won            = 4;
  Image_Buttons        = 5;

type
  TPMLevelInfo = class
    Title, Skill, Desc, Theme, Location: string;
    StarsToGet, Hiscore: Integer;
    Carolin: Boolean; CarolinName, Author: string;
    constructor Create(FileName: string);
    procedure Draw(Y: Integer; Active: Boolean; FontPic: TPictureCollectionItem; Surface: TDirectDrawSurface; Quality: Integer);
  end;
  TFormPeterM = class(TDXForm)
    DXDraw: TDXDraw;
    DXTimer: TDXTimer;
    DXInput: TDXInput;
    DXImageList: TDXImageList;
    DXImageListPack: TDXImageList;
    DXSound: TDXSound;
    DXWaveListPack: TDXWaveList;
    MediaPlayer: TMediaPlayer;
    DXWaveList: TDXWaveList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
  private
    TempPath: string;
    Log: TStringList;
    QuickStart: Boolean;
    PlayerTopPos, LavaTopPos, LevelBottom: Integer;
    MessageText: string;
    MessageOpacity: Integer;
    Data: TPMData;
    CurrentTheme: string;
    LevelList: TList;
    SelectedLevel: Integer;
    LevelListTop: Integer;
    SelectedMenuItem: Integer;
    SelectedOptionItem: Integer;
    PseudoMusic: Integer;
    OldHiscore: Integer;
    procedure StartGame(LevelFile: string);
    procedure ExecuteScript(Script, Caller: string);
  end;

procedure ES(Script, Caller: string);
function LevelComp(Item1, Item2: Pointer): Integer;
function Muesli(Int: Integer): string;
function DeMuesli(Str: string): Integer;

var
  FormPeterM: TFormPeterM;

implementation

{$R *.DFM}

constructor TPMLevelInfo.Create(FileName: string);
var
  Level, Ini: TIniFile32; I, CarolinCount: Integer; TempStr: string;
begin
  Level := TIniFile32.Create(FileName);
  Title := Level.ReadString('Info', 'Title', 'Unbenannte Karte');
  Skill := Level.ReadString('Info', 'Skill', '');
  Desc  := Level.ReadString('Info', 'Desc', '');
  Theme := Level.ReadString('Info', 'Theme', 'Ritter');
  Author := Level.ReadString('Info', 'Author', 'Anonym, email@adresse');
  StarsToGet := Level.ReadInteger('Map', 'StarsGoal', 100);
  I := 0; CarolinCount := 0; Carolin := False;
  while True do begin
    TempStr := Level.ReadString('Objects', IntToStr(I), '');
    if TempStr = '' then Break;
    if Copy(TempStr, 1, 2) = IntToHex(ID_Carolin, 2) then begin
      Carolin := True;
      TempStr := Level.ReadString('Objects', IntToStr(I) + 'Y', '0|Carolin');
      if Length(TempStr) <= 2 then CarolinName := 'Carolin' else CarolinName := Copy(TempStr, 3, Length(TempStr) - 2);
      Inc(CarolinCount);
    end;
    Inc(I);
  end;
  if CarolinCount > 1 then CarolinName := IntToStr(CarolinCount) + ' Gefangene';
  Location := FileName;
  Ini := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
  Hiscore := DeMuesli(Ini.ReadString('Hiscore', ExtractFileName(ExtractShortPathName(Location)), 'Ungültig :('));
  Ini.Free;
  Level.Free;
end;

procedure TPMLevelInfo.Draw(Y: Integer; Active: Boolean; FontPic: TPictureCollectionItem; Surface: TDirectDrawSurface; Quality: Integer);
begin
  // Trennlinie oben
  Surface.FillRect(Bounds(0, Y, 631, 1), Surface.ColorMatch($003000));
  // Titel und Schwierigkeitsgrad
  if Hiscore > -1 then
    DrawBMPText(Title + ' (' + IntToStr(Hiscore) + ' Punkte)', 5, Y + 7, 255, FontPic, Surface, 0)
  else
    DrawBMPText(Title + ' (noch nicht geschafft)', 5, Y + 7, 255, FontPic, Surface, 0);
  DrawBMPText(Skill, 626 - Length(Skill) * 9, Y + 7, 255, FontPic, Surface, 0);
  // Beschreibungstext
  DrawBMPText(Desc, 5, Y + 30, 192, FontPic, Surface, Quality);
  // Einzusammelnde Sterne und evtl. Geiselname und Thema
  if (StarsToGet = 0) and not Carolin then
    DrawBMPText('Ziel: Durchkommen', 5, Y + 53, 128, FontPic, Surface, Quality);
  if (StarsToGet = 0) and Carolin then
    DrawBMPText('Ziel: ' + CarolinName + ' retten', 5, Y + 53, 128, FontPic, Surface, Quality);
  if (StarsToGet <> 0) and not Carolin then
    DrawBMPText('Ziel: ' + IntToStr(StarsToGet) + ' Sterne einsammeln', 5, Y + 53, 128, FontPic, Surface, Quality);
  if (StarsToGet <> 0) and Carolin then
    DrawBMPText('Ziel: ' + IntToStr(StarsToGet) + ' Sterne einsammeln und ' + CarolinName + ' retten', 5, Y + 53, 128, FontPic, Surface, Quality);
  DrawBMPText('Thema: ' + Theme, 626 - Length('Thema: ' + Theme) * 9, Y + 53, 128, FontPic, Surface, Quality);
  // Author
  DrawBMPText('Von ' + Author, 5, Y + 76, 80, FontPic, Surface, Quality);
  // Trennlinie unten
  Surface.FillRect(Bounds(0, Y + 99, 631, 1), Surface.ColorMatch($006000));
  // Aktiven Eintrag highlighten
  if Active then Surface.FillRectAdd(Bounds(0, Y + 1, 631, 98), RGB(96, 48, 0));
end;

procedure TFormPeterM.FormCreate(Sender: TObject);
var
  PeterM_ini: TIniFile32;
  SearchRec: TSearchRec;
  PC: PChar;
begin
  // Cursor ausblenden
  ShowCursor(False);

  // Temppfad setzen und so
  GetMem(PC, 129);
  GetTempPath(128, PC);
  TempPath := string(PC);
  FreeMem(PC, 129);

  // Log erstellen
  Log := TStringList.Create;
  Log.Add('Peter Morphose Logfile vom ' + DateToStr(Date) + '.');
  Log.Add('Kommandozeile: ' + CmdLine);
  Log.Add('');
  Log.Add('');
  Log.Add('Spiel gestartet. Version: ' + PMVersion + '.');

  // PeterM.ini öffnen
  PeterM_ini := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
  // Timer einstellen
  DXTimer.Interval := PeterM_ini.ReadInteger('Options', 'RefreshInterval', 45);
  // Anderen Spielkrams einlesen
  with Data do begin
    OptMusic := PeterM_ini.ReadInteger('Options', 'Music', 1);
    PseudoMusic := OptMusic;
    OptEffects := PeterM_ini.ReadInteger('Options', 'Effects', 100);
    OptEffects := Min(Max(Data.OptEffects, 0), 250);
    OptQuality := PeterM_ini.ReadInteger('Options', 'Quality', 1);
    OptEffectsDistance := PeterM_ini.ReadInteger('Options', 'EffectsDistance', 800);
    OptBlood := PeterM_ini.ReadInteger('Options', 'Blood', 0);
    OptOldJumping := PeterM_ini.ReadInteger('Options', 'OldJumping', 0);
    OptATI := PeterM_ini.ReadInteger('Options', 'IHateFuchsia', 0);
    OptShowStatus := PeterM_ini.ReadInteger('Options', 'ShowStatus', 0);
    OptShowTexts := PeterM_ini.ReadInteger('Options', 'ShowTexts', 1);
    OptLog := PeterM_ini.ReadInteger('Options', 'Log', 0);
  end;
  // PeterM.ini schließen
  PeterM_ini.Free;

  // Data initialisieren
  Data.Images := DXImageListPack.Items;
  Data.Waves := DXWaveListPack.Items;
  Data.FontPic := DXImageList.Items[Image_Font];
  Data.DXDraw := DXDraw;
  Data.Input := DXInput;
  Data.Map := TPMMap.Create;
  // Objektlistenplatzhalter einrichten
  Data.ObjCollectibles := TPMObjBreak.Create(nil, 'Einsammelbare Objekte', ID_Break, 0, 0, 0, 0);
  Data.ObjEnd := TPMObjBreak.Create(nil, 'Objektlistenende', ID_Break, 0, 0, 0, 0);
  Data.ObjCollectibles.Data := @Data;
  Data.ObjCollectibles.Next := Data.ObjEnd;
  Data.ObjEnd.Last := Data.ObjCollectibles;
  Data.ObjOther := TPMObjBreak.Create(Data.ObjCollectibles, 'Andere Objekte', ID_Break, 0, 0, 0, 0);
  Data.ObjEnemies := TPMObjBreak.Create(Data.ObjOther, 'Gegner', ID_Break, 0, 0, 0, 0);
  Data.ObjPlayers := TPMObjBreak.Create(Data.ObjEnemies, 'Spieler', ID_Break, 0, 0, 0, 0);
  Data.ObjEffects := TPMObjBreak.Create(Data.ObjPlayers, 'Effekte', ID_Break, 0, 0, 0, 0);
  Data.ExecuteScript := ES;

  // Quickstart?
  if ParamStr(1) <> '' then begin
    QuickStart := True;
    StartGame(ParamStr(1));
    if Data.OptMusic = 1 then begin
      MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\' + CurrentTheme + '.mid';
      MediaPlayer.Open;
      MediaPlayer.Play;
    end;
    Log.Add('Schnellstart von ' + ParamStr(1));
    Exit;
  end else Data.State := State_Welcome;

  // Wenn nicht, dann Levelinfoliste erstellen
  LevelList := TList.Create;
  // Levelliste laden
  if FindFirst(ExtractFileDir(ParamStr(0)) + '\*.pml', faAnyFile, SearchRec) = 0 then begin
    LevelList.Add(TPMLevelInfo.Create(ExtractFileDir(ParamStr(0)) + '\' + SearchRec.Name));
    while FindNext(SearchRec) = 0 do begin
      LevelList.Add(TPMLevelInfo.Create(ExtractFileDir(ParamStr(0)) + '\' + SearchRec.Name));
    end;
    FindClose(SearchRec);
  end;
  // Levelliste sortieren
  LevelList.Sort(LevelComp);

  // Musik starten
  if Data.OptMusic = 1 then begin
    MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\Menu.mid';
    MediaPlayer.Open;
    MediaPlayer.Play;
  end;

end;

procedure TFormPeterM.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Musik stoppen
  if Data.OptMusic = 1 then begin
    MediaPlayer.Stop;
    MediaPlayer.Close;
  end;
  // Objekte freigeben
  while Data.ObjCollectibles.Next <> Data.ObjEnd do Data.ObjCollectibles.Next.ReallyKill;
  Data.ObjCollectibles.Destroy; Data.ObjEnd.Destroy;
  // Karte freigeben
  Data.Map.Free;
  // Speicher der Levelliste freigeben (wenn Schnellstart)
  if not QuickStart then begin while LevelList.Count > 0 do
    begin TPMLevelInfo(LevelList.First).Free; LevelList.Delete(0); end;
  LevelList.Free; end;
  // Log schließen
  Log.Add('');
  Log.Add('Spiel beendet.');
  if Data.OptLog = 1 then Log.SaveToFile(ExtractFileDir(ParamStr(0)) + '\PeterM.log');
  Log.Free;
  // Willkommen zurück in WIN95!
  ShowCursor(True);
end;

procedure TFormPeterM.StartGame(LevelFile: string);
var
  Level_pml, Theme_def, PeterM_ini: TIniFile32;
  LoopX, LoopY, LoopT: Integer;
  Row, ObjString, NewTheme: string;
  OverLoadedTiles: TStringList; NewTiles: TBitmap;
begin
  // Reinitialisieren aller Variablen
  PlayerTopPos := 1024; LavaTopPos := 1024; MessageText := ''; MessageOpacity := 0;
  Data.Frame := -1; Data.FrameFadingBox := 16; Data.InvTimeLeft := 0; Data.SpeedTimeLeft := 0; Data.JumpTimeLeft := 0; Data.FlyTimeLeft := 0;
  Data.Keys := 0; Data.Stars := 0; Data.Ammo := 0; Data.Bombs := 0; Data.Score := 0;
  Data.Map.LavaFrame := 0; Data.Map.LavaTimeLeft := 0;
  for LoopX := 0 to 15 do Data.ObjVars[LoopX] := nil;

  // Alten Hiscore auslesen
  if ExtractFileDir(LevelFile) = ExtractFileDir(ParamStr(0)) then begin
    PeterM_ini := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
    OldHiscore := DeMuesli(PeterM_ini.ReadString('Hiscore', ExtractFileName(ExtractShortPathName(LevelFile)), 'Ungültig :('));
    PeterM_ini.Free;
  end else OldHiScore := High(Integer);

  // Karte löschen
  Data.Map.Clear;

  // Level öffnen
  Level_pml := TIniFile32.Create(LevelFile);
  // Nerfiger Täxt
  Log.Add('');
  Log.Add('Level "' + Level_pml.ReadString('Info', 'Title', '<Kein Titel>') + '" geladen.');
  // Version überprüfen
  if Level_pml.ReadString('Info', 'Version', '<Ungültige Version>') <> PMVersion then
    Log.Add('Warnung: Level ist nicht auf diese Version von Peter Morphose ausgelegt.');

  // Laden des passenden Themes                                                         
  NewTheme := Level_pml.ReadString('Info', 'Theme', 'Ritter');
  Log.Add('Thema des Levels: ' + NewTheme);
  DXImageListPack.Items.LoadFromFile(ExtractFileDir(ParamStr(0)) + '\' + Level_pml.ReadString('Info', 'Theme', 'Ritter') + '.pmt');
  DXWaveListPack.Items.LoadFromFile(ExtractFileDir(ParamStr(0)) + '\' + Level_pml.ReadString('Info', 'Theme', 'Ritter') + '.pms');

  // Wenn überladen, dann schonmal Kopie der alten speichern
  OverloadedTiles := TStringList.Create;
  Level_pml.ReadSection('Tiles', OverloadedTiles);
  if OverloadedTiles.Count > 0 then begin
    // Originaltiles speichern
    DXImageListPack.Items[Image_Tiles].Picture.SaveToFile(TempPath + '\PMTempOV.bmp');
    // Originaltiles in NewTiles laden
    NewTiles := TBitmap.Create;
    NewTiles.LoadFromFile(TempPath + '\PMTempOV.bmp');
    // Überladene Tiles einlesen
    for LoopT := 0 to 255 do begin
      Row := Level_pml.ReadString('Tiles', IntToHex(LoopT, 2), '');
      if Length(Row) = 3456 then begin
        Log.Add('Tile ' + IntToHex(LoopT, 2) + ' überladen.');
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
    // Newtiles und temporäre Datei löschen
    NewTiles.Free;
    DeleteFile(TempPath + '\PMTempOV.bmp');
  end;
  OverLoadedTiles.Free;

  // Karte einlesen
  for LoopY := 0 to 1023 do begin
    Row := Level_pml.ReadString('Map', IntToStr(LoopY), '000000000000000000000000000000000000000000000000');
    for LoopX := 0 to 23 do
      Data.Map.Tiles[LoopX, LoopY] := StrToIntDef('$' + Copy(Row, LoopX * 2 + 1, 2), 00);
    Data.Map.Scripts[LoopY] := Level_pml.ReadString('Scripts', IntToStr(LoopY), '');
  end;

  // Skripttimer laden
  for LoopX := 0 to 10 do
    Data.Map.ScriptTimers[LoopX] := Level_pml.ReadString('Scripts', 'Timer' + IntToStr(LoopX), '');

  // Andere Werte aus dem Level einlesen
  Data.StarsGoal     := Level_pml.ReadInteger('Map', 'StarsGoal', 100);
  Data.Map.Sky       := Level_pml.ReadInteger('Map', 'Sky', 0);
  Data.Map.LavaSpeed := Level_pml.ReadInteger('Map', 'LavaSpeed', 1);
  Data.Map.LavaMode  := Level_pml.ReadInteger('Map', 'LavaMode', 0);
  Data.Map.LavaPos   := Level_pml.ReadInteger('Map', 'LavaPos', 1024) * 24;
  Data.Map.LavaScore := Level_pml.ReadInteger('Map', 'LavaScore', 1);
  Data.Map.LevelTop  := Level_pml.ReadInteger('Map', 'LevelTop', 0) * 24;
  LevelBottom := Min(1024, Data.Map.LavaPos div 24);

  // Alle Objekte löschen
  while Data.ObjCollectibles.Next <> Data.ObjOther   do Data.ObjCollectibles.Next.ReallyKill;
  while Data.ObjOther.Next        <> Data.ObjEnemies do Data.ObjOther.Next.ReallyKill;
  while Data.ObjEnemies.Next      <> Data.ObjPlayers do Data.ObjEnemies.Next.ReallyKill;
  while Data.ObjPlayers.Next      <> Data.ObjEffects do Data.ObjPlayers.Next.ReallyKill;
  while Data.ObjEffects.Next      <> Data.ObjEnd     do Data.ObjEffects.Next.ReallyKill;

  // Definitionsdatei laden und Definitionen einlesen
  Theme_def := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\' + NewTheme + '.def');
  if CurrentTheme <> NewTheme then begin
    for LoopX := 0 to ID_Max do with Data.Defs[LoopX] do begin
      Name := Theme_def.ReadString('ObjName', IntToHex(LoopX, 2), '<Kein Name>');
      Life := Theme_def.ReadInteger('ObjLife', IntToHex(LoopX, 2), 3);
      Rect := Classes.Rect(-StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(LoopX, 2), '10102020'), 1, 2), 16),
                           -StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(LoopX, 2), '10102020'), 3, 2), 16),
                           +StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(LoopX, 2), '10102020'), 5, 2), 16),
                           +StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(LoopX, 2), '10102020'), 7, 2), 16));
      Speed := Theme_def.ReadInteger('ObjSpeed', IntToHex(LoopX, 2), 3);
      JumpX := Theme_def.ReadInteger('ObjJump', IntToHex(LoopX, 2) + 'X', 0);
      JumpY := Theme_def.ReadInteger('ObjJump', IntToHex(LoopX, 2) + 'Y', 0);
    end;
  end;      

  // Spieler einrichten
  with TPMLiving.Create(
                        Data.ObjPlayers,
                        '',
                        Level_pml.ReadInteger('Objects', 'PlayerID', ID_Player),
                        Level_pml.ReadInteger('Objects', 'PlayerX',   288),
                        Level_pml.ReadInteger('Objects', 'PlayerY', 24515),
                        Level_pml.ReadInteger('Objects', 'PlayerVX', 0),
                        Level_pml.ReadInteger('Objects', 'PlayerVY', 0),
                        Level_pml.ReadInteger('Objects', 'PlayerLife', Theme_def.ReadInteger('ObjLife', '00', 8)),
                        Act_Stand,
                        Level_pml.ReadInteger('Objects', 'PlayerDirection', Random(2))
                        )
  do Log.Add('Spieler als ' + Data.Defs[ID].Name + ' bei ' + IntToStr(PosX) + ', ' + IntToStr(PosY) + ' platziert.');
  Log.Add('Es ist ' + TimeToStr(Time) + '.');

  // Zeit setzen, wenn Spieler Spezialpeter ist
  if Data.ObjPlayers.Next.ID = ID_Player then Data.TimeLeft := 0 else Data.TimeLeft := Data.Defs[Data.ObjPlayers.Next.ID].Life;

  // Neue Objekte laden
  LoopX := -1;
  while True do begin
    Inc(LoopX);
    ObjString := Level_pml.ReadString('Objects', IntToStr(LoopX), '');
    if ObjString <> '' then
      CreateObject(Data,
                   Level_pml.ReadString('Objects', IntToStr(LoopX) + 'Y', ''),
                   StrToIntDef('$' + Copy(ObjString, 1, 2), 0),
                   StrToIntDef('$' + Copy(ObjString, 4, 3), 288),
                   StrToIntDef('$' + Copy(ObjString, 8, 4), 0),
                   StrToIntDef('$' + Copy(ObjString, 13, 5), 0),
                   StrToIntDef('$' + Copy(ObjString, 19, 5), 0)) else Break;
  end;

  // Thema und Level freigeben
  Theme_def.Free;
  CurrentTheme := NewTheme;
  Level_pml.Free;

  // Status setzen
  Data.State := State_Game;
end;

procedure TFormPeterM.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  OptionFile: TIniFile32;
begin
  // Escape: Beenden oder Status wechseln
  if Key = VK_Escape then begin
    if Data.State in [State_LevelSelection, State_Credits, State_ReadMe1..State_ReadMe8] then begin
      DXWaveList.Items[Sound_WooshBack].Play(False);
      Data.State := State_MainMenu;
      Exit;
    end;
    if Data.State in [State_Game, State_Paused, State_Dead] then begin
      if Data.State in [State_Game, State_Paused] then Log.Add('Level abgebrochen.');
      if QuickStart then Close else DXWaveList.Items[Sound_WooshBack].Play(False);
      Data.State := State_LevelSelection;
      Exit;
    end;
    if Data.State in [State_Options, State_Options2] then begin
      DXWaveList.Items[Sound_WooshBack].Play(False);
      Data.State := State_MainMenu;
      OptionFile := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
      OptionFile.WriteInteger('Options', 'Music', PseudoMusic);
      OptionFile.WriteInteger('Options', 'ShowStatus', Data.OptShowStatus);
      OptionFile.WriteInteger('Options', 'ShowTexts', Data.OptShowTexts);
      OptionFile.WriteInteger('Options', 'Effects', Data.OptEffects);
      OptionFile.WriteInteger('Options', 'Quality', Data.OptQuality);
      OptionFile.WriteInteger('Options', 'Blood', Data.OptBlood);
      OptionFile.WriteInteger('Options', 'OldJumping', Data.OptOldJumping);
      OptionFile.WriteInteger('Options', 'IHateFuchsia', Data.OptATI);
      OptionFile.Free;
      Exit;
    end;
  end;

  // Vollbild an/aus
  if (ssAlt in Shift) and (Key = VK_Return) then begin
    DXDraw.Finalize;
    if doFullScreen in DXDraw.Options then begin
      RestoreWindow;
      ShowCursor(True);
      BorderStyle := bsSingle;
      ClientWidth := 640;
      ClientHeight := 480;
      DXDraw.Options := DXDraw.Options - [doFullScreen];
    end else begin
      StoreWindow;
      ShowCursor(False);
      BorderStyle := bsNone;
      DXDraw.Options := DXDraw.Options + [doFullScreen];
    end;
    DXDraw.Initialize;
    Exit;
  end;

  // P: Pause an/aus
  if Key = Ord('P') then begin
    if Data.State = State_Paused then begin Data.State := State_Game; Exit; end else
      if Data.State = State_Game then begin Data.State := State_Paused; Exit; end;
  end;

  // Andere Knöpfe je nach Status auswerten
  case Data.State of
    State_Welcome: if not (ssAlt in Shift) then begin Data.State := State_MainMenu; DXWaveList.Items[Sound_Woosh].Play(False); end;
    State_MainMenu: case Key of
      VK_Up, VK_Left: if SelectedMenuItem > 0 then Dec(SelectedMenuItem);
      VK_Down, VK_Right: if SelectedMenuItem < 4 then Inc(SelectedMenuItem);
      VK_Return, VK_Space: if not (ssAlt in Shift) then case SelectedMenuItem of
                                                          0: begin Data.State := State_LevelSelection; DXWaveList.Items[Sound_Woosh].Play(False); end;
                                                          1: begin DXWaveList.Items[Sound_Woosh].Play(False); DXDraw.Surface.Fill(0); DrawBMPText('Hilfe wird geladen...', 225, 230, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality); DXDraw.Flip; DXImageListPack.Items.LoadFromFile(ExtractFileDir(ParamStr(0)) + '\Ritter.pmt'); Data.State := State_ReadMe1; end;
                                                          2: begin Data.State := State_Options; DXWaveList.Items[Sound_Woosh].Play(False); end;
                                                          3: begin Data.State := State_Credits; DXWaveList.Items[Sound_Woosh].Play(False); end;
                                                          4: begin DXWaveList.Items[Sound_WooshBack].Play(True); Close; end;
                                                        end;
                    end;
    State_Options: case Key of
      VK_Up: if SelectedOptionItem > 0 then Dec(SelectedOptionItem);
      VK_Down: if SelectedOptionItem < 4 then Inc(SelectedOptionItem);
      VK_Left: case SelectedOptionItem of
        0: PseudoMusic := 0;
        1: Data.OptBlood := 0;
        2: Data.OptShowStatus := 0;
        3: Data.OptATI := 0;
               end;
      VK_Right: case SelectedOptionItem of
        0: PseudoMusic := 1;
        1: Data.OptBlood := 1;
        2: Data.OptShowStatus := 1;
        3: Data.OptATI := 1;
        4: Data.State := State_Options2;
                end;
                   end;
    State_Options2: case Key of
      VK_Up: if SelectedOptionItem > 0 then Dec(SelectedOptionItem);
      VK_Down: if SelectedOptionItem < 4 then Inc(SelectedOptionItem);
      VK_Left: case SelectedOptionItem of
        0: if Data.OptQuality > 0 then Dec(Data.OptQuality);
        1: if Data.OptEffects > 4 then Dec(Data.OptEffects, 5);
        2: Data.OptOldJumping := 1;
        3: Data.OptShowTexts := 0;
        4: Data.State := State_Options;
               end;
      VK_Right: case SelectedOptionItem of
        0: if Data.OptQuality < 2 then Inc(Data.OptQuality);
        1: if Data.OptEffects < 246 then Inc(Data.OptEffects, 5);
        2: Data.OptOldJumping := 0;
        3: Data.OptShowTexts := 1;
                end;
                   end;
    State_ReadMe1..State_ReadMe8: case Key of
      VK_Up, VK_Left: if Data.State > State_ReadMe1 then Dec(Data.State);
      VK_Down, VK_Right: if Data.State < State_ReadMe8 then Inc(Data.State);
                                  end;
    State_LevelSelection: case Key of
      VK_Up, VK_Left: if SelectedLevel > 0 then begin
                        Dec(SelectedLevel);
                        if SelectedLevel < LevelListTop then Dec(LevelListTop);
                      end;
      VK_Down, VK_Right: if SelectedLevel < LevelList.Count - 1 then begin
                        Inc(SelectedLevel);
                        if SelectedLevel > LevelListTop + 3 then Inc(LevelListTop);
                      end;
      VK_Return, VK_Space: if not (ssAlt in Shift) then begin DXWaveList.Items[Sound_Woosh].Play(False); DXDraw.Surface.Fill(0); DrawBMPText('Level wird geladen...', 225, 230, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality); DXDraw.Flip; StartGame(TPMLevelInfo(LevelList.Items[SelectedLevel]).Location); end;
    end;
    State_Game: case Key of
      VK_Up:    if Data.FlyTimeLeft = 0 then TPMLiving(Data.ObjPlayers.Next).Jump;
      VK_Down:  if Data.FlyTimeLeft = 0 then TPMLiving(Data.ObjPlayers.Next).UseTile;
      VK_Space: TPMLiving(Data.ObjPlayers.Next).Special;
      VK_Delete, VK_Return: begin
                   if (Data.Frame = -1) or (Data.ObjPlayers.Next.ID = ID_Player) then Exit;
                   Data.ObjPlayers.Next.ID := ID_Player;
                   if TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead then TPMLiving(Data.ObjPlayers.Next).Action := Act_Jump;
                   CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
                   Exit;
                 end;
    end;
    State_Dead: if Key = VK_Return then
      begin if QuickStart then StartGame(ParamStr(1)) else StartGame(TPMLevelInfo(LevelList.Items[SelectedLevel]).Location); DXWaveList.Items[Sound_Woosh].Play(False); end;
    State_Won: if Key = VK_Return then begin
                 Data.State := State_WonInfo;
                 if Data.Score > OldHiscore then begin
                   OptionFile := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
                   if QuickStart then
                     OptionFile.WriteString('Hiscore', ExtractFileName(ExtractShortPathName(ParamStr(1))), Muesli(Data.Score))
                   else
                     OptionFile.WriteString('Hiscore', ExtractFileName(ExtractShortPathName(TPMLevelInfo(LevelList[SelectedLevel]).Location)), Muesli(Data.Score));
                   OptionFile.Free;
                   if not QuickStart then TPMLevelInfo(LevelList[SelectedLevel]).Hiscore := Data.Score;
                 end;
                 Log.Add('Level beendet.');
                 if QuickStart then Close else DXWaveList.Items[Sound_Woosh].Play(False);
               end;
    State_WonInfo: if not (ssAlt in Shift) then begin Data.State := State_LevelSelection; DXWaveList.Items[Sound_Woosh].Play(False); end;
  end;
end;
procedure TFormPeterM.DXTimerTimer(Sender: TObject; LagCount: Integer);
var
  LoopX, LoopY, YRow, YTop: Integer;
  TempObj: TPMObject;
begin
  // Musikverwaltung
  if Data.OptMusic = 1 then begin
    if (Data.State in [0..99, 200..255]) and (MediaPlayer.FileName <> ExtractFileDir(ParamStr(0)) + '\Menu.mid')
      then begin
        MediaPlayer.Stop;
        MediaPlayer.Close;
        MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\Menu.mid';
        MediaPlayer.Open;
        MediaPlayer.Play;
      end;
    if (Data.State in [100..199]) and (MediaPlayer.FileName <> ExtractFileDir(ParamStr(0)) + '\' + CurrentTheme + '.mid')
      then begin
        MediaPlayer.Stop;
        MediaPlayer.Close;
        MediaPlayer.FileName := ExtractFileDir(ParamStr(0)) + '\' + CurrentTheme + '.mid';
        MediaPlayer.Open;
        MediaPlayer.Play;
      end;
    if MediaPlayer.Position = MediaPlayer.Length then begin MediaPlayer.Rewind; MediaPlayer.Play; end; 
  end;
  // Rest
  case Data.State of
    State_Welcome: begin
      // Introbild malen
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_Title].Draw(DXDraw.Surface, 0, 0, 0);
      DrawBMPText('Version: 1.02.     http://www.petermorphose.de/', 109, 440, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DXDraw.Flip;
    end;
    State_MainMenu: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120,  20, 0 + Integer(SelectedMenuItem = 0));
      DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120,  90, 2 + Integer(SelectedMenuItem = 1));
      DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120, 160, 4 + Integer(SelectedMenuItem = 2));
      DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120, 230, 6 + Integer(SelectedMenuItem = 3));
      DXImageList.Items[Image_Buttons].Draw(DXDraw.Surface, 120, 300, 8 + Integer(SelectedMenuItem = 4));

      DrawBMPText('Wähle mit den Pfeiltasten aus, was du tun willst und drücke Enter.', 23, 435, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_Options: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Optionsmenü (Seite 1)', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Musik', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if PseudoMusic = 0 then DrawBMPText('<aus>', 575, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if PseudoMusic = 1 then DrawBMPText('<ein>', 575, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Schaltet die Musik ein oder aus. (Benötigt Peter-Neustart.)', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 0 then DXDraw.Surface.FillRectAdd(Bounds(0, 60, 640, 16), $004896);

      DrawBMPText('Blut und Schreie', 20, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptBlood = 0 then DrawBMPText('<aus>', 575, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                           else DrawBMPText('<ein>', 575, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Schaltet Blut an und aus. Viele finden, dass es nicht zum Spiel', 20, 140, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('passt. Aber manche können ja gar nicht ohne leben...', 20, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 1 then DXDraw.Surface.FillRectAdd(Bounds(0, 120, 640, 16), $004896);

      DrawBMPText('Positionsanzeige im Spiel', 20, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptShowStatus = 0 then DrawBMPText('<aus>', 575, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                                else DrawBMPText('<ein>', 575, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Blendet im Spiel links eine Leiste zur besseren Orientierung ein.', 20, 220, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 2 then DXDraw.Surface.FillRectAdd(Bounds(0, 200, 640, 16), $004896);

      DrawBMPText('Behebung des Rosa-Ränder-Problems', 20, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptATI = 0 then DrawBMPText('<aus>', 575, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                         else DrawBMPText('<ein>', 575, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Einschalten, wenn Grafiken in Hilfe oder Editor rosa Ränder haben.', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 3 then DXDraw.Surface.FillRectAdd(Bounds(0, 260, 640, 16), $004896);

      DrawBMPText('Seite 1      Seite 2', 230, 340, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 4 then DXDraw.Surface.FillRectAdd(Bounds(220, 340, 83, 16), $004896);

      DrawBMPText('Wähle mit den Pfeiltasten "oben" und "unten" aus, was du ändern willst', 3, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('und ändere den Wert mit "links" und "rechts". Zurück mit "Escape".', 12, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;

    State_Options2: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Optionsmenü (Seite 2)', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Grafikqualität', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptQuality = 0 then DrawBMPText('<schlecht>', 530, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptQuality = 1 then DrawBMPText('<standard>', 530, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptQuality = 2 then DrawBMPText('<sehr gut>', 530, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Ändert die Grafikqualität. Bei ''schlecht'' fehlen ein paar Effekte,', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('bei ''sehr gut'' kommen ein paar neue (übertriebene) hinzu.', 20, 100, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 0 then DXDraw.Surface.FillRectAdd(Bounds(0, 60, 640, 16), $004896);

      DrawBMPText('Effekte', 20, 140, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('<' + IntToStr(Data.OptEffects) + '%>', 620 - (Length(IntToStr(Data.OptEffects)) + 3) * 9, 140, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Gibt an, wieviel Prozent der Standardeffekte erzeugt werden.', 20, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 1 then DXDraw.Surface.FillRectAdd(Bounds(0, 140, 640, 16), $004896);

      DrawBMPText('Sprungsystem', 20, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptOldJumping = 1 then DrawBMPText('<alt>', 575, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                                else DrawBMPText('<neu>', 575, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Wer Probleme mit der alten Sprungsteuerung hat, kann versuchen, ob', 20, 220, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('er mit der neuen besser spielen kann.', 20, 240, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 2 then DXDraw.Surface.FillRectAdd(Bounds(0, 200, 640, 16), $004896);

      DrawBMPText('Texte', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if Data.OptShowTexts = 1 then DrawBMPText('<ein>', 575, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                               else DrawBMPText('<aus>', 575, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Schaltet Texte bei eingesammelten Objekten ein oder aus.', 20, 300, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 3 then DXDraw.Surface.FillRectAdd(Bounds(0, 280, 640, 16), $004896);

      DrawBMPText('Seite 1      Seite 2', 230, 340, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      if SelectedOptionItem = 4 then DXDraw.Surface.FillRectAdd(Bounds(337, 340, 83, 16), $004896);

      DrawBMPText('Wähle mit den Pfeiltasten "oben" und "unten" aus, was du ändern willst', 3, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('und ändere den Wert mit "links" und "rechts". Zurück mit "Escape".', 12, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;

    State_ReadMe1: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Willkommen bei Peter Morphose!', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Hier findest du die Erklärung des Spielprinzips, der Steuerung und', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('der Objekte und Kartenteile, die du im Spiel triffst. Die meisten', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Angaben beziehen sich auf das "Ritter"-Thema. Daher wird empfohlen,', 20, 100, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('zuerst Level mit diesem Thema zu spielen.', 20, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Die Steuerung: (Gamepad oder Tastatur)', 20, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Pfeiltasten links/rechts:   Laufen', 20, 220, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Pfeiltaste rauf/Button 1:   Springen', 20, 240, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Leertaste/Button 2:         Spezialaktion des aktuellen Peters', 20, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Pfeiltaste runter/Button 3: Treppen und Bodenplatten benutzen', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Enter/Entfernen/Button 4:   Wieder zum normalen Peter werden', 20, 300, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('P:                          Pause an/aus', 20, 320, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Escape:                     Wieder zum Hauptmenü', 20, 340, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('(Gamepad funktioniert nicht im Menü.)', 20, 360, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 1 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_ReadMe2: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Weitere Tipps zur Steuerung:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('• Nur der normale Peter kann Hebel umlegen (Spezialaktion). Wenn du', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('  ein Spezialpeter bist und einen Hebel umlegen willst, musst du', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('  dich erst zurückverwandeln (Enter/B4).', 20, 100, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('• Im Sprung kannst du die Flugrichtung ein wenig mit Links/Rechts', 20, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('  beeinflussen.', 20, 140, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('• Wenn du getroffen wirst, bist du für etwa eine Sekunde transparent', 20, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('  und unverwundbar. Nutze die Zeit, um aus dem Getümmel zu entkommen!.', 20, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Ziel des Spiels ist es, durch die jeweils letzte nach oben führende', 20, 220, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Treppe des Levels zu gehen. Wenn du genug Sterne hast, hast du das', 20, 240, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Level geschafft. In vielen Runden muss man unterwegs auch eine oder', 20, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('mehrere Geiseln retten (berühren), um gewinnen zu können. Das Ziel', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('einer Runde siehst du vor dem Spielen im Levelauswahlbildschirm.', 20, 300, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Was dich daran hindert, durch das Level zu kommen, ist vor allem', 20, 320, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('die Lava, die unerbittlich steigt und alles auf ihrem Wege toastet.', 20, 340, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Aber auch einige Gegner und Rätsel stehen dir im Weg...', 20, 360, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 2 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_ReadMe3: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Die 5 verschiedenen Peter:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num, Bounds(20, 50, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Das ist der normale Peter. Er ist wendig und kann Hebel', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('umlegen (Leertaste/B2).', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num * 2 + Act_Action3, Bounds(20, 100, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Ritterpeter ist stabiler und träger als Peter. Er kann dafür', 80, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('mit dem Schwert zuschlagen (Leertaste/B2).', 80, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num * 5, Bounds(20, 150, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Das ist Flitzebogenpeter. Er kann auf der Leertaste schießen,', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('verbraucht allerdings Munition.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num * 9, Bounds(20, 200, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Der Bombenlegerpeter kann Bomben werfen (Leertaste) und damit', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Gegner bekämpfen und Sprengstoffkisten explodieren lassen.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DXImageListPack.Items[Image_Effects].DrawAdd(DXDraw.Surface, Bounds(20, 250, 48, 48), 8, 192);
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num * 7, Bounds(20, 250, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Feuerpeter hat keine Spezialaktion. Er ist beinahe', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('unverwundbar und kann Gegner durch Berührung töten.', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MunitionBomber2 - 16, Bounds(10, 300, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MunitionGun2 - 16, Bounds(20, 310, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Pfeile sind Munition für den Flitzebogenpeter, Bomben für', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Bombenlegerpeter.', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 3 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_ReadMe4: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Die 5 verschiedenen Gegner:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], 0, Bounds(580, 50, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Kinderschrecks sind schwache, schnelle Gegner und meistens', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('keine große Gefahr.', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 3 + Act_Action4, Bounds(580, 100, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Tempelwächter sind zwar langsam, halten aber mehr Schläge aus', 20, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('als Kinderschrecks.', 20, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 8, Bounds(580, 150, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Diese schnellen Gegner explodieren bei Kontakt mit Peter und', 20, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('ziehen ihm so viel Energie ab. Gefährlich!', 20, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 4, Bounds(580, 200, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Bogenbayern lauern meistens an schwer erreichbaren Orten und', 20, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('schießen auf Peter, sobald sie ihn sehen.', 20, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DXImageListPack.Items[Image_Effects].DrawAdd(DXDraw.Surface, Bounds(580, 255, 48, 48), 7, 192);
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 7, Bounds(580, 250, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Diese brennende Unholden lassen sich am besten aus der Distanz', 20, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('besiegen. Kontakt meiden!', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 4 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_ReadMe5: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Die wichtigsten Objekte:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Carolin - 16, Bounds(20, 50, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Eine arme Gefangene. Muss durch Berührung gerettet werden.', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Stirbt sie, ist das Spiel sofort verloren!', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Key - 16, Bounds(20, 100, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Manche Türen kann man nur öffnen, wenn man noch einen', 80, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Schlüssel übrig hat.', 80, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Star - 16, Bounds(15, 140, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Star2 - 16, Bounds(20, 150, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Star3 - 16, Bounds(25, 160, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Diese Sterne müssen meistens in einer bestimmten Anzahl', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('eingesammelt werden, damit man die Runde schaffen kann.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Health - 16, Bounds(25, 195, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_EdibleFish2 - 16, Bounds(20, 210, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Kleine Beeren füllen eine Energie auf, große vier. Rote', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Fische füllen immer nur eine Energie auf.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MorphFighter - 16, Bounds(20, 250, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Morphobjekte verwandeln Peter in den abgebildeten', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Spezialpeter (hier: Ritterpeter).', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MoreTime - 16, Bounds(25, 295, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MoreTime2 - 16, Bounds(15, 310, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Große und kleine Uhren geben ein paar Sekunden mehr', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Spezialpeterzeit.', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 5 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_ReadMe6: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Weitere wichtige Objekte:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Lever - 16, Bounds(25, 40, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_LeverRight - 16, Bounds(25, 90, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Hebel und Schalter kann nur der normale Peter umlegen', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('(Leertaste). Sie verändern normalerweise etwas an der', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Spielwelt (Spezialteil erscheint, Mauer verschwindet,', 80, 100, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Hilfsobjekte werden erschaffen...', 80, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_SlowDown - 16, Bounds(25, 145, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Crystal - 16, Bounds(15, 165, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Sanduhren machen die Lava dauerhaft langsamer, Kristalle', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('frieren sie wenige Sekunden lang ein.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Fly - 16, Bounds(20, 200, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Mit diesen Flügeln kann Peter fliegen, bis sie vollständig', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('verblasst sind.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Jump - 16, Bounds(27, 242, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Speed - 16, Bounds(13, 258, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Siebenmeilenstiefel lassen Peter eine Weile schneller', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('laufen, Adlerstiefel höher springen.', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points6 - 16, Bounds(28, 318, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points - 16, Bounds(5, 290, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points5 - 16, Bounds(5, 315, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points2 - 16, Bounds(25, 290, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points4 - 16, Bounds(15, 300, 48, 48), Boolean(Data.OptATI));
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points3 - 16, Bounds(20, 310, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Diese Objekte machen nichts Anderes als Punkte zu geben.', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Nur einsammeln, wenn du zu viel Zeit hast!', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 6 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_ReadMe7: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Die wichtigsten Spezialkartenteile:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_RocketUpLeft2, Bounds(20, 55, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Katapultiert den Spieler bei Aktivierung (Pfeiltaste unten)', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('in Richtung des Pfeiles (hier: oben links).', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_MorphBomb, Bounds(20, 105, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Verwandelt den Spieler bei Aktivierung in den abgebildeten', 80, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Spezialpeter (hier: Bombenlegerpeter).', 80, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_ClosedDoor3, Bounds(20, 155, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Diese Türen lassen sich nur öffnen, wenn man einen Schlüssel', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('dabei hat.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Blocker, Bounds(20, 205, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Lassen sich mit Ritterpeter zerschlagen und mit Bombenleger-', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('peter zerbomben.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_BigBlocker, Bounds(20, 255, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Kann mit einer Bombe angezündet werden. Explodiert dann und', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('kann dabei auch weitere Kisten anzünden... Kettenreaktion!', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Bridge2, Bounds(20, 305, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Diese alten, verwitterten Steinmauern fangen an, zu zer-', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('bröseln, sobald ein Lebewesen draufläuft.', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 7 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_ReadMe8: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Mehr Spezialkartenteile:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_BigBlocker3, Bounds(20, 55, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Lässt sich auch zersprengen, explodiert aber nicht', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('selbst, im Gegensatz zu Sprengstoffkisten.', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Slime2, Bounds(20, 105, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Auf diesem klebrigen Schleim kann Peter nur sehr', 80, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('langsam laufen und nicht hoch springen.', 80, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_StairsUp, Bounds(20, 155, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Geht man in eine solche Tür, kommt man aus der nächsten', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Tür in Richtung des Pfeiles raus. Kann verschlossen sein.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_AirRocketUp2, Bounds(20, 205, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Läuft man an diesen Kartenteilen vorbei, schleudern sie', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('den Spieler in die angezeigte Richtung.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Spikes, Bounds(20, 255, 48, 48), Boolean(Data.OptATI));
      DrawBMPText('Diese Stacheln sind unangenehm für Gegner und Spieler.', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Manchmal auch an der Decke zu finden.', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('So, und jetzt noch viel Glück und Spaß beim Spielen von', 80, 335, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Peter Morphose!', 230, 360, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

      DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite 8 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Auf Escape kommst du zum Hauptmenü zurück.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_Credits: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

      DrawBMPText('Spielidee, Programmierung, Grafiken, Sounds', 100,  40, 192, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Julian Raschke, julian@raschke.de',           200,  80, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('http://www.petermorphose.de/',                200, 100, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Zusätzliche Sounds und Himmel',               100, 140, 192, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Sandro Mascia, xxsgrrs-@gmx.de',              200, 160, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Sebastian Ludwig, usludwig@t-online.de',      200, 180, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Sören Bevier, soeren.bevier@dtp-isw.de',      200, 200, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Sebastian Burkhart, buggi@buggi.com',         200, 220, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Florian Groß, flgr@gmx.de',                   200, 240, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Holger Biermann, kaiserbiddy@web.de',         200, 260, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Musik',                                       100, 300, 192, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
      DrawBMPText('Steffen Wenz, s.wenz@t-online.de',            200, 340, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);

      DrawBMPText('Willst du zurück zum Hauptmenü, drücke Escape.', 113, 435, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_LevelSelection: begin
      // Levelauswahl anzeigen
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);
      for LoopY := 0 to Min(4, LevelList.Count) - 1 do
        TPMLevelInfo(LevelList.Items[LoopY + LevelListTop]).Draw(LoopY * 100, LoopY + LevelListTop = SelectedLevel, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DXDraw.Surface.FillRect(Bounds(631, 0,  1, 400), DXDraw.Surface.ColorMatch($003010));
      DXDraw.Surface.FillRect(Bounds(632, 0, 16, 400), DXDraw.Surface.ColorMatch($004020));
      if LevelList.Count > 4 then DXImageList.Items[Image_Font].DrawAdd(DXDraw.Surface, Bounds(632, Round(384 * ((LevelListTop) / (LevelList.Count - 4))), 8, 16), 95, 128);
      DrawBMPText('Wähle mit den Pfeiltasten ein Level aus und starte es mit Enter.', 32, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DrawBMPText('Willst du zurück zum Hauptmenü, drücke Escape.', 113, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
      DXDraw.Flip;
    end;
    State_WonInfo: begin
      if not (DXDraw.CanDraw and Application.Active) then Exit;
      DXDraw.Surface.Fill(0);
      DXImageList.Items[Image_Won].Draw(DXDraw.Surface, 0, 0, 0);
      DrawBMPText('Übrige Lebensenergie (je Punkt 5 Punkte):              ' + IntToStr(TPMLiving(Data.ObjPlayers.Next).Life),             40, 150, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DrawBMPText('Übrige Schlüssel (je Schlüssel 25 Punkte):             ' + IntToStr(Data.Keys),                                        40, 180, 245, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DrawBMPText('Übrige Sterne (je Stern 3 Punkte):                     ' + IntToStr(Data.Stars - Data.StarsGoal),                      40, 210, 235, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DrawBMPText('Übrige Munition (je Schuss 2 Punkte):                  ' + IntToStr(Data.Ammo),                                        40, 240, 225, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DrawBMPText('Übrige Bomben (je Bombe 5 Punkte):                     ' + IntToStr(Data.Bombs),                                       40, 270, 215, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      if Data.Map.LavaScore = 1 then begin
        DrawBMPText('Übrige Lava-Einfrierzeit (pro Bild 1 Punkt):           ' + IntToStr(Data.Map.LavaTimeLeft) + ' Bilder',                40, 300, 205, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
        DrawBMPText('Abstand zur Lava bei Spielende (pro Pixel 0.1 Punkte): ' + IntToStr(Data.Map.LavaPos - Data.Map.LevelTop) + ' Pixel',  40, 330, 195, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      end;
      DrawBMPText('Gesamtpunktestand:                                    ' + IntToStr(Data.Score) + ' Punkte!',                          40, 380, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DrawBMPText('(Taste drücken)', 252, 440, 128, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DXDraw.Flip;
    end;
    State_Paused, State_Game, State_Dead, State_Won: begin
      // Wäre State_Dead nicht doch passender?
      if (Data.State = State_Game) and ((Data.ObjPlayers.Next = Data.ObjEffects) or (TPMLiving(Data.ObjPlayers.Next).Action = Act_Dead)) then
        begin Data.State := State_Dead; Log.Add('Spieler gestorben.'); end;
      // Gewonnen?
      if (Data.State = State_Game) and (Data.ObjPlayers.Next.PosY < Data.Map.LevelTop) then
        if (Data.Stars >= Data.StarsGoal) and (FindObject(Data.ObjCollectibles, Data.ObjOther, ID_Carolin, ID_Carolin, Bounds(0, 0, 576, 24576)) = nil) then begin
          Data.State := State_Won; Log.Add('Gewonnen!');
          Log.Add('Es ist ' + TimeToStr(Time) + '.');
          Log.Add('Übrige Lebensenergie (je Punkt 5 Punkte):              ' + IntToStr(TPMLiving(Data.ObjPlayers.Next).Life));
          Inc(Data.Score, TPMLiving(Data.ObjPlayers.Next).Life * 5);
          Log.Add('Übrige Schlüssel (je Schlüssel 25 Punkte):             ' + IntToStr(Data.Keys));
          Inc(Data.Score, Data.Keys * 25);
          Log.Add('Übrige Sterne (je Sterne 3 Punkte):                    ' + IntToStr(Data.Stars - Data.StarsGoal));
          Inc(Data.Score, (Data.Stars - Data.StarsGoal) * 3);
          Log.Add('Übrige Munition (je Schuss 2 Punkte):                  ' + IntToStr(Data.Ammo));
          Inc(Data.Score, Data.Ammo * 2);
          Log.Add('Übrige Bomben (je Bombe 5 Punkte):                     ' + IntToStr(Data.Bombs));
          Inc(Data.Score, Data.Bombs * 5);
          if Data.Map.LavaScore = 1 then begin
            Log.Add('Übrige Lava-Einfrierzeit (pro Bild 1 Punkt):           ' + IntToStr(Data.Map.LavaTimeLeft) + ' Bilder');
            Inc(Data.Score, Data.Map.LavaTimeLeft);
            Log.Add('Abstand zur Lava bei Spielende (pro Pixel 0.1 Punkte): ' + IntToStr(Data.Map.LavaPos - Data.Map.LevelTop) + ' Pixel');
            Inc(Data.Score, (Data.Map.LavaPos - Data.Map.LevelTop) div 10);
          end;
          Log.Add('Gesamtpunktestand:                                     ' + IntToStr(Data.Score) + ' Punkte!');
        end else begin
          Data.State := State_Dead; Log.Add('Zu wenig Sterne oder Geiseln übrig - verloren.');
        end;
      // Normaler Verlauf
      if Data.State = State_Game then begin
        // Bildzähler erhöhen
        Inc(Data.Frame);
        if Data.Frame = 2400 then Data.Frame := 0;
        if MessageOpacity > 0 then Dec(MessageOpacity, 3);

        // Jetzt schon das Skript ausführen (damit Zeile 0 berücksichtigt wird)
        if Data.Map.LavaPos div 24 < LavaTopPos then begin // Höchstwert überschritten
          LavaTopPos := Data.Map.LavaPos div 24;
          ExecuteScript(Data.Map.Scripts[LavaTopPos], 'lava');
        end;
        // Außerdem Spielerskript ausführen
        if Data.ObjPlayers.Next.PosY div 24 < PlayerTopPos then begin // Höchstwert überschritten
          PlayerTopPos := Data.ObjPlayers.Next.PosY div 24;
          ExecuteScript(Data.Map.Scripts[PlayerTopPos], 'player');
        end;
        // Und nu die Timerz
        ExecuteScript(Data.Map.ScriptTimers[Data.Frame mod 10], 'do');
        ExecuteScript(Data.Map.ScriptTimers[10], 'do');

        // Lava steigen lassen
        if (Data.Map.LavaTimeLeft = 0) then begin if (Data.Map.LavaSpeed <> 0) then begin
          if (Data.Map.LavaMode = 0) and ((Data.Frame mod Data.Map.LavaSpeed) = 0) then Dec(Data.Map.LavaPos);
          if (Data.Map.LavaMode = 1) then Dec(Data.Map.LavaPos, Data.Map.LavaSpeed);
          Inc(Data.Map.LavaFrame);
          if Data.Map.LavaFrame = 120 then Data.Map.LavaFrame := 0;
          if (Data.Frame mod 10 = 0) and (Random(10) = 0) then DistSound(Data.Map.LavaPos, Sound_Lava, Data);
        end; end else Dec(Data.Map.LavaTimeLeft);
        // Spezialpeterzeit ablaufen lassen
        if Data.ObjPlayers.Next.ID > ID_Player then begin
          Dec(Data.TimeLeft);
          if Data.TimeLeft = 0 then begin
            Data.ObjPlayers.Next.ID := ID_Player;
            CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
          end;
        end;
        if Data.InvTimeLeft > 0 then Dec(Data.InvTimeLeft);
        // Bestimmen, welcher Teil des Levels angezeigt wird
        Data.ViewPos := Max(Min(Min(Data.Map.LavaPos - 432, Data.ObjPlayers.Next.PosY - 240), 24096), Data.Map.LevelTop);
      end;
      if Data.State = State_Game then begin
        // Spielersteuerung
        DXInput.Update;
        // Steuerung für normalen Peter
        if (Data.FlyTimeLeft = 0) and (not Data.ObjPlayers.Next.InWater) then begin
          // Nach links bewegen
          if isLeft in DXInput.States then with TPMLiving(Data.ObjPlayers.Next) do begin
            if (not Busy) and (VelX > -Round(Data.Defs[ID].Speed * 1.75)) then Dec(VelX, Data.Defs[ID].Speed + Integer(Data.SpeedTimeLeft > 0) * 6);
            if Data.OptOldJumping = 1 then begin
              if (Action = Act_Jump) or (Action = Act_Land)
              or (Action = Act_Pain1) or (Action = Act_Pain2) then begin
                if not Blocked(Dir_Left) then Dec(PosX);
                if not Blocked(Dir_Left) then Dec(PosX);
                if not Blocked(Dir_Left) and (Action = Act_Land) then Dec(PosX);
                if not Blocked(Dir_Left) and (Action = Act_Land) then Dec(PosX);
              end;
            end else begin
              if (Action in [Act_Jump, Act_Pain1, Act_Pain2]) and (VelX > -Data.Defs[ID].JumpX - 2) then Dec(VelX);
              if (Action = Act_Land) and (VelX > -Data.Defs[ID].JumpX - 3) then Dec(VelX);
            end;
          end else
            if (Data.OptOldJumping = 0) and (Data.Frame mod 3 = 0) and (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Jump, Act_Land]) and (Data.ObjPlayers.Next.VelX < -1) then Inc(Data.ObjPlayers.Next.VelX);
          // Nach rechts bewegen
          if isRight in DXInput.States then with TPMLiving(Data.ObjPlayers.Next) do begin
            if (not Busy) and (VelX < +Round(Data.Defs[ID].Speed * 1.75)) then Inc(VelX, Data.Defs[ID].Speed + Integer(Data.SpeedTimeLeft > 0) * 6);
            if Data.OptOldJumping = 1 then begin
              if (Action = Act_Jump) or (Action = Act_Land)
              or (Action = Act_Pain1) or (Action = Act_Pain2) then begin
                if not Blocked(Dir_Right) then Inc(PosX);
                if not Blocked(Dir_Right) then Inc(PosX);
                if not Blocked(Dir_Right) and (Action = Act_Land) then Inc(PosX);
                if not Blocked(Dir_Right) and (Action = Act_Land) then Inc(PosX);
              end;
            end else begin
              if (Action in [Act_Jump, Act_Pain1, Act_Pain2]) and (VelX < +Data.Defs[ID].JumpX + 2) then Inc(VelX);
              if (Action = Act_Land) and (VelX < +Data.Defs[ID].JumpX + 3) then Inc(VelX);
            end;
          end else
            if (Data.OptOldJumping = 0) and (Data.Frame mod 3 = 0) and (TPMLiving(Data.ObjPlayers.Next).Action in [Act_Jump, Act_Land]) and (Data.ObjPlayers.Next.VelX > 1) then Dec(Data.ObjPlayers.Next.VelX);
        end else with TPMLiving(Data.ObjPlayers.Next) do begin
          if (isUp in DXInput.States)    and (VelY > -5) then Dec(VelY);
          if (isUp in DXInput.States)    and (VelY > -5) then Dec(VelY);
          if (isDown in DXInput.States)  and (VelY < +5) then Inc(VelY);
          if (isDown in DXInput.States)  and (VelY < +5) then Inc(VelY);
          if (isLeft in DXInput.States)  and (VelX > -4) then Dec(VelX);
          if (isRight in DXInput.States) and (VelX < +4) then Inc(VelX);
          if (isLeft in DXInput.States)  and (VelX > -4) then Dec(VelX);
          if (isRight in DXInput.States) and (VelX < +4) then Inc(VelX);
          if not InWater then begin
            if VelY < 0 then Inc(VelY); if VelY > 0 then Dec(VelY);
            if VelX < 0 then Inc(VelX); if VelX > 0 then Dec(VelX);
          end;
          if InWater and (VelX + VelY > 1) and (Data.Frame mod 3 = 0) and (Random(5) = 0) then Data.Waves[Sound_Water + Random(2)].Play(False);
          if VelX < 0 then Direction := Dir_Left;
          if VelX > 0 then Direction := Dir_Right;
        end;
        if Data.SpeedTimeLeft > 0 then begin
          Dec(Data.SpeedTimeLeft);
          CastObjects(ID_FXSpark, Random(2), 0, 0, 1, Data.OptEffects, Data.ObjPlayers.Next.GetRect(1, 1), Data.ObjEffects);
        end;
        if Data.JumpTimeLeft > 0 then Dec(Data.JumpTimeLeft);
        if Data.FlyTimeLeft > 0 then Dec(Data.FlyTimeLeft);
        if DXInput.Keyboard.Keys[VK_Up] or DXInput.Joystick.Buttons[0] and (Data.FlyTimeLeft = 0) then TPMLiving(Data.ObjPlayers.Next).Jump;
        if DXInput.Keyboard.Keys[VK_Down] or DXInput.Joystick.Buttons[2] and (Data.FlyTimeLeft = 0) then TPMLiving(Data.ObjPlayers.Next).UseTile;
        if DXInput.Keyboard.Keys[VK_Space] or DXInput.Joystick.Buttons[1] then TPMLiving(Data.ObjPlayers.Next).Special;
        if DXInput.Joystick.Buttons[3] then begin
          if (Data.Frame = -1) or (Data.ObjPlayers.Next.ID = ID_Player) then Exit;
          Data.ObjPlayers.Next.ID := ID_Player;
          if TPMLiving(Data.ObjPlayers.Next).Action < Act_Dead then TPMLiving(Data.ObjPlayers.Next).Action := Act_Jump;
          CastFX(8, 0, 0, Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY, 24, 24, 0, -1, 4, Data.OptEffects, Data.ObjEffects);
          Exit;
        end;

        // Objekte berechnen
        TempObj := Data.ObjCollectibles.Next;
        while TempObj <> Data.ObjEnd do begin
          TempObj.Update;
          TempObj := TempObj.Next;
        end;
        // Jetzt noch die kaputten löschen
        TempObj := Data.ObjCollectibles.Next;
        while TempObj <> nil do begin
          if TempObj.Last.Marked then TempObj.Last.ReallyKill;
          TempObj := TempObj.Next;
        end;
        // Ab und zu mal ein Rauchwölkchen und Flammen aus der Lava steigen lassen...
        if Data.Map.LavaTimeLeft = 0 then begin
          CastFX(Random(2) + 1, Random(2) + 1, 0, 288, Data.Map.LavaPos, 576, 8, 1, -4, 1, Data.OptEffects, Data.ObjEffects);
          if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
          if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
          if (Data.OptEffects > 0) and (Random(250 - Data.OptEffects) div 10 = 0) then TPMEffect.Create(Data.ObjEffects, '', ID_FXBubble, Random(576), Data.Map.LavaPos - 12, 1 - Random(3), 0);
        end;
      end;

      // Alles zeichnen
      if not (DXDraw.CanDraw and Application.Active) then Exit;
                                                                                     
      // Erstmal den Hintergrund
      case Data.Map.Sky of
        0: for LoopY := 0 to 3 do
             for LoopX := 0 to 3 do
               DXImageListPack.Items[Image_Sky].Draw(DXDraw.Surface, LoopX * 144, LoopY * 120, Data.Map.Sky);
        else
          for LoopY := 0 to 4 do
            for LoopX := 0 to 3 do
              DXImageListPack.Items[Image_Sky].Draw(DXDraw.Surface, LoopX * 144, LoopY * 120 - Data.ViewPos mod 120, Data.Map.Sky);
      end;
      // Danach die Karte
      YTop := Data.ViewPos mod 24; YRow := Data.ViewPos div 24;
      for LoopY := 0 to 20 do for LoopX := 0 to 23 do
        if Data.Map.Tiles[LoopX, YRow + LoopY] <> 0 then DXImageListPack.Items[Image_Tiles].Draw(DXDraw.Surface, LoopX * 24, LoopY * 24 - YTop, Data.Map.Tiles[LoopX, YRow + LoopY]);

      // Objekte zeichnen
      TempObj := Data.ObjCollectibles.Next;
      while TempObj <> Data.ObjEnd do begin
        TempObj.Draw;
        TempObj := TempObj.Next;
      end;

      // Zum Schluss die böhze Gefahr, die von unten aufsteigt
      for LoopX := -1 to 4 do
        DXImageListPack.Items[Image_Danger].Draw(DXDraw.Surface, LoopX * 120 + Data.Map.LavaFrame, Data.Map.LavaPos - Data.ViewPos + Integer(Data.Map.LavaTimeLeft = 0) * ((Data.Frame div 2) mod 2), Min(1, Data.Map.LavaTimeLeft));
      if Data.Map.LavaPos < Data.Map.LevelTop + 432 then
        for LoopX := -1 to 4 do
          for LoopY := 0 to (Data.Map.LevelTop + 432 - Data.Map.LavaPos) div 48 + 1 do
        DXImageListPack.Items[Image_Danger].Draw(DXDraw.Surface, LoopX * 120 + Data.Map.LavaFrame, Data.Map.LavaPos - Data.ViewPos + 48 + LoopY * 48 + Integer(Data.Map.LavaTimeLeft = 0) * ((Data.Frame div 2) mod 2), Min(1, Data.Map.LavaTimeLeft) + 2);

      // Dann noch die Leiste drüber
      // Das göttliche P
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 0, 0);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 0, 1);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 0, 2);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 0, 3);
      // Leerzeile
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 48, 4);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 48, 5);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 48, 6);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 48, 7);
      // Energie
      if Data.ObjPlayers.Next <> Data.ObjEffects then begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 96, 8);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 96, 9);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 96, Min(TPMLiving(Data.ObjPlayers.Next).Life, 99) div 10 * 2 + 20);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 96, Min(TPMLiving(Data.ObjPlayers.Next).Life, 99) mod 10 * 2 + 21);
      end else begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 96, 8);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 96, 9);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 96, 20);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 96, 21);
      end;
      // Schlüssel
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 144, 10);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 144, 11);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 144, Min(Data.Keys, 99) div 10 * 2 + 20);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 144, Min(Data.Keys, 99) mod 10 * 2 + 21);
      // Sterne
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 192, 12);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 192, 13);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 192, Min(Data.Stars, 99) div 10 * 2 + 20);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 192, Min(Data.Stars, 99) mod 10 * 2 + 21);
      // Wenn genug, dann Häkchen
      if Data.Stars >= Data.StarsGoal then begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 192, 42);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 192, 43);
      end;
      // Wenn gar keine benötigt, dann nix
      if Data.StarsGoal = 0 then begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 192, 4);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 192, 5);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 192, 6);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 192, 7);
      end;
      // Übrige Spezialpeterzeit
      if Data.ObjPlayers.Next.ID < 1 then begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 240, 4);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 240, 5);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 240, 6);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 240, 7);
      end else begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 240, 14);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 240, 15);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 240, (Data.TimeLeft div 20) div 10 * 2 + 20);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 240, Data.TimeLeft div 20 mod 10 * 2 + 21);
      end;
      // Munition
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 288, 16);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 288, 17);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 288, Min(Data.Ammo, 99) div 10 * 2 + 20);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 288, Min(Data.Ammo, 99) mod 10 * 2 + 21);
      // Bomben
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 336, 18);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 336, 19);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 336, Min(Data.Bombs, 99) div 10 * 2 + 20);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 336, Min(Data.Bombs, 99) mod 10 * 2 + 21);
      // Übrige Lavafrierzeit
      if Data.Map.LavaTimeLeft = 0 then begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 384, 4);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 384, 5);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 384, 6);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 384, 7);
      end else begin
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 384, 40);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 384, 41);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 384, Min(Data.Map.LavaTimeLeft div 20, 99) div 10 * 2 + 20);
        DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 384, Min(Data.Map.LavaTimeLeft div 20, 99) mod 10 * 2 + 21);
      end;

      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 576, 432, 4);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 592, 432, 5);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 608, 432, 6);
      DXImageListPack.Items[Image_GUI].Draw(DXDraw.Surface, 624, 432, 7);

      // Levelfortschrittsanzeige (wenn aktiviert)
      if Data.OptShowStatus = 1 then begin
        DXDraw.Surface.FillRectAlpha(Bounds(2, 38, 8, 404), clGray, 64);
        if Data.ObjPlayers.Next.ID > -1 then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.ObjPlayers.Next.PosY / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clNavy, 192);
        if (Data.Map.LavaPos <= 24576) and (Data.Map.LavaTimeLeft = 0) then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.Map.LavaPos / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clYellow, 128);
        if (Data.Map.LavaPos <= 24576) and (Data.Map.LavaTimeLeft > 0) then DXDraw.Surface.FillRectAlpha(Bounds(0, 38 + Round(((Data.Map.LavaPos / 24 - Data.Map.LevelTop / 24) / (LevelBottom - Data.Map.LevelTop / 24)) * 400), 12, 4), clAqua, 128);
      end;

      // Scriptmessages
      if (Data.State in [State_Game, State_Paused]) and (MessageOpacity > 0) then
        DrawBMPText(MessageText, (640 - Length(MessageText) * 9) div 2, 230, MessageOpacity, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);

      // Game-Over-Schild 
      if (Data.State = State_Dead) or (Data.State = State_Won) then begin
        Inc(Data.FrameFadingBox);
        if Data.FrameFadingBox = 33 then Data.FrameFadingBox := 1;
        DXImageList.Items[Image_GameDialogs].DrawAdd(DXDraw.Surface, Bounds(200, 160, 240, 120), Data.State - State_Dead, Abs(16 - Data.FrameFadingBox) * 16);
        if Data.State = State_Won then begin
          if Data.Score > OldHiscore then
            DrawBMPText('Punkte: ' + IntToStr(Data.Score) + ' (neuer Hiscore)', 320 - Round((Length(IntToStr(Data.Score)) + 24) * 4.5), 220, 255 - Min(Abs(16 - Data.FrameFadingBox) * 16, 255), DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality)
          else
            DrawBMPText('Punkte: ' + IntToStr(Data.Score), 320 - Round((Length(IntToStr(Data.Score)) + 8) * 4.5), 220, 255 - Min(Abs(16 - Data.FrameFadingBox) * 16, 255), DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
        end;
      end;

      // Pause-Schriftzug
      if Data.State = State_Paused then begin
        DXImageList.Items[Image_GameDialogs].DrawAdd(DXDraw.Surface, Bounds(200, 120, 240, 120), 2, 255);
      end;

      // Und noch die Punkte
      DrawBMPText('Punkte: ' + IntToStr(Data.Score), 320 - Round((Length(IntToStr(Data.Score)) + 8) * 4.5), 25, 160, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);
      DXDraw.Flip;
    end;                            
  end;
end;

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
  // Gibt den Wert einer vierstelligen GameVar zurück
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
    if not L in [4, 5] then begin Log.Add('Fehler: Ungültige Parameter in ' + ParamList); Exit; end;
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
  // Befehl ausführen
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

    // Bedingung ist wahr: Befehl ausführen

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

    // kill - Objektvariable löschen
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

    // setxd - ExtraData eines Objekts ändern
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
             ParamToInt(Command, ParserPos + 43, 4), // Höhe
             ParamToInt(Command, ParserPos + 48, 5), // XDir
             ParamToInt(Command, ParserPos + 54, 5), // YDir
             ParamToInt(Command, ParserPos + 60, 4), // Rnd
             Data.OptEffects, Data.ObjEffects);
      Exit;
    end;

    // changetile - Kartenteil verändern
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

procedure ES(Script, Caller: string);
begin
  FormPeterM.ExecuteScript(Script, Caller);
end;

function LevelComp(Item1, Item2: Pointer): Integer;
begin
  if TPMLevelInfo(Item1).Title = TPMLevelInfo(Item2).Title then begin Result := 0; Exit; end;
  if TPMLevelInfo(Item1).Title = 'Gemütlicher Aufstieg' then begin Result := -1; Exit; end;
  if TPMLevelInfo(Item2).Title = 'Gemütlicher Aufstieg' then begin Result := +1; Exit; end;
  Result := CompareText(TPMLevelInfo(Item1).Title, TPMLevelInfo(Item2).Title);
end;

function Muesli(Int: Integer): string;
var
  I: Integer;
begin
  for I := 1 to Length(IntToStr(Int)) do
    Result := Result + Char(Integer(IntToStr(Int)[I]) * 2 + 48 + I * 2 - (I mod 2) * 5);
end;

function DeMuesli(Str: string): Integer;
var
  I: Integer;
  TempStr: string;
begin
  for I := 1 to Length(Str) do
    TempStr := TempStr + Char((Integer(Str[I]) + (I mod 2) * 5 - I * 2 - 48) div 2);
  Result := StrToIntDef(TempStr, -1);
end;

end.
