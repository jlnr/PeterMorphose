class GameObject < Struct.new(:game, :pmid, :x, :y, :xdata, :vx, :vy)
  def initialize *args
    super *args
    @last_frame_in_water = in_water?
  end
  
  MAX_SOUND_DISTANCE = 500.0
  
  def emit_sound name
    distance = (y - game.player.y).abs
    return if distance > MAX_SOUND_DISTANCE
    sound(name).play 1 - distance / MAX_SOUND_DISTANCE
  end
  
  ALL_WATER_TILES = (TILE_WATER..TILE_WATER_4).to_a + [TILE_WATER_5]
  def in_water?
    ALL_WATER_TILES.include? game.map[x / TILE_SIZE, y / TILE_SIZE]
  end
  
  def update
    if [ID_FIREWALL_1, ID_FIREWALL_2, ID_FIRE].include? pmid then
      #   if PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom - 11 > Data.Map.LavaPos then begin CastFX(4, 4, 0, PosX, PosY, 16, 16, 0, -3, 1, Data.OptEffects, Data.ObjEffects); Kill; DistSound(PosY, Sound_Shshsh, Data^); end;
      #   ExtraData := IntToStr(Abs((Round(Data.Frame * 7.5) mod 256) - 128));
      #   BurnObj := Data.ObjEnemies;
      #   while BurnObj <> Data.ObjEffects do begin
      #     if PointInRect(Point(BurnObj.PosX, BurnObj.PosY), GetRect(0, 0)) and (BurnObj.ID <> ID_EnemyBerserker) and not (TPMLiving(BurnObj).Action in [Act_Dead, Act_InvUp, Act_InvDown]) then begin
      #       TPMLiving(BurnObj).Hurt(False);
      #       CastFX(Random(3), Random(2), 0, PosX, PosY, 12, 12, 0, 0, 2, Data.OptEffects, Data.ObjEffects);
      #     end;
      #     BurnObj := BurnObj.Next;
      #   end;
      return
    end
    
    # Hint arrows
    if pmid == ID_HELP_ARROW and
      false then #PointInRect(Point(Data.ObjPlayers.Next.PosX, Data.ObjPlayers.Next.PosY), Bounds(PosX - 11, PosY + 12, 24, 48)) then Kill;
      kill
    end
    
    # Fish
    # if ID = ID_Fish then begin
    #   if not InWater then begin Fall; CheckTile; end else begin
    #     Dec(PosX, 2);
    #     if Random(30) = 0 then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 3, 0, 0);
    #     if Blocked(Dir_Left) then ID := ID_Fish2;
    #   end;
    # end else if ID = ID_Fish2 then begin
    #   if not InWater then begin Fall; CheckTile; end else begin
    #     Inc(PosX, 2);
    #     if Random(30) = 0 then TPMEffect.Create(Data.ObjEffects, '', ID_FXWaterbubble, PosX, PosY - 3, 0, 0);
    #     if Blocked(Dir_Right) then ID := ID_Fish;
    #   end;
    # end;
    
    # Fused bomb
    # if ID = ID_FusingBomb then begin
    #   // Nach ner Weile hochgehen
    #   ExtraData := IntToStr(StrToIntDef(ExtraData, 0) + 1);
    #   if ExtraData = '25' then begin
    #     Kill;
    #     Explosion(PosX, PosY, 50, Data^, True);
    #     Exit;
    #   end;
    #   // Bei Gegnerkontakt auch
    #   BurnObj := Data.ObjEnemies;
    #   while BurnObj <> Data.ObjPlayers do begin
    #     if BurnObj.RectCollision(GetRect(1, 1)) and not (TPMLiving(BurnObj).Action in [Act_Dead, Act_InvUp, Act_InvDown]) then begin
    #       TPMLiving(BurnObj).Hurt(True);
    #       Kill;
    #       Explosion(PosX, PosY, 50, Data^, True);
    #       Exit;
    #     end;
    #     BurnObj := BurnObj.Next;
    #   end;
    #   // Fallen und so
    #   Fall; CheckTile;
    # end;
    
    # Rocks fall down
    if (ID_TRASH..ID_TRASH_4).include? pmid then
      fall
      check_tile
    end
    
    # Get roasted by lava
    if y + ObjectDefs[pmid].bottom > map.lava_pos then
      # TODO CastFX(4, 4, 0, PosX, PosY, 16, 16, 0, -3, 1, Data.OptEffects, Data.ObjEffects);
      kill
      emit_sound :shshsh
    end
  end
  
  def fall
    # // Wasserplatsch machen
    # if InWater and not LastFrameInWater then begin
    #   CastObjects(ID_FXWater, 5, -VelX div 2, -5, 3, Data.OptEffects, GetRect(1, 1), Data.ObjEffects);
    #   DistSound(PosY, Sound_Water + Random(2), Data^);
    # end;
    # LastFrameInWater := InWater;
    
    self.vy += 1 if (pmid > ID_PLAYER_MAX or game.fly_time_left == 0) and not in_water?
    
    if in_water? then
      self.vy -= 1 if vy > 1
      self.vy += 1 if vy < 1
      self.vx -= 1 if vx > 2
      self.vx += 1 if vx < 2
    end
    
    # Velocity is limited to +- TILE_SIZE
    self.vx = [[vx, -TILE_SIZE].max, TILE_SIZE].min
    self.vy = [[vy, -TILE_SIZE].max, TILE_SIZE].min
    
    if vy > 0 then
      vy.times do
        break if blocked? DIR_DOWN
        self.y += 1
      end
    elsif vy < 0 then
      vy.abs.times do
        break if blocked? DIR_UP
        self.y -= 1
      end
    end
    
    if blocked? DIR_DOWN then
      if is_a? LivingObject and vx > 10 and not [ACT_DEAD, ACT_ACTION, ACT_ACTION_2].include? action then
        self.action = ACT_IMPACT_1 + [vy - 11, 4].min
      end
      self.vy = 0
      # Conveyor belts are neither implemented nor used
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullLeft) and (not Blocked(Dir_Left)) then Dec(PosX);
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullRight) and (not Blocked(Dir_Right)) then Inc(PosX);
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullLeft) and (not Blocked(Dir_Left)) then Dec(PosX);
      # if (Data.Map.Tile(PosX + Data.Defs[ID].Rect.Left + Data.Defs[ID].Rect.Right, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) = Tile_PullRight) and (not Blocked(Dir_Right)) then Inc(PosX);
    end
    
    if blocked? DIR_UP and game.fly_time_left == 0 then
      self.vy /= -2
      self.vx /= +2
    end
    
    if vx < 0 then
      vx.abs.times do
        if blocked? DIR_LEFT then
          self.vx = 0
          break
        else
          self.x -= 1
        end
      end
    elsif vx > 0 then
      vx.times do
        if blocked? DIR_RIGHT then
          self.vx = 0
          break
        else
          self.x += 1
        end
      end
    end
    
    if (pmid > ID_PLAYER_MAX or game.fly_time_left == 0) and blocked? DIR_DOWN then
      self.vx -= 1 if vx >  0
      self.vx -= 1 if vx > +1
      self.vx -= 1 if pmid <= ID_ENEMY_MAX and vx > +ObjectDef[pmid].speed
      self.vx += 1 if vx <  0
      self.vx += 1 if vx < -1
      self.vx += 1 if pmid <= ID_ENEMY_MAX and vx < -ObjectDef[pmid].speed
      # TODO Slime tiles
      #       if Data.Map.Tile(PosX, PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom + 1) in [Tile_Slime..Tile_Slime3] then begin
      #         if VelX > 0 then Dec(VelX); if VelX > 1 then Dec(VelX);
      #         if (ID <= ID_EnemyMax) and (VelX > +Data.Defs[ID].Speed) then Dec(VelX);
      #         if VelX < 0 then Inc(VelX); if VelX < -1 then Inc(VelX);
      #         if (ID <= ID_EnemyMax) and (VelX < -Data.Defs[ID].Speed) then Inc(VelX);
      #         if VelX > 0 then Dec(VelX); if VelX > 1 then Dec(VelX);
      #         if (ID <= ID_EnemyMax) and (VelX > +Data.Defs[ID].Speed) then Dec(VelX);
      #         if VelX < 0 then Inc(VelX); if VelX < -1 then Inc(VelX);
      #         if (ID <= ID_EnemyMax) and (VelX < -Data.Defs[ID].Speed) then Inc(VelX);
      #         if Data.Frame mod 2 = 0 then begin
      #           if VelX > 0 then Dec(VelX); if VelX > 1 then Dec(VelX);
      #           if (ID <= ID_EnemyMax) and (VelX > +Data.Defs[ID].Speed) then Dec(VelX);
      #           if VelX < 0 then Inc(VelX); if VelX < -1 then Inc(VelX);
      #           if (ID <= ID_EnemyMax) and (VelX < -Data.Defs[ID].Speed) then Inc(VelX);
      #         end;
      #       end;
      #     end;
    end
    
    # Annoying Special FX
    # if (Data.OptQuality = 2) and ((Abs(VelX) > 12) or (VelY < -15)) then
    #   CastFX(Random(5), Random(3), 0, PosX, PosY, 5, 5, 0, -2, 2, Data.OptEffects, Data.ObjEffects);
    # end;
  end
  
  def blocked? direction
    rect = ObjectDef[pmid].rect
    case direction
    when DIR_LEFT then
      game.map.solid? x + rect.left - 1, y + rect.top or
      game.map.solid? x + rect.left - 1, y + rect.bottom
    when DIR_RIGHT then
      game.map.solid? x + rect.right + 1, y + rect.top or
      game.map.solid? x + rect.right + 1, y + rect.bottom
    when DIR_UP then
      game.map.solid? x + rect.left,  y + rect.top - 1 or
      game.map.solid? x + rect.right, y + rect.top - 1
    when DIR_DOWN then
      game.map.solid? x + rect.left,  y + rect.bottom + 1 or
      game.map.solid? x + rect.right, y + rect.bottom + 1
    end
  end
  
  protected
  
  def check_tile
    case game.map[x / TILE_SIZE, y / TILE_SIZE]
    when TILE_AIR_ROCKET_UP, TILE_AIR_ROCKET_UP_2, TILE_AIR_ROCKET_UP_3 then
      emit_sound :turbo
      #   Fling(0, -20, 0, True, False);
      #   if not Blocked(Dir_Up) then Dec(PosY);
      #   PosX := PosX div 24 * 24 + 11;
      #   if (ID >= ID_Enemy) and (ID <= ID_EnemyMax) then VelX := RealDir(TPMLiving(Self).Direction);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, 0, -10, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketUpLeft: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   if not Blocked(Dir_Up) then Dec(PosY);
      #   Fling(-10, -15, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, -8, -8, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketUpRight: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   if not Blocked(Dir_Up) then Dec(PosY);
      #   Fling(10, -15, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, +8, -8, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketLeft: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   Fling(-20, 2, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, -10, 0, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketRight: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   Fling(20, -2, 0, True, False);
      #   PosY := PosY div 24 * 24 + 11;
      #   for I := 0 to 23 do if Stuck then Dec(PosY);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, +10, 0, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_AirRocketDown: begin
      #   DistSound(PosY, Sound_Turbo, Data^);
      #   Fling(0, 15, 0, True, False);
      #   PosX := PosX div 24 * 24 + 11;
      #   if (ID >= ID_Enemy) and (ID <= ID_EnemyMax) then VelX := RealDir(TPMLiving(Self).Direction);
      #   CastFX(0, 0, 10, PosX, PosY, 24, 24, 0, 8, 1, Data.OptEffects, Data.ObjEffects);
      # end;
      # Tile_SlowRocketUp: begin
      #   CastFX(0, 0, 1, PosX, PosY, 24, 24, 0, -2, 1, Data.OptEffects, Data.ObjEffects);
      #   VelX := VelX div 2;
      #   Dec(VelY, 4);
      #   if (ID >= ID_Enemy) and (ID <= ID_EnemyMax) then VelX := RealDir(TPMLiving(Self).Direction);
      #   if Self.ClassType = TPMLiving then
      #     TPMLiving(Self).Action := Act_Jump;
      # end;
      # // Stacheln
      # Tile_Spikes:
      #   if (ID <= ID_LivingMax) and (((PosY + Data.Defs[ID].Rect.Top + Data.Defs[ID].Rect.Bottom) mod 24) > 8) then begin
      #     TPMLiving(Self).Hit; VelY := -10; VelX := 0;
      #   end;
      # // Stacheln an der Decke
      # Tile_SpikesTop:
      #   if (ID <= ID_LivingMax) and (((PosY + Data.Defs[ID].Rect.Top) mod 24) < 14) then begin
      #     TPMLiving(Self).Hit; VelY := 5; VelX := 0;
      #   end;
    end
  end  
