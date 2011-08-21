class LevelInfo
  attr_accessor :filename, :title
    
  def initialize filename
    @filename = filename
    ini = INIFile.new(filename, %w(Info Objects))
    @title       = ini['Info', 'Title']  || 'Unbenannte Karte'
    @difficulty  = ini['Info', 'Skill']  || ''
    @description = ini['Info', 'Desc']   || ''
    @author      = ini['Info', 'Author'] || '(Anonym)'
    
    stars_goal = (ini['Info', 'StarsGoal'] || 100).to_i
    if stars_goal == 0 then
      @goal = "Durchkommen"
    else
      @goal = "#{stars_goal} Sterne einsammeln"
    end
    
    hostages = []
    obj = 0
    while obj_desc = ini['Objects', obj] do
      if obj_desc[1..2] == ID_CAROLIN.to_s(16) then
        obj_desc_extended = ini['Objects', "#{obj}Y"] || '|'
        hostages << (obj_desc_extended.split('|').last || 'Carolin')
      end
      obj += 1
    end
    if hostages.size == 1 then
      @goal += " und #{hostages[0]} Gefangene retten"
    elsif hostages.size > 1 then
      @goal += " und #{hostages.size} Gefangene retten"
    end
    
    # TODO highscore = ...
  end
    
  def draw y, active
    if active then
      draw_rect 0, y + 1, 631, 98, 0xff603000
    end
    
    draw_rect 0, y, 631, 1, 0x003000
    # TODO (Highscore) / (noch nicht geschafft)
    draw_string @title, 5, y + 7, 255
    # TODO right-align
    draw_string @difficulty, 626 - @difficulty.length * 9, y + 7, 255
    draw_string @description, 5, y + 30, 192
    draw_string @goal, 5, y + 53, 128
    draw_string "Von #{@author}", 5, y + 76, 80
    draw_rect 0, y + 99, 631, 1, 0x006000
  end
  
  FIRST_LEVEL = 'jr_Gemuetlicher_Aufstieg.pml'
  
  def <=> other
    if File.basename(self.filename) == FIRST_LEVEL then
      -1
    elsif File.basename(other.filename) == FIRST_LEVEL then
      +1
    else
      title <=> other.title
    end
  end
end
