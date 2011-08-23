class LevelInfo
  attr_accessor :filename, :title, :ini_file
  
  def initialize filename
    @filename = filename
    @ini_file = INIFile.new(filename)
    @title       = t(@ini_file['Info', 'Title']  || 'Unbenannte Karte')
    @difficulty  = t(@ini_file['Info', 'Skill']  || '')
    @description = t(@ini_file['Info', 'Desc']   || '')
    @author      =  (@ini_file['Info', 'Author'] || '')
    
    stars_goal = (@ini_file['Map', 'StarsGoal'] || 100).to_i
    if stars_goal == 0 then
      @goal = t "Durchkommen"
    else
      @goal = "#{stars_goal} #{t 'Sterne einsammeln'}"
    end
    
    hostages = []
    obj = 0
    while obj_desc = @ini_file['Objects', obj] do
      if obj_desc[0, 2] == ('%02X' % ID_CAROLIN) then
        obj_desc_extended = @ini_file['Objects', "#{obj}Y"] || '|'
        hostages << (obj_desc_extended.split('|').last || 'Carolin')
      end
      obj += 1
    end
    if hostages.size == 1 then
      @goal += " #{t 'und'} #{hostages[0]} #{t 'retten'}"
    elsif hostages.size > 1 then
      @goal += " #{t 'und'} #{hostages.size} #{t 'Gefangene retten'}"
    end
    
    # TODO highscore = ...
  end
  
  def draw y, active
    if active then
      draw_rect 0, y + 1, 631, 98, 0xff603000
    end
    
    draw_rect 0, y, 631, 1, 0x003000
    # TODO (Highscore) / (not beaten yet)
    draw_string @title, 5, y + 7, 255
    draw_right_aligned_string @difficulty, 626, y + 7, 255
    draw_string @description, 5, y + 30, 192
    draw_string @goal, 5, y + 53, 128
    draw_string @author, 5, y + 76, 80
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