end

# TODO split into proper classes

=begin
  // Peter-Morphose-Grundobjekt mit all seinen Eigenschaften
  TPMObject = class(TObject)
  public
    Data: ^TPMData;
    Next, Last: TPMObject;
    ID, PosX, PosY, VelX, VelY: Integer;
    ExtraData: string;
    LastFrameInWater: Boolean;
    Marked: Boolean;
    constructor Create(After: TPMObject; XData: string; InitID, X, Y, VX, VY: Integer);
    procedure Draw; virtual;
    procedure Update; virtual;
    procedure Kill;
    procedure ReallyKill;
    procedure Fall;
    procedure CheckTile;
    procedure Fling(XLvl, YLvl, Rnd: Integer; Fixed, Malign: Boolean);
    function Blocked(Dir: Integer): Boolean;
    function RectCollision(Rect: TRect): Boolean;
    function GetRect(ExtraWidth: Integer = 0; ExtraHeight: Integer = 0): TRect;
    function Stuck: Boolean;
    function InWater: Boolean;
  end;

procedure DrawBMPText(Text: string; X, Y: Integer; Alpha: Byte; SrcPic: TPictureCollectionItem; DestSrf: TDirectDrawSurface; Quality: Integer);
procedure MyStretchDraw(DestSrf: TDirectDrawSurface; SrcPic: TPictureCollectionItem; Pattern: Integer; DestRect: TRect; ATI: Boolean);
procedure CastFX(SmokeNum, FlameNum, SparkNum, X, Y, Width, Height, XLvl, YLvl, Rnd, Level: Integer; FXObj: TPMObjBreak);
procedure CastObjects(ID, Number, XLvl, YLvl, Rnd, Level: Integer; Rect: TRect; After: TPMObjBreak);
procedure Explosion(X, Y, Radius: Integer; Data: TPMData; DoScore: Boolean);
procedure DistSound(Y, Sound: Integer; Data: TPMData);
function CreateObject(DataObj: TPMData; XData: string; InitID, X, Y, VX, VY: Integer): TPMObject;
function FindObject(StartObj, EndObj: TPMObject; MinID, MaxID: Integer; Rect: TRect): TPMObject;
function FindLiving(StartObj, EndObj: TPMObject; MinID, MaxID, MinAction, MaxAction: Integer; Rect: TRect): TPMLiving;
function LaunchProjectile(X, Y, Direction: Integer; TargetMinObj, TargetMaxObj, FXObj: TPMObject; Data: TPMData): TPMObject;

