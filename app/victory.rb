class Victory < State
  # case Data.State of
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
end
