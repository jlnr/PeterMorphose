/////////////////////////////////////////////////////
// PeterME - von Julian Raschke, julian@raschke.de //
/////////////////////////////////////////////////////

unit UnitPME;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, DXDraws, Menus, DXClass, IniFiles32, Graphics, Spin,
  ExtCtrls, ComCtrls, PMConst, PMObjects, PMMaps, ExtDlgs, FileType;

// Konstanten, die der PeterME benötigt
const
  Image_Font = 0;
  Image_Bar = 1;
  Image_Danger = 2;

// Typendeklarationen
type
  TFormPeterME = class(TForm)
    DXDraw: TDXDraw;
    DXImageList: TDXImageList;
    DXImageListPack: TDXImageList;
    ScrollBarTiles: TScrollBar;
    MainMenu: TMainMenu;
    MnuDatei: TMenuItem;
    MnuNeu: TMenuItem;
    MnuLaden: TMenuItem;
    MnuSpeichern: TMenuItem;
    MnuBreak: TMenuItem;
    MnuBeenden: TMenuItem;
    MnuAnderes: TMenuItem;
    MnuAktualisieren: TMenuItem;
    MnuBoxen: TMenuItem;
    MnuObjektlisteSpeichern: TMenuItem;
    SDlgLevel: TSaveDialog;
    ODlgLevel: TOpenDialog;
    StatusBar: TStatusBar;
    PnlMapOptions: TPanel;
    PnlMoreOpts: TPanel;
    PnlObjOpts: TPanel;
    PnlProperties: TPanel;
    ScrollBar: TScrollBar;
    SdtLavaPos: TSpinEdit;
    SdtXPos: TSpinEdit;
    SdtLavaSpeed: TSpinEdit;
    SdtPiecesGoal: TSpinEdit;
    RadioMapTiles: TRadioButton;
    RadioObjects: TRadioButton;
    CbxSkies: TComboBox;
    EdtMapName: TEdit;
    EdtMapSkill: TEdit;
    EdtMapDesc: TEdit;
    BtnMoreOpts: TButton;
    RadLavaMode0: TRadioButton;
    RadLavaMode1: TRadioButton;
    LblLavaSpeed: TLabel;
    LblLavaPos: TLabel;
    LblXPos: TLabel;
    LblMapSkies: TLabel;
    LblPiecesGoal: TLabel;
    LblYPos: TLabel;
    SdtYPos: TSpinEdit;
    LblXVel: TLabel;
    SdtXVel: TSpinEdit;
    LblYVel: TLabel;
    SdtYVel: TSpinEdit;
    PnlLivingXData: TPanel;
    CbxJumps: TCheckBox;
    CbxUseSpecial: TCheckBox;
    PnlPowerUpXData: TPanel;
    CbxFalls: TCheckBox;
    MnuSpielen: TMenuItem;
    PnlLeverXData: TPanel;
    CmbLeverTargets: TComboBox;
    SdtLeverTargetNum: TSpinEdit;
    LblLeverTargetNum: TLabel;
    BtnLeverTarget: TButton;
    BtnTargetTile: TButton;
    MnuInfo: TMenuItem;
    BtnLeverScript: TButton;
    MnuTimer: TMenuItem;
    MnuTimer9: TMenuItem;
    MnuTimer8: TMenuItem;
    MnuTimer7: TMenuItem;
    MnuTimer6: TMenuItem;
    MnuTimer5: TMenuItem;
    MnuTimer4: TMenuItem;
    MnuTimer3: TMenuItem;
    MnuTimer2: TMenuItem;
    MnuTimer1: TMenuItem;
    MnuTimer0: TMenuItem;
    LblLevelTop: TLabel;
    SdtLevelTop: TSpinEdit;
    PictureDialog: TOpenPictureDialog;
    SavPicDlg: TSavePictureDialog;
    EditHostName: TEdit;
    LabelHostName: TLabel;
    MnuSpeichern2: TMenuItem;
    MnuBreak2: TMenuItem;
    MnuBreak3: TMenuItem;
    MnuAuthor: TMenuItem;
    MnuLavaScore: TMenuItem;
    MnuTheme: TMenuItem;
    ODlgTheme: TOpenDialog;
    MnuTimerX: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure DXDrawMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RadioClick(Sender: TObject);
    procedure MnuNeuClick(Sender: TObject);
    procedure MnuLadenClick(Sender: TObject);
    procedure MnuSpeichernClick(Sender: TObject);
    procedure MnuAktualisierenClick(Sender: TObject);
    procedure DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CbxSkiesChange(Sender: TObject);
    procedure SdtPiecesGoalChange(Sender: TObject);
    procedure MnuBoxenClick(Sender: TObject);
    procedure MnuObjektlisteSpeichernClick(Sender: TObject);
    procedure BtnMoreOptsClick(Sender: TObject);
    procedure SdtLavaPosChange(Sender: TObject);
    procedure Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure UpdateOptObj(Sender: TObject);
    procedure MnuBeendenClick(Sender: TObject);
    procedure MnuSpielenClick(Sender: TObject);
    procedure SdtLeverTargetNumChange(Sender: TObject);
    procedure BtnLeverTargetClick(Sender: TObject);
    procedure BtnTargetTileClick(Sender: TObject);
    procedure MnuInfoClick(Sender: TObject);
    procedure BtnLeverScriptClick(Sender: TObject);
    procedure SetTimer(Sender: TObject);
    procedure SdtLevelTopChange(Sender: TObject);
    procedure DXDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure EditHostNameChange(Sender: TObject);
    procedure MnuSpeichern2Click(Sender: TObject);
    procedure MnuAuthorClick(Sender: TObject);
    procedure MnuLavaScoreClick(Sender: TObject);
    procedure MnuThemeClick(Sender: TObject);
    procedure CmbLeverTargetsClick(Sender: TObject);
  private
    Changed: Boolean;
  public
    // Ausgewählte(s/r) Teil / Objekt / Person
    SelectedTile, SelectedObject: Integer;
    // Objekt, von dem die Eigenschaften geändert werden
    OptObj: TPMObject;
    // Wird gerade ein Ziel gesucht?
    SelectingTarget, SelectingTile, EditingTiles, WasJustEditingTiles: Boolean;
    TileOverload: array[0..255] of string;
    TempPath: string;
    // Alle Daten (fast)
    Data: TPMData;
    // Erweiterte Leveleinstellungen
    MapTheme, MapAuthor: string;
    // Prozedur zum Setzen von Changed
    procedure SetChanged(Value: Boolean);
    // Hat sich das Level seit letztem Speichern geändert?
    property HasChanged: Boolean read Changed write SetChanged;
    // Objekteigenschaften anzeigen von Objekt
    procedure ShowObjOpts(PMObject: TPMObject);
    // Prozedur, die das Hauptfenster des Editors neu zeichnet
    procedure UpdateDXDraw;
    procedure LoadLevel(FileName: string);
    // Timermenüs aktualisieren
    procedure RefreshTimerMenus;
    // Funktion, die das erste Objekt an angegebener Stelle zurückgibt
    function GetObject(X, Y: Integer): TPMObject;
    // string mit angegebenem Zeichen auffüllen
    function FillWithChar(OldString: string; NewLength: Integer; FillChar: Char): string;
  end;

var
  FormPeterME: TFormPeterME;

implementation

{$R *.DFM}

// Initialisierung
procedure TFormPeterME.FormCreate(Sender: TObject);
var
  PeterM_ini: TIniFile32; PC: PChar;
begin
  // Temppfad setzen und so
  GetMem(PC, 129);
  GetTempPath(128, PC);
  TempPath := string(PC);
  FreeMem(PC, 129);
  // Dialogpfade setzen
  ODlgLevel.InitialDir := ExtractFileDir(ParamStr(0));
  ODlgTheme.InitialDir := ExtractFileDir(ParamStr(0));
  PictureDialog.InitialDir := ExtractFileDir(ParamStr(0));
  SavPicDlg.InitialDir := ExtractFileDir(ParamStr(0));
  // Data initialisieren
  Data.Images := DXImageListPack.Items;
  Data.DXDraw := DXDraw;
  Data.FontPic := DXImageList.Items[Image_Font];
  Data.Map := TPMMap.Create;
  // Grafikqualität laden
  PeterM_ini := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\PeterM.ini');
  Data.OptQuality := PeterM_ini.ReadInteger('Options', 'Quality', 1);
  Data.OptATI     := PeterM_ini.ReadInteger('Options', 'IHateFuchsia', 0);
  PeterM_ini.Free;
  // Objektlistenplatzhalter einrichten
  Data.ObjCollectibles := TPMObjBreak.Create(nil, 'Einsammelbare Objekte', ID_Break, 0, 0, 0, 0);
  Data.ObjEnd := TPMObjBreak.Create(nil, 'Objektlistenende', ID_Break, 0, 0, 0, 0);
  Data.ObjCollectibles.Data := @Data;
  Data.ObjEnd.Data := @Data;
  Data.ObjCollectibles.Next := Data.ObjEnd;
  Data.ObjEnd.Last := Data.ObjCollectibles;
  Data.ObjOther := TPMObjBreak.Create(Data.ObjCollectibles, 'Andere Objekte', ID_Break, 0, 0, 0, 0);
  Data.ObjEnemies := TPMObjBreak.Create(Data.ObjOther, 'Gegner', ID_Break, 0, 0, 0, 0);
  Data.ObjPlayers := TPMObjBreak.Create(Data.ObjEnemies, 'Spieler', ID_Break, 0, 0, 0, 0);
  Data.ObjEffects := TPMObjBreak.Create(Data.ObjPlayers, 'Effekte', ID_Break, 0, 0, 0, 0);

  // Spieler einrichten
  TPMLiving.Create(Data.ObjPlayers, '', ID_Player, 0, 0, 0, 0, 0, 0, 0);
  if ParamStr(1) = '' then MnuNeuClick(nil) else LoadLevel(ParamStr(1));
  UpdateDXDraw;
  Application.OnActivate := FormActivate;