implementation

procedure TPMObject.Draw;
begin
  case ID of
    ID_FireWall1, ID_FireWall2, ID_Fire:
      Data.Images[Image_Stuff].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - Data.ViewPos - 11, 24, 24), ID - ID_OtherObjectsMin, 128 + StrToIntDef(ExtraData, 128));
    ID_HelpArrow:
      Data.Images[Image_Stuff].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - Data.ViewPos - 11, 24, 24), ID - ID_OtherObjectsMin, 128 + ((Data.Frame div 8) mod 2) * 64);
    ID_Speed, ID_Jump, ID_Fly:
      Data.Images[Image_Stuff].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - Data.ViewPos - 11, 24, 24), ID - ID_OtherObjectsMin, 255);
  else
    Data.Images[Image_Stuff].Draw(Data.DXDraw.Surface, PosX - 11, PosY - Data.ViewPos - 11, ID - ID_OtherObjectsMin);
  end;
  if ID = ID_Carolin then begin
    if Length(ExtraData) < 3 then DrawBMPText('Carolin', PosX - 31, PosY + 16 - Data.ViewPos, 128, Data.FontPic, Data.DXDraw.Surface, Data.OptQuality)
                             else DrawBMPText(Copy(ExtraData, 3, Length(ExtraData) - 2), PosX - ((Length(ExtraData) - 2) * 9) div 2, PosY + 16 - Data.ViewPos, 128, Data.FontPic, Data.DXDraw.Surface, Data.OptQuality);
  end;
