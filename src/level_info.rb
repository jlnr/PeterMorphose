class LevelInfo
  attr_accessor :title, :author, :description
  attr_accessor :difficulty, :stars_goal, :hostage, :hostage_name
  attr_accessor :highscore
  
  def draw y, active, font
  end
end

# TODO translate more

=begin

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
  Hiscore := DeMuesli(Ini.ReadString('Hiscore', ExtractFileName(ExtractShortPathName(Location)), 'Ung¸ltig :('));
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

function LevelComp(Item1, Item2: Pointer): Integer;
begin
  if TPMLevelInfo(Item1).Title = TPMLevelInfo(Item2).Title then begin Result := 0; Exit; end;
  if TPMLevelInfo(Item1).Title = 'Gem¸tlicher Aufstieg' then begin Result := -1; Exit; end;
  if TPMLevelInfo(Item2).Title = 'Gem¸tlicher Aufstieg' then begin Result := +1; Exit; end;
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

=end