end;

procedure TFormPeterME.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if HasChanged then case MessageDlg('Änderungen speichern?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: MnuSpeichernClick(nil);
    mrCancel: begin Action := caNone; Exit; end;
  end;

  Application.OnActivate := nil;

  // Objekte freigeben
  while Data.ObjCollectibles.Next <> Data.ObjEnd do Data.ObjCollectibles.Next.ReallyKill;

  Data.ObjCollectibles.Free; Data.ObjEnd.Free;

  // Karte freigeben
  Data.Map.Free;
end;

procedure TFormPeterME.FormPaint(Sender: TObject);
begin
  if Application.Active then UpdateDXDraw;
end;

procedure TFormPeterME.DXDrawMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LoopX, LoopY, Regetni: Integer; PlacedObject: TPMObject; NewTiles, NewTile: TBitmap; TempStr: string;
begin
  // Nur, wenn aktiv
  if not Application.Active then Exit;

  // Geändert!
  if (Y < 288) and (X < 576) and ((Button = mbLeft) or (ssShift in Shift)) then
    HasChanged := True;

  // Tilebearbeitung
  if EditingTiles then begin
    // LADEN
    if PointInRect(Point(X, Y), Bounds(150, 200, 100, 25)) and PictureDialog.Execute then begin
      // Neues Tile in string umwandeln
      NewTile := TBitmap.Create;
      NewTile.LoadFromFile(PictureDialog.Filename);
      TileOverload[SelectedTile] := '';
      for LoopX := 0 to 23 do
        for LoopY := 0 to 23 do begin
          TempStr := IntToHex(NewTile.Canvas.Pixels[LoopX, LoopY], 6);
          TileOverload[SelectedTile] := TileOverload[SelectedTile] + TempStr[5] + TempStr[6] + TempStr[3] + TempStr[4] + TempStr[1] + TempStr[2];
        end;
      NewTile.Free;
      
      // Originaltiles speichern
      DXImageListPack.Items[Image_Tiles].Picture.SaveToFile(TempPath + '\PMTempOT.bmp');
      // Originaltiles in NewTiles laden
      NewTiles := TBitmap.Create;
      NewTiles.LoadFromFile(TempPath + '\PMTempOT.bmp');
      // Neues Tile auf alte Tilemap patschen
      for LoopY := 0 to 23 do for LoopX := 0 to 23 do
        NewTiles.Canvas.Pixels[(SelectedTile mod 16) * 24 + LoopX, (SelectedTile div 16) * 24 + LoopY] := StringToColor('$00' + Copy(TileOverload[SelectedTile], 5 + 6 * (LoopY + LoopX * 24), 2) + Copy(TileOverload[SelectedTile], 3 + 6 * (LoopY + LoopX * 24), 2) + Copy(TileOverload[SelectedTile], 1 + 6 * (LoopY + LoopX * 24), 2));

      // Datei speichern und wieder einladen
      NewTiles.SaveToFile(TempPath + '\PMTempOT.bmp');
      NewTiles.Free;
      DXImageListPack.Items[Image_Tiles].Picture.LoadFromFile(TempPath + '\PMTempOT.bmp');
      DXImageListPack.Items[Image_Tiles].Restore;
      DeleteFile(TempPath + '\PMTempOT.bmp');
    end;
    // SPEICHERN
    if PointInRect(Point(X, Y), Bounds(150, 250, 100, 25)) and SavPicDlg.Execute then begin
      // BMP dran?
      if LowerCase(Copy(SavPicDlg.FileName, Length(SavPicDlg.FileName) - 3, 4)) <> '.bmp' then SavPicDlg.FileName := SavPicDlg.FileName + '.bmp';
      // Abfrage
      if FileExists(SavPicDlg.FileName) and (MessageDlg('Datei besteht bereits. Überschreiben?', mtConfirmation, [mbYes, mbNo], 0) = mrNo) then Exit;
      // Originaltiles speichern
      DXImageListPack.Items[Image_Tiles].Picture.SaveToFile(TempPath + '\PMTempOT.bmp');

      // NewTile(s) erstellen
      NewTiles := TBitmap.Create;
      NewTiles.LoadFromFile(TempPath + '\PMTempOT.bmp');
      NewTile := TBitmap.Create;
      NewTile.Width := 24; NewTile.Height := 24; NewTile.PixelFormat := pf24bit;
      // Tile auf NewTiles übertragen
      for LoopY := 0 to 23 do for LoopX := 0 to 23 do
        NewTile.Canvas.Pixels[LoopX, LoopY] := NewTiles.Canvas.Pixels[(SelectedTile mod 16) * 24 + LoopX, (SelectedTile div 16) * 24 + LoopY];
      // Datei speichern und wieder einladen
      NewTile.SaveToFile(SavPicDlg.FileName);
      NewTile.Free;
      NewTiles.Free;
      DeleteFile(TempPath + '\PMTempOT.bmp');
    end;
    // LÖSCHEN
    if PointInRect(Point(X, Y), Bounds(350, 200, 100, 25)) then begin
      // Aktuelles Tile löschen
      TileOverload[SelectedTile] := '';
      // Thema neu laden und alte Überladungen löschen
      MnuAktualisierenClick(nil);
      // Originaltiles speichern
      DXImageListPack.Items[Image_Tiles].Picture.SaveToFile(TempPath + '\PMTempOT.bmp');
      // Originaltiles in NewTiles laden
      NewTiles := TBitmap.Create;
      NewTiles.LoadFromFile(TempPath + '\PMTempOT.bmp');
      // Überladene Tiles einlesen
      for Regetni := 0 to 255 do begin if Length(TileOverload[Regetni]) = 3456 then
        // Neues Tile auf alte Tilemap patschen
        for LoopY := 0 to 23 do for LoopX := 0 to 23 do
          NewTiles.Canvas.Pixels[(Regetni mod 16) * 24 + LoopX, (Regetni div 16) * 24 + LoopY] := StringToColor('$00' + Copy(TileOverload[Regetni], 5 + 6 * (LoopY + LoopX * 24), 2) + Copy(TileOverload[Regetni], 3 + 6 * (LoopY + LoopX * 24), 2) + Copy(TileOverload[Regetni], 1 + 6 * (LoopY + LoopX * 24), 2));
      end;
      // Datei speichern und wieder einladen
      NewTiles.SaveToFile(TempPath + '\PMTempOT.bmp');
      NewTiles.Free;
      DXImageListPack.Items[Image_Tiles].Picture.LoadFromFile(TempPath + '\PMTempOT.bmp');
      DXImageListPack.Items[Image_Tiles].Restore;
      DeleteFile(TempPath + '\PMTempOT.bmp');
    end;
    // ZURÜCK
    if PointInRect(Point(X, Y), Bounds(350, 250, 100, 25)) then begin
      EditingTiles := False;
      WasJustEditingTiles := True;
      MnuDatei.Enabled := True;
      MnuAnderes.Enabled := True;
      ScrollBar.Enabled := True;
      PnlProperties.Enabled := True;
    end;
    UpdateDXDraw;
    Exit;
  end;

  // Zielauswahl
  if SelectingTarget then if (X < 576) and (Y < 288) then begin
    SelectingTarget := False;
    PnlProperties.Enabled := True;
    MnuDatei.Enabled := True;
    MnuAnderes.Enabled := True;
    LoopX := CmbLeverTargets.ItemIndex;
    CmbLeverTargets.Items[LoopX] := IntToHex(X div 24, 2) + '|'
      + IntToHex(Y div 24 + ScrollBar.Position, 3) + Copy(CmbLeverTargets.Items[LoopX], 7, 3);
    CmbLeverTargets.ItemIndex := LoopX;
    UpdateOptObj(nil);
    Exit;
  end else Exit;

  // Teilauswahl
  if SelectingTile then if (X < 600) and (Y >= 288) then begin
    Regetni := -1;
    for LoopX := 0 to 15 do begin
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 289, 24, 24)) then Regetni := ScrollBarTiles.Position * 16 + LoopX;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 314, 24, 24)) then Regetni := ScrollBarTiles.Position * 16 + LoopX + 16;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 339, 24, 24)) then Regetni := ScrollBarTiles.Position * 16 + LoopX + 32;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 364, 24, 24)) then Regetni := ScrollBarTiles.Position * 16 + LoopX + 48;
    end;
    if Regetni = -1 then Exit;

    SelectingTile := False;
    PnlProperties.Enabled := True;
    MnuDatei.Enabled := True;
    MnuAnderes.Enabled := True;
    ScrollBar.Enabled := True;
    ScrollBarTiles.Visible := False;

    LoopX := CmbLeverTargets.ItemIndex;
    CmbLeverTargets.Items[LoopX] := Copy(CmbLeverTargets.Items[LoopX], 1, 7) + IntToHex(Regetni, 2);
    CmbLeverTargets.ItemIndex := LoopX;
    UpdateOptObj(nil);
    Exit;
  end else Exit;

  // Scriptbefehle bearbeiten
  if (ssCtrl in Shift) and (Button = mbLeft) and (Y < 288) then begin
    Data.Map.Scripts[Y div 24 + ScrollBar.Position] :=
      InputBox('Skriptereignis bearbeiten',
               'Skriptereignis bei Zeile ' + IntToStr(Y div 24 + ScrollBar.Position) + ':',
               Data.Map.Scripts[Y div 24 + ScrollBar.Position]);
    Change(nil);
    UpdateDXDraw;
    Exit;
  end;
  // Mausposition in Hex anzeigen
  if (ssCtrl in Shift) and (Button = mbRight) and (Y < 288) then begin
    MessageDlg('Mausklick bei #' + IntToHex(X, 3) + ', #' + IntToHex(Y + ScrollBar.Position * 24, 4) +
               ', Tile #' + IntToHex(X div 24, 2) + ', #' + IntToHex(Y div 24 + ScrollBar.Position, 3) + '.',
               mtInformation, [mbOk], 0);
    Exit;
  end;

  // Kartenteile malen oder auswählen
  if RadioMapTiles.Checked then begin
    if PointInRect(Point(X, Y), Rect(0, 0, 575, 287)) then case Button of
      mbLeft: begin
                Data.Map.Tiles[X div 24, Y div 24 + Scrollbar.Position] := SelectedTile;
                if ssShift in Shift then begin
                  Data.Map.SetTile(X div 24 - 1, Y div 24 - 1 + Scrollbar.Position, SelectedTile);
                  Data.Map.SetTile(X div 24,     Y div 24 - 1 + Scrollbar.Position, SelectedTile);
                  Data.Map.SetTile(X div 24 + 1, Y div 24 - 1 + Scrollbar.Position, SelectedTile);
                  Data.Map.SetTile(X div 24 - 1, Y div 24     + Scrollbar.Position, SelectedTile);
                  Data.Map.SetTile(X div 24 + 1, Y div 24     + Scrollbar.Position, SelectedTile);
                  Data.Map.SetTile(X div 24 - 1, Y div 24 + 1 + Scrollbar.Position, SelectedTile);
                  Data.Map.SetTile(X div 24,     Y div 24 + 1 + Scrollbar.Position, SelectedTile);
                  Data.Map.SetTile(X div 24 + 1, Y div 24 + 1 + Scrollbar.Position, SelectedTile);
                end;
              end;
      mbRight: SelectedTile := Data.Map.Tiles[X div 24, Y div 24 + Scrollbar.Position];
    end;
    for LoopX := 0 to 15 do begin
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 289, 24, 24)) then begin SelectedTile := ScrollBarTiles.Position * 16 + LoopX; if Button = mbRight then begin EditingTiles := True; MnuDatei.Enabled := False; MnuAnderes.Enabled := False; PnlProperties.Enabled := False; ScrollBar.Enabled := False; end; end;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 314, 24, 24)) then begin SelectedTile := ScrollBarTiles.Position * 16 + LoopX + 16; if Button = mbRight then begin EditingTiles := True; MnuDatei.Enabled := False; MnuAnderes.Enabled := False; PnlProperties.Enabled := False; ScrollBar.Enabled := False; end; end;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 339, 24, 24)) then begin SelectedTile := ScrollBarTiles.Position * 16 + LoopX + 32; if Button = mbRight then begin EditingTiles := True; MnuDatei.Enabled := False; MnuAnderes.Enabled := False; PnlProperties.Enabled := False; ScrollBar.Enabled := False; end; end;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 364, 24, 24)) then begin SelectedTile := ScrollBarTiles.Position * 16 + LoopX + 48; if Button = mbRight then begin EditingTiles := True; MnuDatei.Enabled := False; MnuAnderes.Enabled := False; PnlProperties.Enabled := False; ScrollBar.Enabled := False; end; end;
    end;
    if SelectedTile in [$70..$DF] then
      StatusBar.Panels[1].Text := 'Ausgewählt: Kartenteil #' + IntToHex(SelectedTile, 2) + ' (Fest)'
    else
      StatusBar.Panels[1].Text := 'Ausgewählt: Kartenteil #' + IntToHex(SelectedTile, 2) + ' (Hintergrund)';
  end;
  // Objekteditormodus
  if RadioObjects.Checked then begin
    if PointInRect(Point(X, Y), Bounds(0, 0, 575, 287)) then case Button of
      // Objekte: platzieren
      mbLeft: if SelectedObject > ID_PlayerMax then begin
        ShowObjOpts(nil);
        PlacedObject := CreateObject(Data, '', SelectedObject, X, Y + ScrollBar.Position * 24, 0, 0);
        if SelectedObject in [ID_Firewall1, ID_Firewall2, ID_HelpArrow] then begin
          PlacedObject.PosX := PlacedObject.PosX div 24 * 24 + 11;
          PlacedObject.PosY := PlacedObject.PosY div 24 * 24 + 11;
          if SelectedObject in [ID_Firewall1, ID_Firewall2] then PlacedObject.ExtraData := '128';
        end else if ssShift in Shift then while not PlacedObject.Blocked(Dir_Down) do Inc(PlacedObject.PosY);
      // Spieler: nur verschieben
      end else with Data.ObjPlayers.Next do begin
        ShowObjOpts(nil);
        ID := SelectedObject;
        PosX := X;
        PosY := Y + Data.ViewPos;
        if ssShift in Shift then while not Blocked(Dir_Down) do Inc(PosY);
      end;
      // Objekte löschen oder Eigenschaften anzeigen
      mbRight: if ssShift in Shift then begin
                 PlacedObject := GetObject(X, Y + ScrollBar.Position * 24);
                 if (PlacedObject <> nil) and (PlacedObject <> Data.ObjPlayers.Next) then
                   begin ShowObjOpts(nil); PlacedObject.ReallyKill; end else Exit;
               end else ShowObjOpts(GetObject(X, Y + ScrollBar.Position * 24));
    end;
    for LoopX := 0 to 15 do begin
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 289, 24, 24)) and (LoopX < 10) then SelectedObject := LoopX;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 314, 24, 24)) then SelectedObject := LoopX + 16;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 339, 24, 24)) then SelectedObject := LoopX + 32;
      if PointInRect(Point(X, Y), Bounds(LoopX * 25 + 199, 364, 24, 24)) then SelectedObject := LoopX + 48;
    end;
    StatusBar.Panels[1].Text := 'Ausgewählt: ' + Data.Defs[SelectedObject].Name + ' (#' + IntToHex(SelectedObject, 2) + ')' ;
  end;
  UpdateDXDraw;