end;

procedure TPMObject.Kill;
var
  I: Integer;
begin
  // Argh
  Marked := True;
  for I := 0 to 15 do
    if Data.ObjVars[I] = Self then Data.ObjVars[I] := nil;
end;

procedure TPMObject.ReallyKill;
begin
  // Jawollja
  Next.Last := Last;
  Last.Next := Next;
  Free;
end;


procedure TPMObject.Fling(XLvl, YLvl, Rnd: Integer; Fixed, Malign: Boolean);
begin
  // Wehrlose Objekte nur, wenn Malign=False
  if (ID <= ID_PlayerMax) and (Malign = True) and ((Data.InvTimeLeft > 0) or (ID = ID_PlayerBerserker))then Exit;
  // Zufall + 1
  Inc(Rnd);
  // Schleudern
  if Fixed then begin
    VelX := XLvl + Random(Rnd); VelY := YLvl + Random(Rnd);
  end else begin
    Inc(VelX, XLvl + Random(Rnd));
    Inc(VelY, YLvl + Random(Rnd));
  end;
end;

function TPMObject.RectCollision(Rect: TRect): Boolean;
begin
  Result := OverlapRect(Bounds(PosX + Data.Defs[ID].Rect.Left,
                               PosY + Data.Defs[ID].Rect.Top,
                               Data.Defs[ID].Rect.Right,
                               Data.Defs[ID].Rect.Bottom), Rect);
