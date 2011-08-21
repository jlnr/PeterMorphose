unit PMMaps;

interface

uses
  Windows, Classes, DXClass, PMConst;

type
  TPMMap = class
    Tiles: array[0..23, 0..1023] of Byte;
    Scripts: array[0..1023] of string;
    ScriptTimers: array[0..10] of string;
    ScriptVars: array[0..15] of Integer;
    LavaPos, LavaFrame, LavaTimeLeft, LavaScore,
      Sky, LavaSpeed, LavaMode, LevelTop: Integer;
    procedure Clear;
    procedure SetTile(X, Y, Tile: Integer);
    function Solid(X, Y: Integer): Boolean;
    function Tile(X, Y: Integer): Byte;
    function StairsEnd(X, Y: Integer): Boolean;
  end;

implementation

procedure TPMMap.Clear;
var
  X, Y: Integer;
begin
  for Y := 0 to 1023 do begin
    for X := 0 to 23 do Tiles[X, Y] := 0;
    Scripts[Y] := '';
  end;
  for X := 0 to 10 do ScriptTimers[X] := '';
  for X := 0 to 15 do ScriptVars[X] := 0;
end;

procedure TPMMap.SetTile(X, Y, Tile: Integer);
begin
  if PointInRect(Point(X, Y), Bounds(0, 0, 23, 1023)) then Tiles[X, Y] := Tile;
end;

function TPMMap.Solid(X, Y: Integer): Boolean;
begin
  if (Y > LavaPos) and (LavaTimeLeft > 0) then begin Result := True; Exit; end; 
  if (Tile(X, Y) >= $70) and (Tile(X, Y) < $E0) then Result := True else Result := False;
end;

function TPMMap.Tile(X, Y: Integer): Byte;
begin
  if PointInRect(Point(X, Y), Rect(0, LevelTop, 575, 24575)) then Result := Tiles[X div 24, Y div 24] else Result := $70;
end;

function TPMMap.StairsEnd(X, Y: Integer): Boolean;
begin
  // Normalerweise False
  Result := False;
  // Fall A: Geht nach unten
  if Tiles[X, Y] in [Tile_StairsDown, Tile_StairsDown2] then
    while True do begin
      Inc(Y);
      if Y > 1023 then begin Result := False; Exit; end;
      if Tiles[X, Y] in [Tile_StairsUp, Tile_StairsUp2, Tile_StairsEnd, Tile_StairsEnd2] then
        begin Result := True; Exit; end;
    end;
  // Fall B: Geht nach oben
  if Tiles[X, Y] in [Tile_StairsUp, Tile_StairsUp2] then
    while True do begin
      Dec(Y);
      if Y < LevelTop div 24 then begin Result := False; Exit; end;
      if Tiles[X, Y] in [Tile_StairsDown, Tile_StairsDown2, Tile_StairsEnd, Tile_StairsEnd2] then
        begin Result := True; Exit; end;
    end;
end;

end.
