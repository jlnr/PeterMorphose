# TODO translate to Ruby

=begin
State_Credits: begin
  if not (DXDraw.CanDraw and Application.Active) then Exit;
  DXImageList.Items[Image_TitleDark].Draw(DXDraw.Surface, 0, 0, 0);

  DrawBMPText('Spielidee, Programmierung, Grafiken, Sounds', 100,  40, 192, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Julian Raschke, julian@raschke.de',           200,  80, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('http://www.petermorphose.de/',                200, 100, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Zus‰tzliche Sounds und Himmel',               100, 140, 192, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Sandro Mascia, xxsgrrs-@gmx.de',              200, 160, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Sebastian Ludwig, usludwig@t-online.de',      200, 180, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Sˆren Bevier, soeren.bevier@dtp-isw.de',      200, 200, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Sebastian Burkhart, buggi@buggi.com',         200, 220, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Florian Groﬂ, flgr@gmx.de',                   200, 240, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Holger Biermann, kaiserbiddy@web.de',         200, 260, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Musik',                                       100, 300, 192, DXImageList.Items[Image_Font], DXDraw.Surface, 1);
  DrawBMPText('Steffen Wenz, s.wenz@t-online.de',            200, 340, 255, DXImageList.Items[Image_Font], DXDraw.Surface, 1);

  DrawBMPText('Willst du zur¸ck zum Hauptmen¸, dr¸cke Escape.', 113, 435, 0, DXImageList.Items[Image_Font], DXDraw.Surface, 0);
  DXDraw.Flip;
end;
=end