end;

function TPMObject.GetRect(ExtraWidth: Integer = 0; ExtraHeight: Integer = 0): TRect;
begin
  Result := Bounds(PosX + Data.Defs[ID].Rect.Left - ExtraWidth,
                   PosY + Data.Defs[ID].Rect.Top - ExtraHeight,
                   Data.Defs[ID].Rect.Right + ExtraWidth * 2,
                   Data.Defs[ID].Rect.Bottom + ExtraHeight * 2)
end;

function TPMObject.Stuck: Boolean;
begin with Data^ do begin
  Result := Map.Solid(PosX + Defs[ID].Rect.Left,
                      PosY + Defs[ID].Rect.Top)
         or Map.Solid(PosX + Defs[ID].Rect.Left + Defs[ID].Rect.Right,
                      PosY + Defs[ID].Rect.Top)
         or Map.Solid(PosX + Defs[ID].Rect.Left,
                      PosY + Defs[ID].Rect.Top  + Defs[ID].Rect.Bottom)
         or Map.Solid(PosX + Defs[ID].Rect.Left + Defs[ID].Rect.Right,
                      PosY + Defs[ID].Rect.Top  + Defs[ID].Rect.Bottom)
end; end;

procedure TPMEffect.Draw;
begin
  case ID of
    ID_FXSmoke:
      Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), Max(0,  Phase -  1), 128);
    ID_FXFlame:
      Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), Max(7,  Phase +  6), 160);
    ID_FXSpark:
      Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), Max(14, Phase + 13), 128);
    ID_FXBubble:
      Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), Max(21, Phase + 20), 192);
    ID_FXRicochet:
      Data.Images[Image_Effects].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 19 + StrToInt(ExtraData), Min((255 - Phase) * 3, 255));
    ID_FXLine:
      Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX, PosY - 11 - Data.ViewPos, StrToInt(ExtraData), 24), 28, 255 - Phase);
    ID_FXBlockerParts:
      Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 29, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
    ID_FXBreak:
      Data.Images[Image_Effects].DrawSub(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 30, Phase);
    ID_FXBreak2:
      Data.Images[Image_Effects].DrawSub(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 31, Phase);
    ID_FXBreakingParts:
      Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 32, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
    ID_FXBlood:
      Data.Images[Image_Effects].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 33, 250 - Phase);
    ID_FXFire:
      Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX, PosY - Data.ViewPos, 24, 24), 34, Phase);
    ID_FXFlyingCarolin:
      Data.Images[Image_Effects].Draw(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 35);
    ID_FXFlyingChain:
      Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 36, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
    ID_FXFlyingBlob:
      Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 37, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
    ID_FXWaterBubble:
      Data.Images[Image_Effects].DrawAlpha(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 46, 100 + Random(29));
    ID_FXWater:
      Data.Images[Image_Effects].DrawRotateAlpha(Data.DXDraw.Surface, PosX, PosY - Data.ViewPos, 24, 24, 47, 0.5, 0.5, (PosX * 10) mod 256, 255 - Phase);
    ID_FXSparkle:
      Data.Images[Image_Effects].DrawAdd(Data.DXDraw.Surface, Bounds(PosX - 11, PosY - 11 - Data.ViewPos, 24, 24), 48, 255 - Phase);
    ID_FXText, ID_FXSlowText:
      DrawBMPText(ExtraData, Min(Max(PosX - Round(Length(ExtraData) * 4.5), 0), 576 - Length(ExtraData) * 9), PosY - 7 - Data.ViewPos, 255 - Phase, Data.FontPic, Data.DXDraw.Surface, Data.OptQuality);
  end;
end;

