class Object
  %w(up down left right).each do |direction|
    kb_id = Gosu.const_get("Kb#{direction.capitalize}")
    gp_id = Gosu.const_get("Gp#{direction.capitalize}")
    define_method "#{direction}?" do |id|
      id == kb_id or id == gp_id
    end
    
    define_method "#{direction}_pressed?" do
      $window.button_down? kb_id or $window.button_down? gp_id
    end
  end
end

def confirmation? id
  id == Gosu::KbReturn or id == Gosu::KbEnter or
  id == Gosu::KbSpace or id == Gosu::GpButton0
end

def action? id
  id == Gosu::KbSpace or id == Gosu::GpButton1
end

def cancel? id
  id == Gosu::KbEscape or id == Gosu::GpButton2
end
