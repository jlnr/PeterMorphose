# TODO convert to Ruby or not
=begin
State_Options: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Optionsmen¸ (Seite 1)', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Musik', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if PseudoMusic = 0 then DrawBMPText('<aus>', 575, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if PseudoMusic = 1 then DrawBMPText('<ein>', 575, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Schaltet die Musik ein oder aus. (Benˆtigt Peter-Neustart.)', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if SelectedOptionItem = 0 then DXDraw.Surface.FillRectAdd(Bounds(0, 60, 640, 16), $004896);

  DrawBMPText('Blut und Schreie', 20, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if Data.OptBlood = 0 then DrawBMPText('<aus>', 575, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                       else DrawBMPText('<ein>', 575, 120, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Schaltet Blut an und aus. Viele finden, dass es nicht zum Spiel', 20, 140, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('passt. Aber manche kˆnnen ja gar nicht ohne leben...', 20, 160, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if SelectedOptionItem = 1 then DXDraw.Surface.FillRectAdd(Bounds(0, 120, 640, 16), $004896);

  DrawBMPText('Positionsanzeige im Spiel', 20, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if Data.OptShowStatus = 0 then DrawBMPText('<aus>', 575, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                            else DrawBMPText('<ein>', 575, 200, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Blendet im Spiel links eine Leiste zur besseren Orientierung ein.', 20, 220, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if SelectedOptionItem = 2 then DXDraw.Surface.FillRectAdd(Bounds(0, 200, 640, 16), $004896);

  DrawBMPText('Behebung des Rosa-R‰nder-Problems', 20, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if Data.OptATI = 0 then DrawBMPText('<aus>', 575, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0)
                     else DrawBMPText('<ein>', 575, 260, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('Einschalten, wenn Grafiken in Hilfe oder Editor rosa R‰nder haben.', 20, 280, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if SelectedOptionItem = 3 then DXDraw.Surface.FillRectAdd(Bounds(0, 260, 640, 16), $004896);

  DrawBMPText('Seite 1      Seite 2', 230, 340, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if SelectedOptionItem = 4 then DXDraw.Surface.FillRectAdd(Bounds(220, 340, 83, 16), $004896);

  DrawBMPText('W‰hle mit den Pfeiltasten "oben" und "unten" aus, was du ‰ndern willst', 3, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('und ‰ndere den Wert mit "links" und "rechts". Zur¸ck mit "Escape".', 12, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;

State_Options2: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Optionsmen¸ (Seite 2)', 20, 20, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);

  DrawBMPText('Grafikqualit‰t', 20, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if Data.OptQuality = 0 then DrawBMPText('<schlecht>', 530, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if Data.OptQuality = 1 then DrawBMPText('<standard>', 530, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  if Data.OptQuality = 2 then DrawBMPText('<sehr gut>', 530, 60, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('ƒndert die Grafikqualit‰t. Bei ''schlecht'' fehlen ein paar Effekte,', 20, 80, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('bei ''sehr gut'' kommen ein paar neue (¸bertriebene) hinzu.', 20, 100, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
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

  DrawBMPText('W‰hle mit den Pfeiltasten "oben" und "unten" aus, was du ‰ndern willst', 3, 424, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DrawBMPText('und ‰ndere den Wert mit "links" und "rechts". Zur¸ck mit "Escape".', 12, 446, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
=end