procedure TPMEffect.Update;
begin
  case ID of
    ID_FXSmoke, ID_FXFlame: begin
      Inc(PosX, VelX);
      Inc(PosY, VelY);
      Inc(Phase);
      if Phase > 7 then begin Kill; Exit; end;
    end;
    ID_FXSpark: begin
      Inc(PosX, VelX);
      Inc(PosY, VelY);
      if Data.Frame mod 3 = 0 then Inc(Phase);
      if Phase > 5 then begin Kill; Exit; end;
    end;
    ID_FXBubble: begin
      Inc(PosX, VelX);
      PosY := Data.Map.LavaPos - 12;
      if Data.Frame mod 2 = 0 then Inc(Phase);
      if Phase > 7 then begin Kill; Exit; end;
    end;
    ID_FXBlockerParts: begin
      Inc(PosX, VelX);
      Inc(PosY, VelY);
      Inc(VelY);
      Inc(Phase, 15);
      if Phase = 255 then begin Kill; Exit; end;
    end;
    ID_FXWater: begin
      Inc(PosX, VelX);
      Inc(VelY);
      Inc(PosY, VelY);
      Inc(Phase, 25);
      if Phase = 250 then begin Kill; Exit; end;
    end;
    ID_FXBreak, ID_FXBreak2: begin
      Inc(Phase, 15);
      if Phase = 255 then begin
        Data.Map.Tiles[PosX div 24, PosY div 24] := Tile_Hole + (((PosY div 24) mod 2 + PosX div 24) mod 2) * 16;
        CastObjects(ID_FXBreakingParts, 20, 0, 5, 2, Data.OptEffects, Bounds(PosX div 24 * 24, PosY div 24 * 24, 24, 24), Data.ObjEffects);
        DistSound(PosY, Sound_Break + Random(2), Data^);
        Kill; Exit;
      end;
    end;
    ID_FXFire: begin
      Inc(Phase, 15);
      if Phase = 255 then begin
        Data.Map.Tiles[PosX div 24, PosY div 24] := Tile_BigBlockerBroken;
        Explosion(PosX + 12, PosY + 12, 30, Data^, True);
        Kill; Exit;
      end;
    end;
    ID_FXBreakingParts, ID_FXText, ID_FXRicochet, ID_FXLine, ID_FXBlood, ID_FXFlyingChain, ID_FXFlyingBlob: begin
      Inc(PosX, VelX);
      Inc(PosY, VelY);
      Inc(Phase, 15);
      if Phase = 255 then Kill;
    end;
    ID_FXSlowText: begin
      Inc(PosX, VelX);
      Inc(PosY, VelY);
      Inc(Phase, 5);
      if Phase = 255 then Kill;
    end;
    ID_FXFlyingCarolin: begin
      Inc(PosX, VelX);
      Inc(PosY, VelY);
      if PosY < Data.ViewPos - Data.OptEffectsDistance then Kill;
    end;
    ID_FXWaterBubble: begin
      Dec(PosY);
      if Random(4) = 0 then PosX := PosX - 1 + Random(3);
      if not InWater then Kill;
    end;
    ID_FXSparkle: begin
      Inc(Phase, 25);
      if Phase = 250 then Kill;
    end;
  end;
end;

///////////////////////
// Andere Funktionen //
///////////////////////

procedure CastFX(SmokeNum, FlameNum, SparkNum, X, Y, Width, Height, XLvl, YLvl, Rnd, Level: Integer; FXObj: TPMObjBreak);
var
  Loop: Integer;
begin
  // Nicht, wenn zu weit weg (CYCLEZ R B R0X)
  if Abs(Y - FXObj.Data.ObjPlayers.Next.PosY) > FXObj.Data.OptEffectsDistance then Exit;
  // Rauch
  if Round(SmokeNum / 100 * Level) > 0 then for Loop := 1 to Max(Round(SmokeNum / 100 * Level), 1) do
    TPMEffect.Create(FXObj, '', ID_FXSmoke,
                     Min(Max(X - Width div 2 + Random(Width + 1), 0), 575),
                     Y - Height div 2 + Random(Height + 1), XLvl - Rnd + Random(Rnd * 2 + 1), YLvl - Rnd + Random(Rnd * 2 + 1));
  // Flammen
  if Round(FlameNum / 100 * Level) > 0 then for Loop := 1 to Max(Round(FlameNum / 100 * Level), 1) do
    TPMEffect.Create(FXObj, '', ID_FXFlame,
                     Min(Max(X - Width div 2 + Random(Width + 1), 0), 575),
                     Y - Height div 2 + Random(Height + 1), XLvl - Rnd + Random(Rnd * 2 + 1), YLvl - Rnd + Random(Rnd * 2 + 1));
  // Flammen
  if Round(SparkNum / 100 * Level) > 0 then for Loop := 1 to Max(Round(SparkNum / 100 * Level), 1) do
    TPMEffect.Create(FXObj, '', ID_FXSpark,
                     Min(Max(X - Width div 2 + Random(Width + 1), 0), 575),
                     Y - Height div 2 + Random(Height + 1), XLvl - Rnd + Random(Rnd * 2 + 1), YLvl - Rnd + Random(Rnd * 2 + 1));
end;

procedure CastObjects(ID, Number, XLvl, YLvl, Rnd, Level: Integer; Rect: TRect; After: TPMObjBreak);
var
  Loop: Integer;