end;

procedure TFormPeterME.RadioClick(Sender: TObject);
begin
  // Kartenteilmodus
  ScrollBarTiles.Visible := RadioMapTiles.Checked;
  PnlMapOptions.Visible := RadioMapTiles.Checked;

  // Objekteditormodus
  PnlObjOpts.Visible := RadioObjects.Checked;

  // Statusleiste anpassen
  if RadioMapTiles.Checked then begin
    if SelectedTile in [$70..$DF] then
      StatusBar.Panels[1].Text := 'Ausgewählt: Kartenteil ' + IntToHex(SelectedTile, 2) + ' (Fest)'
    else
      StatusBar.Panels[1].Text := 'Ausgewählt: Kartenteil ' + IntToHex(SelectedTile, 2) + ' (Hintergrund)';
    ShowObjOpts(nil);
  end else
    StatusBar.Panels[1].Text := 'Ausgewählt: ' + Data.Defs[SelectedObject].Name;

  // Modus in die Leiste schreiben
  if RadioMapTiles.Checked then StatusBar.Panels[0].Text := 'Kartenteilbaumodus'
                           else StatusBar.Panels[0].Text := 'Objekteditormodus';

  // Und nochmal alles malen
  UpdateDXDraw;
end;

procedure TFormPeterME.UpdateDXDraw;
var
  LoopX, LoopY: Integer;
  TempObj: TPMObject;
  // Objekt malen
  procedure DrawObject(X, Y, ID, Size: Integer);
  begin case ID of
    ID_Player..ID_PlayerMax:
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], (ID - ID_Player) * Act_Num * 2, Bounds(X, Y, Size, Size), Boolean(Data.OptATI));
    ID_Enemy..ID_EnemyMax:
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], (ID - ID_Enemy) * Act_Num * 2, Bounds(X, Y, Size, Size), Boolean(Data.OptATI));
    ID_OtherObjectsMin..ID_CollectibleMax:
      MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID - ID_OtherObjectsMin, Bounds(X, Y, Size, Size), Boolean(Data.OptATI));
  end; end;
