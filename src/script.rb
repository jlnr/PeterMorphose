module PMScript
  def letter_to_object letter
    letter == 'P' ? player : obj_vars[letter.to_i(16)]
  end
  
  def convert_sound_name name
    case name.downcase
    when /^(.*)Collect/ then
      "collect_#{$1}"
    when "jeepee" then
      "yippie"
    when "stairsrnd" then
      "stairs_steps"
    when "swordwoosh" then
      "sword_whoosh"
    when "blockerbreak" then
      "blocker_break"
    when "arrowhit" then
      "arrow_hit"
    else
      if (sound("#{name.downcase}2") rescue nil) then
        "#{name.downcase}1"
      else
        name.downcase
      end
    end
  end
  
  def shortcut_to_message shortcut
    case shortcut
    when 'ex' then :existence_as_int
    when 'px' then :x
    when 'py' then :y
    when 'vx' then :vx
    when 'vy' then :vy
    when 'id' then :pmid
    when 'lf' then :life
    when 'ac' then :action
    when 'dr' then :direction
    end
  end
  
  def get_var var
    case var
    when /^var(.)$/ then
      map.vars[$1.to_i(16)]
    when /\?(...)/ then
      rand($1.to_i(16) + 1)
    when /^\$(.)(..)/ then
      receiver = letter_to_object($1)
      message = shortcut_to_message($2)
      receiver.send(message)
    when 'keys' then keys
    when 'ammo' then ammo
    when 'bomb' then bombs
    when 'star' then stars
    when 'scor' then score
    
    when 'time' then time_left
    when 'tspd' then speed_time_left
    when 'tjmp' then jump_time_left
    when 'tfly' then fly_time_left
    
    when 'lpos' then map.lava_pos
    when 'lspd' then map.lava_speed
    when 'lmod' then map.lava_mode
    else
      throw "Getting unknown variable #{var}"
    end
  end
  
  def set_var var, value
    case var
    when /^var(.)$/ then
      map.vars[$1.to_i(16)] = value
    when /^\$(.)(..)/ then
      receiver = letter_to_object($1)
      message = shortcut_to_message($2)
      receiver.send "#{message}=", value
    when 'keys' then self.keys = value
    when 'ammo' then self.ammo = value
    when 'bomb' then self.bombs = value
    when 'star' then self.stars = value
    when 'scor' then self.score = value
    
    when 'time' then self.time_left = value
    when 'tspd' then self.speed_time_left = value
    when 'tjmp' then self.jump_time_left = value
    when 'tfly' then self.fly_time_left = value
    
    when 'lpos' then map.lava_pos = value
    when 'lspd' then map.lava_speed = value
    when 'lmod' then map.lava_mode = value
    else
      throw "Setting unknown variable #{var}"
    end
  end
  
  def evaluate_param param
    if param.length == 5 then
      evaluate_param(param[1..-1]) * (param[0, 1] == '-' ? -1 : +1)
    else
      if param =~ /[0-9A-Fa-f]{4}/ then
        param.to_i(16)
      else
        get_var param
      end
    end
  end
  
  def evaluate_condition condition
    return true if condition == 'always'
    left_var  = evaluate_param(condition[0, 4])
    right_var = evaluate_param(condition[5, 4])
    
    case condition[4, 1]
    when '=' then return left_var == right_var
    when '!' then return left_var != right_var
    when '<' then return left_var < right_var
    when '>' then return left_var > right_var
    when '"' then return (left_var - right_var).abs <= 16
    when "'" then return (left_var - right_var).abs >  16
    when '{' then return left_var <= right_var
    when '}' then return left_var >= right_var
    else
      "Unknown comparison: #{condition[4, 1]}"
    end
  end
  
  def execute_command command, caller
    return if command.empty?
    
    if command[0, 1] == '_' then
      # Magic condition repeat - return if last condition was false
      return if not @last_cond
      action = command[1..-1]
    elsif not command =~ /^#{caller}\(/ then
      # Wrong caller - counts as false condition
      @last_cond = false
      return
    else
      # Evaluate conditions
      @last_cond = true
      
      conditions = command[/\([^)]*\)/]
      conditions = conditions[1..-2].split('&')
      @last_cond = conditions.all? &method(:evaluate_condition)
      return if not @last_cond
      action = command[(command.index('):') + 2)..-1]
    end
    
    case action
    when /^set (....) (.....)$/ then
      set_var $1, evaluate_param($2)
    when /^add (....) (.....)$/ then
      set_var $1, get_var($1) + evaluate_param($2)
    when /^mul (....) (.....)$/ then
      set_var $1, get_var($1) * evaluate_param($2)
    when /^div (....) (.....)$/ then
      set_var $1, get_var($1) / evaluate_param($2)
    when /^kill \$(.)$/ then
      letter_to_object($1).kill rescue nil
    when /^mapsolid (....) (....) (....)$/ then
      set_var $1, (map.solid?(evaluate_param($2), evaluate_param($3)) ? 1 : 0)
    when /^hit \$(.)$/ then
      letter_to_object($1).hit rescue nil
    when /^hurt \$(.)$/ then
      letter_to_object($1).hurt rescue nil
    when /^createobject (....) (....) (....) (..)$/ then
      obj = create_object(evaluate_param($1), evaluate_param($2), evaluate_param($3), '')
      obj_vars[$4[1, 1].to_i(16)] = obj unless $4 == 'no'
    when /^setxd \$(.) (.*)$/ then
      letter_to_object($1).xdata = $2
    when /^message (.*)$/ then
      @message_text = t($1)
      @message_opacity = 255
    when /^message2 (.*)$/ then
      @message_text = t($1).gsub(/\^..../) { |term| evaluate_param(term[1..-1]) }
      @message_opacity = 255
    when /^sound (.*)$/ then
      sound(convert_sound_name($1)).play
    when /^casteffects (....) (....) (....) (....) (....)$/ then
      cast_fx evaluate_param($1), evaluate_param($2), evaluate_param($3),
        evaluate_param($4), evaluate_param($5), TILE_SIZE, TILE_SIZE, 0, 0, 5
    when /^casteffects2 (....) (....) (....) (....) (....) (....) (.....) (.....) (....)$/ then
      cast_fx evaluate_param($1), evaluate_param($2), evaluate_param($3),
        evaluate_param($4), evaluate_param($5), evaluate_param($6), evaluate_param($7),
        evaluate_param($8), evaluate_param($9), evaluate_param($10)
    when /^changetile (....) (....) (....)$/ then
      map[evaluate_param($1), evaluate_param($2)] = evaluate_param($3)
    when /^explosion (....) (....) (....)$/ then
      explosion evaluate_param($1), evaluate_param($2), evaluate_param($3)
    when /^find \$(.) (....) (....) (....) (....) (....) (....)$/
      obj_vars[$1.to_i(16)] = find_object evaluate_param($2), evaluate_param($3),
        ObjectDef::Rect.new(evaluate_param($4), evaluate_param($5), evaluate_param($6), evaluate_param($7))
    else
      throw "Don't know how to #{action}"
    end
  end
  
  def execute_script script, caller
    return if script.nil? or script.empty?
    
    @cond = true
    script.split('\\').each { |command| execute_command command, caller }
  end
end