begin
  if Round(Number / 100 * Level) > 0 then for Loop := 0 to Round(Number / 100 * Level) do
    case ID of
      ID_OtherObjectsMin..ID_OtherObjectsMax:
        TPMObject.Create(After, '', ID, Rect.Left + Random(Rect.Right - Rect.Left + 1), Rect.Top + Random(Rect.Bottom - Rect.Top + 1), XLvl - Rnd + Random(Rnd * 2 + 1), YLvl - Rnd + Random(Rnd * 2 + 1));
      ID_FXMin..ID_FXMax:
        TPMEffect.Create(After, '', ID, Rect.Left + Random(Rect.Right - Rect.Left + 1), Rect.Top + Random(Rect.Bottom - Rect.Top + 1), XLvl - Rnd + Random(Rnd * 2 + 1), YLvl - Rnd + Random(Rnd * 2 + 1));
    end;
end;

procedure Explosion(X, Y, Radius: Integer; Data: TPMData; DoScore: Boolean);
var
  I, R, P: Integer;
  TempObj: TPMObject;
begin
  // SAUNT KRACH BUM RLOZLRZORZLRzrozrzrlrRZrol
  DistSound(Y, Sound_Explosion, Data);
  // Effekte machen n stuff
  if Data.OptEffects > 0 then for I := 0 to (Data.OptEffects + 3) div 3 do begin
    R := Random(360);
    P := Random(6) + 6;
    TPMEffect.Create(Data.ObjEffects, '', ID_FXSmoke + Random(2), X, Y, Round(Sin(R) * Radius / P), Round(Cos(R) * Radius / P));
  end;
  // Alle Lebewesen puttmachen MAIN GOT SCHAISE ARME FIECHER :((((888
  TempObj := Data.ObjEnemies.Next;
  while TempObj <> Data.ObjEffects do begin
    if (TempObj.ClassType = TPMLiving) and (TPMLiving(TempObj).Action < Act_Dead) then begin
      if Sqrt(Power(Abs(X - TempObj.PosX), 2) + Power(Abs(Y - TempObj.PosY), 2)) <= (Radius / 3) then TPMLiving(TempObj).Hurt(True)
        else if Sqrt(Power(Abs(X - TempObj.PosX), 2) + Power(Abs(Y - TempObj.PosY), 2)) <= Radius then TPMLiving(TempObj).Hit;
      if DoScore and (TempObj.ID in [ID_Enemy..ID_EnemyMax]) and (TPMLiving(TempObj).Action = Act_Dead) then begin
        Inc(Data.Score, Data.Defs[TempObj.ID].Life * 3);
        TPMEffect.Create(Data.ObjEffects, IntToStr(Data.Defs[TempObj.ID].Life * 3) + ' Punkte!', ID_FXText, TempObj.PosX, TempObj.PosY - 10, 0, -1);
      end;
    end;
    TempObj := TempObj.Next;
  end;
  // Und jetze noch f0l Kisten büm´zen =))99
  for I := (X - Radius) div 24 to (X + Radius) div 24 do
    for P := (Y - Radius) div 24 to (Y + Radius) div 24 do begin
      if (Sqrt(Power(Abs(X div 24 - I), 2) + Power(Abs(Y div 24 - P), 2)) < Radius / 24)
        and (Data.Map.Tile(I * 24, P * 24) in [Tile_BigBlocker, Tile_BigBlocker2])
          and (FindObject(Data.ObjEffects, Data.ObjEnd, ID_FXFire, ID_FXFire, Bounds(I * 24 - 1, P * 24 - 1, 2, 2)) = nil) then
            TPMEffect.Create(Data.ObjEffects, '', ID_FXFire, I * 24, P * 24, 0, 0);
      if Data.Map.Tile(I * 24, P * 24) in [Tile_Blocker..Tile_Blocker3] then begin
        if Data.Map.Tile(I * 24, P * 24) in [Tile_Blocker, Tile_Blocker2]
          then Data.Map.Tiles[I, P] := Tile_BlockerBroken
          else Data.Map.Tiles[I, P] := Tile_Blocker3Broken;
        CastObjects(ID_FXBlockerParts, 10, 0, -2, 5, Data.OptEffects, Bounds(I * 24, P * 24, 24, 24), Data.ObjEffects);
        DistSound(Y, Sound_BlockerBreak, Data);
      end;
      if Data.Map.Tile(I * 24, P * 24) = Tile_BigBlocker3 then begin
        Data.Map.SetTile(I, P, 0);
        DistSound(Y, Sound_Break + Random(2), Data);
        CastObjects(ID_FXBreakingParts, 20, 0, 3, 3, Data.OptEffects, Bounds(I * 24, P * 24, 24, 24), Data.ObjEffects);
      end;
    end;
