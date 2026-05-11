# TODO translate to Ruby
=begin
State_ReadMe1: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Willkommen bei Peter Morphose!', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Hier findest du die Erkl‰rung des Spielprinzips, der Steuerung und', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
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
  DrawBMPText('Escape:                     Wieder zum Hauptmen¸', 20, 340, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('(Gamepad funktioniert nicht im Men¸.)', 20, 360, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 1 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
State_ReadMe2: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Weitere Tipps zur Steuerung:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('ï Nur der normale Peter kann Hebel umlegen (Spezialaktion). Wenn du', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('  ein Spezialpeter bist und einen Hebel umlegen willst, musst du', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('  dich erst zur¸ckverwandeln (Enter/B4).', 20, 100, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('ï Im Sprung kannst du die Flugrichtung ein wenig mit Links/Rechts', 20, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('  beeinflussen.', 20, 140, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('ï Wenn du getroffen wirst, bist du f¸r etwa eine Sekunde transparent', 20, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('  und unverwundbar. Nutze die Zeit, um aus dem Get¸mmel zu entkommen!.', 20, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Ziel des Spiels ist es, durch die jeweils letzte nach oben f¸hrende', 20, 220, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Treppe des Levels zu gehen. Wenn du genug Sterne hast, hast du das', 20, 240, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Level geschafft. In vielen Runden muss man unterwegs auch eine oder', 20, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('mehrere Geiseln retten (ber¸hren), um gewinnen zu kˆnnen. Das Ziel', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('einer Runde siehst du vor dem Spielen im Levelauswahlbildschirm.', 20, 300, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Was dich daran hindert, durch das Level zu kommen, ist vor allem', 20, 320, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('die Lava, die unerbittlich steigt und alles auf ihrem Wege toastet.', 20, 340, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Aber auch einige Gegner und R‰tsel stehen dir im Weg...', 20, 360, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 2 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
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
  DrawBMPText('Ritterpeter ist stabiler und tr‰ger als Peter. Er kann daf¸r', 80, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('mit dem Schwert zuschlagen (Leertaste/B2).', 80, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num * 5, Bounds(20, 150, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Das ist Flitzebogenpeter. Er kann auf der Leertaste schieﬂen,', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('verbraucht allerdings Munition.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num * 9, Bounds(20, 200, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Der Bombenlegerpeter kann Bomben werfen (Leertaste) und damit', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Gegner bek‰mpfen und Sprengstoffkisten explodieren lassen.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DXImageListPack.Items[Image_Effects].DrawAdd(DXDraw.Surface, Bounds(20, 250, 48, 48), 8, 192);
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Player], Act_Num * 7, Bounds(20, 250, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Feuerpeter hat keine Spezialaktion. Er ist beinahe', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('unverwundbar und kann Gegner durch Ber¸hrung tˆten.', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MunitionBomber2 - 16, Bounds(10, 300, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MunitionGun2 - 16, Bounds(20, 310, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Pfeile sind Munition f¸r den Flitzebogenpeter, Bomben f¸r', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Bombenlegerpeter.', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 3 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
State_ReadMe4: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Die 5 verschiedenen Gegner:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], 0, Bounds(580, 50, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Kinderschrecks sind schwache, schnelle Gegner und meistens', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('keine groﬂe Gefahr.', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 3 + Act_Action4, Bounds(580, 100, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Tempelw‰chter sind zwar langsam, halten aber mehr Schl‰ge aus', 20, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('als Kinderschrecks.', 20, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 8, Bounds(580, 150, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Diese schnellen Gegner explodieren bei Kontakt mit Peter und', 20, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('ziehen ihm so viel Energie ab. Gef‰hrlich!', 20, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 4, Bounds(580, 200, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Bogenbayern lauern meistens an schwer erreichbaren Orten und', 20, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('schieﬂen auf Peter, sobald sie ihn sehen.', 20, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DXImageListPack.Items[Image_Effects].DrawAdd(DXDraw.Surface, Bounds(580, 255, 48, 48), 7, 192);
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Enemies], Act_Num * 7, Bounds(580, 250, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Diese brennende Unholden lassen sich am besten aus der Distanz', 20, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('besiegen. Kontakt meiden!', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 4 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
State_ReadMe5: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Die wichtigsten Objekte:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Carolin - 16, Bounds(20, 50, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Eine arme Gefangene. Muss durch Ber¸hrung gerettet werden.', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Stirbt sie, ist das Spiel sofort verloren!', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Key - 16, Bounds(20, 100, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Manche T¸ren kann man nur ˆffnen, wenn man noch einen', 80, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Schl¸ssel ¸brig hat.', 80, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Star - 16, Bounds(15, 140, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Star2 - 16, Bounds(20, 150, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Star3 - 16, Bounds(25, 160, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Diese Sterne m¸ssen meistens in einer bestimmten Anzahl', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('eingesammelt werden, damit man die Runde schaffen kann.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Health - 16, Bounds(25, 195, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_EdibleFish2 - 16, Bounds(20, 210, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Kleine Beeren f¸llen eine Energie auf, groﬂe vier. Rote', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Fische f¸llen immer nur eine Energie auf.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MorphFighter - 16, Bounds(20, 250, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Morphobjekte verwandeln Peter in den abgebildeten', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Spezialpeter (hier: Ritterpeter).', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MoreTime - 16, Bounds(25, 295, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_MoreTime2 - 16, Bounds(15, 310, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Groﬂe und kleine Uhren geben ein paar Sekunden mehr', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Spezialpeterzeit.', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 5 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
State_ReadMe6: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Weitere wichtige Objekte:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Lever - 16, Bounds(25, 40, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_LeverRight - 16, Bounds(25, 90, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Hebel und Schalter kann nur der normale Peter umlegen', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('(Leertaste). Sie ver‰ndern normalerweise etwas an der', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Spielwelt (Spezialteil erscheint, Mauer verschwindet,', 80, 100, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Hilfsobjekte werden erschaffen...', 80, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_SlowDown - 16, Bounds(25, 145, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Crystal - 16, Bounds(15, 165, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Sanduhren machen die Lava dauerhaft langsamer, Kristalle', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('frieren sie wenige Sekunden lang ein.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Fly - 16, Bounds(20, 200, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Mit diesen Fl¸geln kann Peter fliegen, bis sie vollst‰ndig', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('verblasst sind.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Jump - 16, Bounds(27, 242, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Speed - 16, Bounds(13, 258, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Siebenmeilenstiefel lassen Peter eine Weile schneller', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('laufen, Adlerstiefel hˆher springen.', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points6 - 16, Bounds(28, 318, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points - 16, Bounds(5, 290, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points5 - 16, Bounds(5, 315, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points2 - 16, Bounds(25, 290, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points4 - 16, Bounds(15, 300, 48, 48), Boolean(Data.OptATI));
  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Stuff], ID_Points3 - 16, Bounds(20, 310, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Diese Objekte machen nichts Anderes als Punkte zu geben.', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Nur einsammeln, wenn du zu viel Zeit hast!', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 6 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
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
  DrawBMPText('Diese T¸ren lassen sich nur ˆffnen, wenn man einen Schl¸ssel', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('dabei hat.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Blocker, Bounds(20, 205, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Lassen sich mit Ritterpeter zerschlagen und mit Bombenleger-', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('peter zerbomben.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_BigBlocker, Bounds(20, 255, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Kann mit einer Bombe angez¸ndet werden. Explodiert dann und', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('kann dabei auch weitere Kisten anz¸nden... Kettenreaktion!', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Bridge2, Bounds(20, 305, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Diese alten, verwitterten Steinmauern fangen an, zu zer-', 80, 310, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('brˆseln, sobald ein Lebewesen draufl‰uft.', 80, 330, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 7 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
State_ReadMe8: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Mehr Spezialkartenteile:', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_BigBlocker3, Bounds(20, 55, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('L‰sst sich auch zersprengen, explodiert aber nicht', 80, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('selbst, im Gegensatz zu Sprengstoffkisten.', 80, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Slime2, Bounds(20, 105, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Auf diesem klebrigen Schleim kann Peter nur sehr', 80, 110, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('langsam laufen und nicht hoch springen.', 80, 130, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_StairsUp, Bounds(20, 155, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Geht man in eine solche T¸r, kommt man aus der n‰chsten', 80, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('T¸r in Richtung des Pfeiles raus. Kann verschlossen sein.', 80, 180, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_AirRocketUp2, Bounds(20, 205, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('L‰uft man an diesen Kartenteilen vorbei, schleudern sie', 80, 210, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('den Spieler in die angezeigte Richtung.', 80, 230, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  MyStretchDraw(DXDraw.Surface, DXImageListPack.Items[Image_Tiles], Tile_Spikes, Bounds(20, 255, 48, 48), Boolean(Data.OptATI));
  DrawBMPText('Diese Stacheln sind unangenehm f¸r Gegner und Spieler.', 80, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Manchmal auch an der Decke zu finden.', 80, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('So, und jetzt noch viel Gl¸ck und Spaﬂ beim Spielen von', 80, 335, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Peter Morphose!', 230, 360, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Mit den Pfeiltasten kannst du in der Hilfe bl‰ttern. (Seite 8 von 8)', 14, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Auf Escape kommst du zum Hauptmen¸ zur¸ck.', 131, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
=end
