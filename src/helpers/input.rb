CONTROLS = {
  :menu_prev => [:KbUp, :GpUp, :KbLeft, :GpLeft],
  :menu_next => [:KbDown, :GpDown, :KbRight, :GpRight],
  :menu_confirm => [:KbEnter, :KbReturn, :KbSpace, :GpButton0],
  :menu_cancel => [:KbEscape, :GpButton2],
  
  :up => [:KbUp, :GpUp],
  :down => [:KbDown, :GpDown],
  :left => [:KbLeft, :GpLeft],
  :right => [:KbRight, :GpRight],
  :jump => [:KbUp, :GpButton0],
  :action => [:KbSpace, :GpButton1],
  :use => [:KbDown, :GpDown],
  :dispose => [:KbEnter, :KbReturn, :KbBackspace, :GpButton2]
}

class Object
  CONTROLS.keys.each do |key|
    ids = CONTROLS[key].map &Gosu.method(:const_get)
    
    define_method "#{key}?" do |id|
      ids.include? id
    end
    
    define_method "#{key}_pressed?" do
      ids.any? { |id| $window.button_down? id }
    end
  end
end