end;

function CreateObject(DataObj: TPMData; XData: string; InitID, X, Y, VX, VY: Integer): TPMObject;
begin case InitID of
  0..ID_LivingMax:
    Result := TPMLiving.Create(DataObj.ObjEnemies, XData, InitID, X, Y, VX, VY, DataObj.Defs[InitID].Life, 0, Random(2));
  ID_OtherObjectsMin..ID_OtherObjectsMax:
    Result := TPMObject.Create(DataObj.ObjOther, XData, InitID, X, Y, VX, VY);
  ID_CollectibleMin..ID_CollectibleMax:
    Result := TPMCollectible.Create(DataObj.ObjCollectibles, XData, InitID, X, Y, VX, VY);
  ID_FXMin..ID_FXMax:
    Result := TPMEffect.Create(DataObj.ObjEffects, XData, InitID, X, Y, VX, VY);
  else
    Result := nil;
end; end;

function FindObject(StartObj, EndObj: TPMObject; MinID, MaxID: Integer; Rect: TRect): TPMObject;
var
  TempObj: TPMObject;
begin
  Result := nil;
  TempObj := StartObj;
  while True do begin
    TempObj := TempObj.Next;
    if TempObj = EndObj then Exit;
    if (TempObj.ID in [MinID..MaxID])
      and PointInRect(Point(TempObj.PosX, TempObj.PosY), Rect) then begin Result := TempObj; Exit; end;
  end;
end;

function FindLiving(StartObj, EndObj: TPMObject; MinID, MaxID, MinAction, MaxAction: Integer; Rect: TRect): TPMLiving;
var
  TempObj: TPMObject;
begin
  Result := nil;
  TempObj := StartObj;
  while True do begin
    TempObj := TempObj.Next;
    if TempObj = EndObj then Exit;
    if (TempObj.ClassType = TPMLiving)
    and (TempObj.ID in [MinID..MaxID])
    and (TPMLiving(TempObj).Action in [MinAction..MaxAction])
    and PointInRect(Point(TempObj.PosX, TempObj.PosY), Rect) then begin Result := TPMLiving(TempObj); Exit; end;
  end;
end;

function LaunchProjectile(X, Y, Direction: Integer; TargetMinObj, TargetMaxObj, FXObj: TPMObject; Data: TPMData): TPMObject;
var
  LoopX: Integer;
  TempObj: TPMObject;
begin
  Result := nil; // noch nix gefunden
  LoopX := X;    // Suchpunkt: Noch der Ursprung
  DistSound(Y, Sound_Bow, Data);
  while (Result = nil) and (LoopX > 2) and (LoopX < 573) do begin
    if Data.Map.Solid(LoopX, Y) then begin
      Result := nil;
      TPMEffect.Create(FXObj, IntToStr(Direction), ID_FXRicochet, LoopX div 24 * 24 + 24 * Integer(not(Boolean(Direction))) - 6 * RealDir(Direction), Y - 1 + Random(3), 0, 0);
      TPMEffect.Create(FXObj, IntToStr(Abs(X - LoopX)), ID_FXLine, Min(X, LoopX), Y, 0, 0);
      DistSound(Y, Sound_ArrowHit, Data);
      Exit;
    end;
    TempObj := TargetMinObj;
    while TempObj <> TargetMaxObj do
      if TempObj.RectCollision(Rect(LoopX, Y - 2, LoopX + 8, Y + 2))
      and ((TempObj.ClassType <> TPMLiving) or (not (TPMLiving(TempObj).Action in [Act_Dead, Act_InvUp, Act_InvDown]))) then begin
        Result := TempObj;
        TPMEffect.Create(FXObj, IntToStr(Direction), ID_FXRicochet, LoopX - 6 * RealDir(Direction), Y - 1 + Random(3), 0, 0);
        TPMEffect.Create(FXObj, IntToStr(Abs(X - LoopX)), ID_FXLine, Min(X, LoopX), Y, 0, 0);
        DistSound(Y, Sound_ArrowHit, Data);
        Exit;
      end else
        TempObj := TempObj.Next;
    Inc(LoopX, 4 * RealDir(Direction));
  end;
  TPMEffect.Create(FXObj, IntToStr(Abs(X - LoopX)), ID_FXLine, Min(X, LoopX), Y, 0, 0);
end;

=end