begin
  if not DXDraw.CanDraw then Exit;

  // Alles löschen
  DXDraw.Surface.FillRect(Bounds(0, 0, 600, 288), 0);

  // ViewPos setzen
  Data.ViewPos := ScrollBar.Position * 24;

  // Himmel
  case Data.Map.Sky of
    0: for LoopY := 0 to 3 do
         for LoopX := 0 to 3 do
           DXImageListPack.Items[Image_Sky].Draw(DXDraw.Surface, LoopX * 144, LoopY * 120, Data.Map.Sky);
    else
      for LoopY := 0 to 3 do
        for LoopX := 0 to 3 do
          DXImageListPack.Items[Image_Sky].Draw(DXDraw.Surface, LoopX * 144, LoopY * 120 - Data.ViewPos mod 120, Data.Map.Sky);
  end;

  // Kartenteile
  for LoopY := 0 to 11 do begin
    for LoopX := 0 to 23 do
      DXImageListPack.Items[Image_Tiles].Draw(DXDraw.Surface, LoopX * 24, LoopY * 24, Data.Map.Tiles[LoopX, LoopY + ScrollBar.Position]);
    if LoopY + ScrollBar.Position = SdtLavaPos.Value then DXImageList.Items[Image_Danger].Draw(DXDraw.Surface, 588, LoopY * 24, 0);
    if LoopY < SdtLevelTop.Value - ScrollBar.Position then DXDraw.Surface.FillRect(Bounds(0, 0 + 24 * LoopY, 576, 24), 0);
  end;

  // Ausgewähltes Hebelziel
  if (OptObj <> nil) and (OptObj.ID in [ID_Lever..ID_LeverRight]) and (CmbLeverTargets.Enabled = True)
    and (CmbLeverTargets.ItemIndex > -1) and (StrToInt('$' + Copy(CmbLeverTargets.Items[CmbLeverTargets.ItemIndex], 4, 3)) >= ScrollBar.Position)
      and (StrToInt('$' + Copy(CmbLeverTargets.Items[CmbLeverTargets.ItemIndex], 4, 3)) <= ScrollBar.Position + 11) then
        DXDraw.Surface.FillRectAlpha(Bounds(24 * StrToInt('$' + Copy(CmbLeverTargets.Items[CmbLeverTargets.ItemIndex], 1, 2)), 24 * (StrToInt('$' + Copy(CmbLeverTargets.Items[CmbLeverTargets.ItemIndex], 4, 3)) - Scrollbar.Position), 24, 24), clWhite, 64);

  // Nummerrrrn
  for LoopY := 0 to 11 do
    if Data.Map.Scripts[LoopY + ScrollBar.Position] = '' then
      DrawBMPText(FillWithChar(IntToStr(LoopY + ScrollBar.Position), 4, '0'), 563, LoopY * 24 + 4, 160, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality)
    else
      DrawBMPText(FillWithChar(IntToStr(LoopY + ScrollBar.Position), 4, '0'), 563, LoopY * 24 + 4, 255, DXImageList.Items[Image_Font], DXDraw.Surface, Data.OptQuality);

  // Objekte zeichnen
  TempObj := Data.ObjCollectibles.Next;
  while TempObj <> Data.ObjEnd do begin
    TempObj.Draw;
    if TempObj = OptObj then begin
      DXDraw.Surface.Canvas.Brush.Color := clYellow;
      DXDraw.Surface.Canvas.FrameRect(Bounds(Data.Defs[TempObj.ID].Rect.Left + TempObj.PosX - 2,
                                             Data.Defs[TempObj.ID].Rect.Top  + TempObj.PosY - ScrollBar.Position * 24 - 2,
                                             Data.Defs[TempObj.ID].Rect.Right + 5,
                                             Data.Defs[TempObj.ID].Rect.Bottom + 5));
      DXDraw.Surface.Canvas.Release;
    end;
    TempObj := TempObj.Next;
  end;

  // Objektboxen
  if MnuBoxen.Checked then begin
    TempObj := Data.ObjCollectibles.Next;
    while TempObj <> Data.ObjEnd do begin
      if TempObj.Stuck then DXDraw.Surface.Canvas.Brush.Color := clRed
        else DXDraw.Surface.Canvas.Brush.Color := clWhite;
      DXDraw.Surface.Canvas.FrameRect(Bounds(Data.Defs[TempObj.ID].Rect.Left + TempObj.PosX,
                                             Data.Defs[TempObj.ID].Rect.Top  + TempObj.PosY - ScrollBar.Position * 24,
                                             Data.Defs[TempObj.ID].Rect.Right + 1,
                                             Data.Defs[TempObj.ID].Rect.Bottom + 1));
      TempObj := TempObj.Next;
    end;
    DXDraw.Surface.Canvas.Release;
  end;

  // Leistenhintergrund
  DXImageList.Items[Image_Bar].Draw(DXDraw.Surface, 0, 288, 0);

  // Kartenteilauswahl
  if RadioMapTiles.Checked or SelectingTile then begin
    for LoopX := 0 to 15 do begin
      DXImageListPack.Items[Image_Tiles].Draw(DXDraw.Surface, LoopX * 25 + 199, 289, ScrollBarTiles.Position * 16 + LoopX);
    end;
    DrawBMPText(IntToHex(ScrollBarTiles.Position * 16, 2)      + '-' + IntToHex(ScrollBarTiles.Position * 16 + 15, 2) + '>', 140, 292, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    for LoopX := 0 to 15 do begin
      DXImageListPack.Items[Image_Tiles].Draw(DXDraw.Surface, LoopX * 25 + 199, 314, ScrollBarTiles.Position * 16 + LoopX + 16);
    end;
    DrawBMPText(IntToHex(ScrollBarTiles.Position * 16 + 16, 2) + '-' + IntToHex(ScrollBarTiles.Position * 16 + 31, 2) + '>', 140, 317, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    for LoopX := 0 to 15 do begin
      DXImageListPack.Items[Image_Tiles].Draw(DXDraw.Surface, LoopX * 25 + 199, 339, ScrollBarTiles.Position * 16 + LoopX + 32);
    end;
    DrawBMPText(IntToHex(ScrollBarTiles.Position * 16 + 32, 2) + '-' + IntToHex(ScrollBarTiles.Position * 16 + 47, 2) + '>', 140, 342, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    for LoopX := 0 to 15 do begin
      DXImageListPack.Items[Image_Tiles].Draw(DXDraw.Surface, LoopX * 25 + 199, 364, ScrollBarTiles.Position * 16 + LoopX + 48);
    end;
    DrawBMPText(IntToHex(ScrollBarTiles.Position * 16 + 48, 2) + '-' + IntToHex(ScrollBarTiles.Position * 16 + 63, 2) + '>', 140, 367, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], SelectedTile, Bounds(8, 290, 96, 96), Boolean(Data.OptATI));
  end;

  // Leiste "Objekte"
  if RadioObjects.Checked and (not SelectingTile) then begin
    for LoopX := 0 to 15 do
      DrawObject(LoopX * 25 + 199, 289, LoopX, 24);
    for LoopX := 0 to 15 do
      DrawObject(LoopX * 25 + 199, 314, LoopX + 16, 24);
    for LoopX := 0 to 15 do
      DrawObject(LoopX * 25 + 199, 339, LoopX + 32, 24);
    for LoopX := 0 to 15 do
      DrawObject(LoopX * 25 + 199, 364, LoopX + 48, 24);
    DrawObject(8, 290, SelectedObject, 96);
  end;

  // Teilbearbeitung
  if EditingTiles then begin
    // Schwarz und so
    DXDraw.Surface.FillRect(Bounds(0, 0, 600, 288), 0);
    // Großes Tile
    MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], SelectedTile, Bounds(228, 30, 120, 120), Boolean(Data.OptATI));
    // Tilebeschreibung
    DrawBMPText('Teil ' + IntToHex(SelectedTile, 2) + '.', 240, 160, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    if TileOverload[SelectedTile] <> ''  then DrawBMPText('Tile ist nicht mehr im Originalzustand.', 240, 180, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    // Button "Laden"
    DXDraw.Surface.FillRect(Bounds(150, 200, 100, 25), DXDraw.Surface.ColorMatch(clGray));
    DrawBMPText('Laden', 178, 203, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    // Button "Speichern"
    DXDraw.Surface.FillRect(Bounds(150, 250, 100, 25), DXDraw.Surface.ColorMatch(clGray));
    DrawBMPText('Speichern', 160, 253, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    // Button "Löschen"
    if TileOverload[SelectedTile] = '' then begin
      DXDraw.Surface.FillRect(Bounds(350, 200, 100, 25), DXDraw.Surface.ColorMatch(clGray div 2));
      DrawBMPText('Löschen', 368, 203, 128, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    end else begin
      DXDraw.Surface.FillRect(Bounds(350, 200, 100, 25), DXDraw.Surface.ColorMatch(clGray));
      DrawBMPText('Löschen', 368, 203, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    end;
    // Button "Zurück"
    DXDraw.Surface.FillRect(Bounds(350, 250, 100, 25), DXDraw.Surface.ColorMatch(clGray));
    DrawBMPText('Zurück', 373, 253, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
    // Leiste unten dunkel
    DXDraw.Surface.FillRectAlpha(Rect(0, 288, 600, 388), clBlack, 192);
  end;

  // Zielauswahl
  if SelectingTarget then begin
    DXDraw.Surface.FillRectAlpha(Rect(0, 288, 600, 388), clBlack, 192);
    DrawBMPText('Klicke in die Karte, um das Hebelziel zu platzieren.', 60, 335, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  end;

  // Teilauswahl
  if SelectingTile then begin
    DXDraw.Surface.FillRectAlpha(Rect(0, 0, 600, 288), clBlack, 192);
    DrawBMPText('Wähle unten das Zielteil aus.', 160, 140, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  end;

  // Aktualisieren
  DXDraw.Flip;  
end;

function TFormPeterME.GetObject(X, Y: Integer): TPMObject;
var
  TempObj: TPMObject;
begin
  TempObj := Data.ObjCollectibles.Next;
  while TempObj <> Data.ObjEnd do begin
    if (TempObj.ID >= ID_Player) and PointInRect(Point(X, Y), TempObj.GetRect(0, 0)) then
      begin Result := TempObj; Exit; end;
    TempObj := TempObj.Next;
  end;
  Result := nil;
end;

procedure TFormPeterME.MnuAktualisierenClick(Sender: TObject);
var
  Theme_def: TIniFile32; Loop: Integer;
begin
  // Theme-Grafiken aus Bitmaps in die DXImageListPack-Items laden
  DXImageListPack.Items.LoadFromFile(ExtractFileDir(ParamStr(0)) + '\' + MapTheme + '.pmt');
  // Objekttypdefinitionen laden
  Theme_def := TIniFile32.Create(ExtractFileDir(ParamStr(0)) + '\' + MapTheme + '.def');
  for Loop := 0 to ID_Max do with Data.Defs[Loop] do begin
    Name := Theme_def.ReadString('ObjName', IntToHex(Loop, 2), 'Objekt ' + IntToStr(Loop));
    Life := Theme_def.ReadInteger('ObjLife', IntToHex(Loop, 2), 3);
    Rect := Classes.Rect(-StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(Loop, 2), '10102020'), 1, 2), 16),
                         -StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(Loop, 2), '10102020'), 3, 2), 16),
                         +StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(Loop, 2), '10102020'), 5, 2), 16),
                         +StrToIntDef('$' + Copy(Theme_def.ReadString('ObjRect', IntToHex(Loop, 2), '10102020'), 7, 2), 16));
  end;
  // Himmel laden
  CbxSkies.Items.Clear;
  for Loop := 0 to Theme_def.ReadInteger('Skies', 'Num', 1) - 1 do
    CbxSkies.Items.Add(Theme_def.ReadString('Skies', 'Desc' + IntToStr(Loop), '<Unbenannter Himmel>'));
  Theme_def.Free;
  if Sender <> nil then UpdateDXDraw;
end;

procedure TFormPeterME.MnuNeuClick(Sender: TObject);
var
  TempObj: TPMObject; I: Integer;
begin
  // Dialog, vorher speichern?
  if HasChanged then case MessageDlg('Änderungen vorher speichern?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: MnuSpeichernClick(nil);
    mrCancel: Exit;
  end;

  // Nix geändert
  EdtMapName.Text := 'Kartenname';
  EdtMapSkill.Text := 'Schwierigkeitsgrad';
  EdtMapDesc.Text := 'Kurze Kartenbeschreibung';
  MapTheme := 'Ritter';
  MapAuthor := 'Anonym, email@adresse';

  // Nix anzeigen
  ShowObjOpts(nil);

  // Objekte löschen
  TempObj := Data.ObjCollectibles.Next;
  while TempObj <> nil do begin
    if TempObj.Last.ID >= ID_Enemy then TempObj.Last.ReallyKill;
    TempObj := TempObj.Next;
  end;

  // Überladene Tiles löschen
  for I := 0 to 255 do TileOverload[I] := '';

  // Alles neu laden
  MnuAktualisierenClick(nil);


  // Andere Sachen zurücksetzen
  with Data do begin
    Map.Clear;

    Map.Sky := 0; CbxSkies.ItemIndex := 0;

    SdtLavaSpeed.Value := 1; RadLavaMode0.Checked := True;
    SdtLavaPos.Value := 1024; SdtLevelTop.Value := 0;
    MnuLavaScore.Checked := True;

    StarsGoal := 100; SdtPiecesGoal.Value := 100;

    ObjPlayers.Next.ID := ID_Player;
    ObjPlayers.Next.PosX := 288;
    ObjPlayers.Next.PosY := 24515;
    ObjPlayers.Next.VelX := 0;
    ObjPlayers.Next.VelY := 0;
    TPMLiving(ObjPlayers.Next).Direction := Random(2);
    TPMLiving(ObjPlayers.Next).Action := Act_Stand;
    TPMLiving(ObjPlayers.Next).Life := Data.Defs[ID_Player].Life;
  end;

  UpdateDXDraw;
  RefreshTimerMenus;
  HasChanged := False;

  SDlgLevel.FileName := '';
end;

procedure TFormPeterME.MnuLadenClick(Sender: TObject);
begin
  // Dialog, vorher speichern?
  if HasChanged then case MessageDlg('Änderungen vorher speichern?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: MnuSpeichernClick(nil);
    mrCancel: Exit;
  end;
  // Level auswählen
  if ODlgLevel.Execute = True then LoadLevel(ODlgLevel.FileName);
end;

procedure TFormPeterME.LoadLevel(FileName: string);
var
  Input: TIniFile32;
  LoopX, LoopY, LoopT: Integer;
  Row, ObjString: string;
  TempObj: TPMObject;
  NewTiles: TBitmap;
  OverloadedTiles: TStringList;
begin
  SDlgLevel.FileName := FileName;

  // Erstmal Karte löschen
  Data.Map.Clear;

  // Karteneigenschaften laden
  Input := TIniFile32.Create(FileName);

  // Karteninformationen
  EdtMapName.Text := Input.ReadString('Info', 'Title', 'Kartenname');
  EdtMapSkill.Text := Input.ReadString('Info', 'Skill', 'Schwierigkeitsgrad');
  EdtMapDesc.Text := Input.ReadString('Info', 'Desc', 'Kurze Kartenbeschreibung');
  MapTheme := Input.ReadString('Info', 'Theme', 'Ritter');
  MapAuthor := Input.ReadString('Info', 'Author', 'Anonym, email@adresse');

  // Einzusammelnde Sterne
  Data.StarsGoal := Input.ReadInteger('Map', 'StarsGoal', 100);
  SdtPiecesGoal.Value := Data.StarsGoal;

  // Lavawerte
  SdtLavaSpeed.Value := Input.ReadInteger('Map', 'LavaSpeed', 1);
  RadLavaMode0.Checked := True;
  RadLavaMode1.Checked := (Input.ReadInteger('Map', 'LavaMode', 0) = 1);
  SdtLavaPos.Value := Input.ReadInteger('Map', 'LavaPos', 1024);
  MnuLavaScore.Checked := Input.ReadBool('Map', 'LavaScore', True);
  SdtLevelTop.Value := Input.ReadInteger('Map', 'LevelTop', 0);

  ScrollBar.Position := Min(1012, Max(0, SdtLavaPos.Value - 11));

  // Überladene Tiles löschen
  for LoopT := 0 to 255 do TileOverload[LoopT] := '';
  MnuAktualisierenClick(nil);
  OverloadedTiles := TStringList.Create;
  Input.ReadSection('Tiles', OverloadedTiles);
  if OverloadedTiles.Count > 0 then begin
    // Originaltiles speichern
    DXImageListPack.Items[Image_Tiles].Picture.SaveToFile(TempPath + '\PMTempOT.bmp');
    // Originaltiles in NewTiles laden
    NewTiles := TBitmap.Create;
    NewTiles.LoadFromFile(TempPath + '\PMTempOT.bmp');
    // Überladene Tiles einlesen
    for LoopT := 0 to 255 do begin
      TileOverload[LoopT] := Input.ReadString('Tiles', IntToHex(LoopT, 2), '');
      if Length(TileOverload[LoopT]) = 3456 then begin
        // Neues Tile auf alte Tilemap patschen
        for LoopY := 0 to 23 do for LoopX := 0 to 23 do
          NewTiles.Canvas.Pixels[(LoopT mod 16) * 24 + LoopX, (LoopT div 16) * 24 + LoopY] := StringToColor('$00' + Copy(TileOverload[LoopT], 5 + 6 * (LoopY + LoopX * 24), 2) + Copy(TileOverload[LoopT], 3 + 6 * (LoopY + LoopX * 24), 2) + Copy(TileOverload[LoopT], 1 + 6 * (LoopY + LoopX * 24), 2));
      end else TileOverload[LoopT] := '';
    end;
    // Datei speichern und wieder einladen
    NewTiles.SaveToFile(TempPath + '\PMTempOT.bmp');
    NewTiles.Free;
    DXImageListPack.Items[Image_Tiles].Picture.LoadFromFile(TempPath + '\PMTempOT.bmp');
    DXImageListPack.Items[Image_Tiles].Restore;
    DeleteFile(TempPath + '\PMTempOT.bmp');
  end;
  OverloadedTiles.Free;

  // Himmel
  Data.Map.Sky := Min(Input.ReadInteger('Map', 'Sky', 0), CbxSkies.Items.Count - 1);
  CbxSkies.ItemIndex := Data.Map.Sky;
  CbxSkies.Text := CbxSkies.Items[CbxSkies.ItemIndex];

  // Karte laden
  for LoopY := 0 to 1023 do begin
    Row := Input.ReadString('Map', IntToStr(LoopY), '000000000000000000000000000000000000000000000000');
    for LoopX := 0 to 23 do
      Data.Map.Tiles[LoopX, LoopY] := StrToIntDef('$' + Copy(Row, LoopX * 2 + 1, 2), 00);
    Data.Map.Scripts[LoopY] := Input.ReadString('Scripts', IntToStr(LoopY), '');
  end;

  // Timerskripte laden
  for LoopX := 0 to 10 do
    Data.Map.ScriptTimers[LoopX] := Input.ReadString('Scripts', 'Timer' + IntToStr(LoopX), '');
  RefreshTimerMenus;

  // Nix anzeigen
  ShowObjOpts(nil);

  // Alte Objekte löschen
  TempObj := Data.ObjCollectibles.Next;
  while TempObj <> nil do begin
    if TempObj.Last.ID >= ID_Enemy then TempObj.Last.ReallyKill;
    TempObj := TempObj.Next;
  end;

  // Neue Objekte laden
  LoopX := -1;
  while True do begin
    Inc(LoopX);
    ObjString := Input.ReadString('Objects', IntToStr(LoopX), '');
    if ObjString <> '' then
      CreateObject(Data,
                   Input.ReadString('Objects', IntToStr(LoopX) + 'Y', ''),
                   StrToIntDef('$' + Copy(ObjString, 1, 2), 0),
                   StrToIntDef('$' + Copy(ObjString, 4, 3), 288),
                   StrToIntDef('$' + Copy(ObjString, 8, 4), 0),
                   StrToIntDef('$' + Copy(ObjString, 13, 5), 0),
                   StrToIntDef('$' + Copy(ObjString, 19, 5), 0)) else Break;
  end;

  // Spieler einrichten
  with TPMLiving(Data.ObjPlayers.Next) do begin
    ID := Input.ReadInteger('Objects', 'PlayerID', ID_Player);
    PosX := Input.ReadInteger('Objects', 'PlayerX', 288);
    PosY := Input.ReadInteger('Objects', 'PlayerY', 24515);
    VelX := Input.ReadInteger('Objects', 'PlayerVX', 0);
    VelY := Input.ReadInteger('Objects', 'PlayerVY', 0);
    Direction := Input.ReadInteger('Objects', 'PlayerDirection', Random(2));
    Action := Act_Stand;
    Life := Input.ReadInteger('Objects', 'PlayerLife', Data.Defs[ID_Player].Life);
  end;

  // Nix geändert
  HasChanged := False;

  // Laden abschließen
  Input.Free;
  UpdateDXDraw;
end;

procedure TFormPeterME.MnuSpeichernClick(Sender: TObject);
var
  Output: TIniFile32;
  LoopX, LoopY, LoopT: Integer;
  Row: string;
  TempObj: TPMObject;
begin
  if SDlgLevel.FileName = '' then begin
    if not SDlgLevel.Execute then begin SDlgLevel.FileName := ''; Exit; end;
    if FileExists(SDlgLevel.FileName) then begin
      if MessageDlg('Level existiert bereits. Überschreiben?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then begin SDlgLevel.FileName := ''; Exit; end;
    end;
  end;
  DeleteFile(SDlgLevel.FileName);
  // Nix geändert
  HasChanged := False;
  ODlgLevel.FileName := SDlgLevel.FileName;
  Output := TIniFile32.Create(SDlgLevel.FileName);
  // Levelinformationen
  Output.WriteString('Info', 'Version', PMVersion);
  Output.WriteString('Info', 'Title', EdtMapName.Text);
  Output.WriteString('Info', 'Skill', EdtMapSkill.Text);
  Output.WriteString('Info', 'Desc', EdtMapDesc.Text);
  Output.WriteString('Info', 'Theme', MapTheme);
  Output.WriteString('Info', 'Author', MapAuthor);
  // Leveleigenschaften
  Output.WriteInteger('Map', 'Sky', Max(Data.Map.Sky, 0));
  Output.WriteInteger('Map', 'StarsGoal', Data.StarsGoal);
  Output.WriteInteger('Map', 'LavaSpeed', SdtLavaSpeed.Value);
  Output.WriteInteger('Map', 'LavaMode', Integer(RadLavaMode1.Checked));
  Output.WriteInteger('Map', 'LavaPos', SdtLavaPos.Value);
  Output.WriteBool('Map', 'LavaScore', MnuLavaScore.Checked);
  Output.WriteInteger('Map', 'LevelTop', SdtLevelTop.Value);
  // Karte
  for LoopY := Max(0, SdtLevelTop.Value) to Min(1023, SdtLavaPos.Value - 1) do begin
    Row := '';
    for LoopX := 0 to 23 do
      Row := Row + IntToHex(Data.Map.Tiles[LoopX, LoopY], 2);
    if Row <> '000000000000000000000000000000000000000000000000' then Output.WriteString('Map', IntToStr(LoopY), Row);
  end;
  // Überladene Tilez
  for LoopT := 0 to 255 do if TileOverload[LoopT] <> '' then Output.WriteString('Tiles', IntToHex(LoopT, 2), TileOverload[LoopT]);
  // Scripts
  for LoopY := 0 to 1023 do if Data.Map.Scripts[LoopY] <> '' then Output.WriteString('Scripts', IntToStr(LoopY), Data.Map.Scripts[LoopY]);
  for LoopX := 0 to 10 do if Data.Map.ScriptTimers[LoopX] <> '' then Output.WriteString('Scripts', 'Timer' + IntToStr(LoopX), Data.Map.ScriptTimers[LoopX]);
  // Spieler eintragen
  with TPMLiving(Data.ObjPlayers.Next) do begin
    if ID <> ID_Player then Output.WriteInteger('Objects', 'PlayerID', ID);
    if PosX <> 288 then Output.WriteInteger('Objects', 'PlayerX', PosX);
    if PosY <> 24515 then Output.WriteInteger('Objects', 'PlayerY', PosY);
    if VelX <> 0 then Output.WriteInteger('Objects', 'PlayerVX', VelX);
    if VelY <> 0 then Output.WriteInteger('Objects', 'PlayerVY', VelY);
    Output.WriteInteger('Objects', 'PlayerDirection', Direction);
    Output.WriteInteger('Objects', 'PlayerLife', Life);
  end;
  // Objekte speichern
  LoopX := 0;
  TempObj := Data.ObjCollectibles.Next;
  while TempObj <> Data.ObjEnd do begin
    if TempObj.ID > ID_PlayerMax then begin
      with TempObj do
        Output.WriteString('Objects', IntToStr(LoopX), IntToHex(ID, 2) + '|' + IntToHex(PosX, 3) + '|' + IntToHex(PosY, 4));
      if TempObj.ExtraData <> '' then
        Output.WriteString('Objects', IntToStr(LoopX) + 'Y', TempObj.ExtraData);
      Inc(LoopX);
    end;
    TempObj := TempObj.Next;
  end;
  // Speichern beenden
  Output.Free;
end;

procedure TFormPeterME.DXDrawMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if SelectingTile or SelectingTarget or EditingTiles or WasJustEditingTiles then Exit;
  if (Y < 288) and (X < 576) then begin
    StatusBar.Panels[3].Text := IntToStr(X div 24) + ', ' + IntToStr(Y div 24 + ScrollBar.Position);
    if RadioMapTiles.Checked and (ssLeft in Shift) then begin
      if not (ssShift in Shift) then begin
        if Data.Map.Tiles[X div 24, Y div 24 + Scrollbar.Position] <> SelectedTile then
          Data.Map.Tiles[X div 24, Y div 24 + Scrollbar.Position] := SelectedTile; end
      else
        if (Data.Map.Tiles[X div 24 - 1, Y div 24 - 1 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24,     Y div 24 - 1 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24 + 1, Y div 24 - 1 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24 - 1, Y div 24 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24,     Y div 24 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24 + 1, Y div 24 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24 - 1, Y div 24 + 1 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24,     Y div 24 + 1 + Scrollbar.Position] <> SelectedTile)
        or (Data.Map.Tiles[X div 24 + 1, Y div 24 + 1 + Scrollbar.Position] <> SelectedTile) then begin
          Data.Map.SetTile(X div 24 - 1, Y div 24 - 1 + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24,     Y div 24 - 1 + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24 + 1, Y div 24 - 1 + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24,     Y div 24     + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24 - 1, Y div 24     + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24 + 1, Y div 24     + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24 - 1, Y div 24 + 1 + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24,     Y div 24 + 1 + Scrollbar.Position, SelectedTile);
          Data.Map.SetTile(X div 24 + 1, Y div 24 + 1 + Scrollbar.Position, SelectedTile);
        end;
      UpdateDXDraw;
    end;
  end;
end;

procedure TFormPeterME.CbxSkiesChange(Sender: TObject);
begin
  Data.Map.Sky := Max(0, CbxSkies.ItemIndex);
  Change(nil);
  UpdateDXDraw;
end;

procedure TFormPeterME.SdtPiecesGoalChange(Sender: TObject);
begin
  Data.StarsGoal := SdtPiecesGoal.Value;
  Change(nil);
end;

procedure TFormPeterME.MnuBoxenClick(Sender: TObject);
begin
  MnuBoxen.Checked := not MnuBoxen.Checked;
  UpdateDXDraw;
end;

procedure TFormPeterME.MnuObjektlisteSpeichernClick(Sender: TObject);
var
  TempObj: TPMObject;
  ObjList: TStringList;
begin
  // Objektliste erstellen
  ObjList := TStringList.Create;
  ObjList.Add('PME-Objektliste (zur Verfolgung von Bugs in der internen Objekteorganisation)');
  // Objekte auflisten
  TempObj := Data.ObjCollectibles;
  while TempObj <> nil do if TempObj.ID >= ID_Player then begin
    ObjList.Add('Objekt: ' + Data.Defs[TempObj.ID].Name + ' (ID ' + IntToHex(TempObj.ID, 2) + ')');
    ObjList.Add('PosX: ' + IntToStr(TempObj.PosX) + ', PosY: ' + IntToStr(TempObj.PosY));
    ObjList.Add('VelX: ' + IntToStr(TempObj.VelX) + ', VelY: ' + IntToStr(TempObj.VelY));
    ObjList.Add('ExtraData: ''' + TempObj.ExtraData + ''''); // ''''... einfach zu schön...
    if TempObj.ClassType = TPMLiving then with TPMLiving(TempObj) do
      ObjList.Add('Direction: ' + IntToStr(Direction) + ', Action: ' + IntToStr(Action));
    TempObj := TempObj.Next;
  end else begin
    ObjList.Add('');
    ObjList.Add('*** Platzhalter ' + TempObj.ExtraData);
    ObjList.Add('');
    TempObj := TempObj.Next;
  end;
  // Objektliste speichern und schließen
  ObjList.SaveToFile(ExtractFileDir(ParamStr(0)) + '\PME-Objects.txt');
  ObjList.Free;
end;

procedure TFormPeterME.BtnMoreOptsClick(Sender: TObject);
begin
  if BtnMoreOpts.Caption = '<' then
    BtnMoreOpts.Caption := '>' else BtnMoreOpts.Caption := '<';
  PnlMoreOpts.Visible := (BtnMoreOpts.Caption = '<');
end;

procedure TFormPeterME.SdtLavaPosChange(Sender: TObject);
begin
  HasChanged := True;
  UpdateDXDraw;
end;

procedure TFormPeterME.Change(Sender: TObject);
begin
  HasChanged := True;
end;

procedure TFormPeterME.SetChanged(Value: Boolean);
begin
  Changed := Value;
  if Value = True then StatusBar.Panels[2].Text := 'Verändert'
    else StatusBar.Panels[2].Text := '';
end;

procedure TFormPeterME.FormActivate(Sender: TObject);
begin
  UpdateDXDraw;
end;

procedure TFormPeterME.ShowObjOpts(PMObject: TPMObject);
var
  I: Integer;
begin

  // Altes Objekt speichern
  UpdateOptObj(nil);

  // Neues Objekt laden
  OptObj := PMObject;

  // Kein Objekt ausgewählt?
  if PMObject = nil then begin
    SdtXPos.Enabled := False;
    SdtYPos.Enabled := False;
    SdtXVel.Enabled := False;
    SdtYVel.Enabled := False;
    PnlLivingXData.Visible := False;
    PnlPowerUpXData.Visible := False;
    PnlLeverXData.Visible := False;
    Exit;
  end;

  // Fokus wegpimmeln
  RadioObjects.SetFocus;

  // Richtiges Panel einblenden
  if PMObject.ID in [ID_Enemy..ID_EnemyMax]
    then PnlLivingXData.Visible := True else PnlLivingXData.Visible := False;
  if PMObject.ID in [ID_CollectibleMin..ID_CollectibleMax]
    then PnlPowerUpXData.Visible := True else PnlPowerUpXData.Visible := False;
  if PMObject.ID in [ID_Carolin, ID_Cookie]
    then begin EditHostName.Visible := True;  LabelHostName.Visible := True;  end
    else begin EditHostName.Visible := False; LabelHostName.Visible := False; end;
  if PMObject.ID = ID_Carolin then LabelHostName.Caption := 'Name:';
  if PMObject.ID = ID_Cookie then LabelHostName.Caption := 'Text:';
  if PMObject.ID in [ID_Lever..ID_LeverRight]
    then PnlLeverXData.Visible := True else PnlLeverXData.Visible := False;

  // Ansonsten alle Werte eintragen usw.
  SdtXPos.Enabled := True;
  SdtYPos.Enabled := True;
  SdtXVel.Enabled := True;
  SdtYVel.Enabled := True;
  SdtXPos.Value := PMObject.PosX;
  SdtYPos.Value := PMObject.PosY;
  SdtXVel.Value := PMObject.VelX;
  SdtYVel.Value := PMObject.VelY;
  if PMObject.ID in [ID_Enemy..ID_EnemyMax] then begin
    if Length(PMObject.ExtraData) > 0 then
      CbxJumps.Checked := Boolean(StrToIntDef(PMObject.ExtraData[1], 0))
    else CbxJumps.Checked := False;
    if Length(PMObject.ExtraData) > 2 then
      CbxUseSpecial.Checked := Boolean(StrToIntDef(PMObject.ExtraData[3], 0))
    else CbxUseSpecial.Checked := False;
  end;
  if PMObject.ID in [ID_CollectibleMin..ID_CollectibleMax] then begin
    if Length(PMObject.ExtraData) > 0 then
      CbxFalls.Checked := Boolean(StrToIntDef(PMObject.ExtraData[1], 0))
    else
      CbxFalls.Checked := False;
    if PMObject.ID = ID_Carolin then
      if Length(PMObject.ExtraData) < 3 then EditHostName.Text := 'Carolin'
                                        else EditHostName.Text := Copy(PMObject.ExtraData, 3, Length(PMObject.ExtraData) - 2);
    if PMObject.ID = ID_Cookie then
      if Length(PMObject.ExtraData) < 3 then EditHostName.Text := ''
                                        else EditHostName.Text := Copy(PMObject.ExtraData, 3, Length(PMObject.ExtraData) - 2);
  end;
  if PMObject.ID in [ID_Lever..ID_LeverRight] then begin
    // Überhaupt Zieldaten vorhanden?
    if Length(PMObject.ExtraData) > 0 then begin
      // Herkömmliche Zieldaten? ...
      if PMObject.ExtraData[1] in ['0'..'9', 'A'..'F'] then begin
        SdtLeverTargetNum.Enabled := True;
        BtnLeverTarget.Enabled := True;
        BtnTargetTile.Enabled := True;
        CmbLeverTargets.Enabled := True;
        CmbLeverTargets.Text := '';
        SdtLeverTargetNum.Value := StrToInt('$' + PMObject.ExtraData[1]);
        for I := 1 to SdtLeverTargetNum.Value do
          CmbLeverTargets.Items[I - 1] := Copy(PMObject.ExtraData, 3 + (I - 1) * 10, 9);
      // Oder doch PMScript?
      end else begin
        SdtLeverTargetNum.Enabled := False;
        BtnLeverTarget.Enabled := False;
        BtnTargetTile.Enabled := False;
        CmbLeverTargets.Enabled := False;
      end;
    // Kein Ziel - Standardeinstellungen nehmen
    end else begin
      SdtLeverTargetNum.Enabled := True;
      BtnLeverTarget.Enabled := True;
      BtnTargetTile.Enabled := True;
      CmbLeverTargets.Enabled := True;
      SdtLeverTargetNum.Value := 0;
    end;
  end;
end;

procedure TFormPeterME.UpdateOptObj(Sender: TObject);
var
  I: Integer;
begin
  // Ich bin zu müde, um das sinnvoll auszudrücken... sorry...
  if ((Sender = SdtXPos) or (Sender = SdtYPos)
  or (Sender = SdtXVel) or (Sender = SdtYVel)
  or (Sender = CbxJumps) or (Sender = CbxUseSpecial)
  or (Sender = CbxFalls) or (Sender = SdtLeverTargetNum))
  and (not TWinControl(Sender).Focused) then Exit;
  // Nur, wenn Objekt ausgewählt
  if OptObj = nil then Exit;
  // Blarg.
  Change(nil);
  // Position speichern
  OptObj.PosX := SdtXPos.Value;
  OptObj.PosY := SdtYPos.Value;
  OptObj.VelX := SdtXVel.Value;
  OptObj.VelY := SdtYVel.Value;
  case OptObj.ID of
    ID_Enemy..ID_EnemyMax:
      OptObj.ExtraData := IntToStr(Integer(CbxJumps.Checked)) + '|' + IntToStr(Integer(CbxUseSpecial.Checked));
    ID_CollectibleMin..ID_Carolin - 1, ID_Carolin + 1..ID_Cookie - 1, ID_Cookie + 1..ID_CollectibleMax:
      OptObj.ExtraData := IntToStr(Integer(CbxFalls.Checked));
    ID_Carolin, ID_Cookie: OptObj.ExtraData := IntToStr(Integer(CbxFalls.Checked)) + '|' + EditHostName.Text;
    ID_Lever, ID_LeverLeft, ID_LeverRight:
      if (Length(OptObj.ExtraData) < 1) or (OptObj.ExtraData[1] in ['0'..'9', 'A'..'F']) then begin
        OptObj.ExtraData := IntToHex(SdtLeverTargetNum.Value, 1);
        for I := 1 to SdtLeverTargetNum.Value do
          OptObj.ExtraData := OptObj.ExtraData + '|' + CmbLeverTargets.Items[I - 1];
      end;
  else
    OptObj.ExtraData := '';
  end;
  // Neu malen (sicher ist sicher!)
  UpdateDXDraw;
end;

procedure TFormPeterME.MnuBeendenClick(Sender: TObject);
begin Close; end;

procedure TFormPeterME.MnuSpielenClick(Sender: TObject);
var
  SUI: TStartUpInfo;
  PrI: TProcessInformation;
begin
  if (SDlgLevel.FileName = '') or (Changed = True) then begin MessageDlg('Level muss erst gespeichert werden.', mtInformation, [mbOk], 0); Exit; end;
  ZeroMemory(@SUI, SizeOf(SUI));
  SUI.cb := SizeOf(SUI);
  CreateProcess(PChar(ExtractFileDir(ParamStr(0)) + '\PeterM.exe'), PChar('"' + ExtractFileDir(ParamStr(0)) + '\PeterM.exe" "' + SDlgLevel.FileName + '"'), nil, nil, False, Normal_Priority_Class, nil, nil, SUI, PrI);
  WaitForSingleObject(PrI.hProcess, Infinite);
  Windows.SetFocus(Application.Handle);
  UpdateDXDraw;
end;

procedure TFormPeterME.SdtLeverTargetNumChange(Sender: TObject);
begin
  while CmbLeverTargets.Items.Count > SdtLeverTargetNum.Value do begin
    CmbLeverTargets.Items.Delete(CmbLeverTargets.Items.Count - 1);
    CmbLeverTargets.ItemIndex := -1; CmbLeverTargets.Text := '';
  end;
  while CmbLeverTargets.Items.Count < SdtLeverTargetNum.Value do
    CmbLeverTargets.Items.Add('00|000|00');
  UpdateOptObj(SdtLeverTargetNum);
end;

procedure TFormPeterME.BtnLeverTargetClick(Sender: TObject);
begin
  if CmbLeverTargets.ItemIndex > -1 then begin
    SelectingTarget := True;
    PnlProperties.Enabled := False;
    MnuDatei.Enabled := False;
    MnuAnderes.Enabled := False;
    UpdateDXDraw;
  end else MessageDlg('Du musst erst ein Ziel in der Liste auswählen!', mtInformation, [mbOk], 0);
end;

procedure TFormPeterME.BtnTargetTileClick(Sender: TObject);
begin
  if CmbLeverTargets.ItemIndex > -1 then begin
    SelectingTile := True;
    PnlProperties.Enabled := False;
    MnuDatei.Enabled := False;
    MnuAnderes.Enabled := False;
    ScrollBar.Enabled := False;
    ScrollBarTiles.Visible := True;
    UpdateDXDraw;
  end else MessageDlg('Du musst erst ein Ziel in der Liste auswählen!', mtInformation, [mbOk], 0);
end;

procedure TFormPeterME.MnuInfoClick(Sender: TObject);
var
  ObjCount, ObjStuckCount, StarsCount: Integer;
  TempObj: TPMObject;
begin
  ObjCount := 0; ObjStuckCount := 0; StarsCount := 0;
  TempObj := Data.ObjCollectibles;
  while TempObj <> Data.ObjEnd do begin
    Inc(ObjCount);
    if TempObj.ID >= ID_Player then begin
      if TempObj.Stuck then Inc(ObjStuckCount);
    end;
    if TempObj.ID in [ID_Star..ID_Star3] then Inc(StarsCount);
    TempObj := TempObj.Next;
  end;
  MessageDlg('"' + EdtMapName.Text + '" enthält ' + IntToStr(ObjCount) + ' Objekte, davon stecken '
             + IntToStr(ObjStuckCount) + ' fest und ' + IntToStr(StarsCount) + ' sind Sterne.'
             + #13#10'Autor des Levels ist ' + MapAuthor + '.' , mtInformation, [mbOk], 0);
end;

procedure TFormPeterME.BtnLeverScriptClick(Sender: TObject);
begin
  if (Length(OptObj.ExtraData) < 2) or (OptObj.ExtraData[1] <> 'X') then
    OptObj.ExtraData := 'X|' + InputBox('Skripteingabe', 'Gib das Skript ein, das der Hebel ausführen soll.', '')
  else
    OptObj.ExtraData := 'X|' + InputBox('Skripteingabe', 'Gib das Skript ein, das der Hebel ausführen soll.', Copy(OptObj.ExtraData, 3, Length(OptObj.ExtraData) - 2));
  if OptObj.ExtraData = 'X|' then OptObj.ExtraData := '';
  ShowObjOpts(OptObj);
  Change(nil);
end;

procedure TFormPeterME.SetTimer(Sender: TObject);
var
  Which: Integer;
begin
  Which := 0;
  if Sender = MnuTimer0 then Which := 0; if Sender = MnuTimer1 then Which := 1;
  if Sender = MnuTimer2 then Which := 2; if Sender = MnuTimer3 then Which := 3;
  if Sender = MnuTimer4 then Which := 4; if Sender = MnuTimer5 then Which := 5;
  if Sender = MnuTimer6 then Which := 6; if Sender = MnuTimer7 then Which := 7;
  if Sender = MnuTimer8 then Which := 8; if Sender = MnuTimer9 then Which := 9;
  if Sender = MnuTimerX then Which := 10;
  if Which < 10 then Data.Map.ScriptTimers[Which] := InputBox('Timer-Skript ' + IntToStr(Which) + ' ändern', 'Gib das Timer-Skript ein.', Data.Map.ScriptTimers[Which])
                else Data.Map.ScriptTimers[Which] := InputBox('Timer-Skript X ändern', 'Gib das Timer-Skript ein.', Data.Map.ScriptTimers[Which]);
  RefreshTimerMenus;
  Change(nil);
end;

procedure TFormPeterME.RefreshTimerMenus;
begin
  MnuTimer0.Caption := '0: ' + Data.Map.ScriptTimers[0]; MnuTimer1.Caption := '1: ' + Data.Map.ScriptTimers[1];
  MnuTimer2.Caption := '2: ' + Data.Map.ScriptTimers[2]; MnuTimer3.Caption := '3: ' + Data.Map.ScriptTimers[3];
  MnuTimer4.Caption := '4: ' + Data.Map.ScriptTimers[4]; MnuTimer5.Caption := '5: ' + Data.Map.ScriptTimers[5];
  MnuTimer6.Caption := '6: ' + Data.Map.ScriptTimers[6]; MnuTimer7.Caption := '7: ' + Data.Map.ScriptTimers[7];
  MnuTimer8.Caption := '8: ' + Data.Map.ScriptTimers[8]; MnuTimer9.Caption := '9: ' + Data.Map.ScriptTimers[9];
  MnuTimerX.Caption := 'X: ' + Data.Map.ScriptTimers[10]; 
end;

procedure TFormPeterME.SdtLevelTopChange(Sender: TObject);
begin
  Change(nil);
  UpdateDXDraw;
end;

procedure TFormPeterME.DXDrawMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  WasJustEditingTiles := False;
end;

procedure TFormPeterME.FormShow(Sender: TObject);
begin
  // Fenster setzen und so
  ClientWidth := 600 + ScrollBar.Width;
  ScrollBar.Left := 600;
  ScrollBarTiles.Left := 600;
end;

procedure TFormPeterME.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin ScrollBar.Position := ScrollBar.Position + 2; end;

procedure TFormPeterME.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin ScrollBar.Position := ScrollBar.Position - 2; end;

procedure TFormPeterME.EditHostNameChange(Sender: TObject);
begin
  UpdateOptObj(nil);
  if EditHostName.Modified then UpdateDXDraw;
end;

procedure TFormPeterME.MnuSpeichern2Click(Sender: TObject);
begin
  SDlgLevel.FileName := '';
  MnuSpeichernClick(nil);
end;

procedure TFormPeterME.MnuAuthorClick(Sender: TObject);
begin
  MapAuthor := InputBox('Autoreninfo ändern', 'Neue Autoreninfo:', MapAuthor);
  Change(nil);
end;

procedure TFormPeterME.MnuLavaScoreClick(Sender: TObject);
begin
  MnuLavaScore.Checked := not MnuLavaScore.Checked;
  Change(nil);
end;

procedure TFormPeterME.MnuThemeClick(Sender: TObject);
var
  LoopT: Integer;
begin
  if MessageDlg('Bei der Umwandlung gehen alle überladenen Tiles verloren. Fortfahren?', mtWarning, [mbYes, mbNo], 0) = mrNo then Exit;
  if not ODlgTheme.Execute then Exit;
  for LoopT := 0 to 255 do  TileOverload[LoopT] := '';
  MapTheme := ExtractFileName(ODlgTheme.FileName);
  MapTheme := Copy(MapTheme, 1, Length(MapTheme) - 4);
  MnuAktualisierenClick(nil);
  UpdateDXDraw;
  Change(nil);
end;

procedure TFormPeterME.CmbLeverTargetsClick(Sender: TObject);
begin
  UpdateDXDraw;
end;

function TFormPeterME.FillWithChar(OldString: string; NewLength: Integer; FillChar: Char): string;
var
  LoopX: Integer;
  IsNegative: Boolean;
begin
  if OldString[1] = '-' then begin
    IsNegative := True;
    OldString := Copy(OldString, 2, Length(OldString) - 1);
  end else IsNegative := False;
  Result := OldString;
  for LoopX := 1 to NewLength - Length(OldString) do Result := FillChar + Result;
  if IsNegative then Result[1] := '-';
end;

end.
