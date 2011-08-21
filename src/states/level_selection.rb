class LevelSelection < State
  def initialize
    @title = Gosu::Image.new 'media/title_dark.png'
    @top = 0
    @selection = 0
    @levels = Dir.glob('levels/*.pml').map &LevelInfo.method(:new)
  end
  
  def draw
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
    
  end
  
  def button_down(id)
    #     if Data.State in [State_LevelSelection, State_Credits, State_ReadMe1..State_ReadMe8] then begin
    #       DXWaveList.Items[Sound_WooshBack].Play(False);
    #       Data.State := State_MainMenu;
    #       Exit;
    #     end;
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
    
  end
  
end
