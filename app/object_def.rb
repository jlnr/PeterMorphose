class ObjectDef < Struct.new(:name, :life, :rect, :speed, :jump_x, :jump_y)
  # TODO This has become a general purpose class, should be moved out of this file
  class Rect < Struct.new(:left, :top, :width, :height)
    def right
      left + width
    end
    
    def bottom
      top + height
    end
    
    def collide_with? other
      left < other.right and right > other.left and
        top < other.bottom and bottom > other.top
    end
    
    def include? point
      point.x >= left and point.y >= top and
        point.x < right and point.y < bottom
    end
  end
  
  def self.[](pmid)
    @all ||= begin
      ini = INIFile.new('objects.ini')
      (0..ID_MAX).map do |id|
        ObjectDef.new.tap do |obj_def|
          hex_id = "%02X" % id
          obj_def.name = ini['ObjName',  hex_id] || '<no name>'
          obj_def.life = (ini['ObjLife',  hex_id] || 3).to_i
          rect_string = ini['ObjRect',  hex_id] || '10102020'
          obj_def.rect = Rect.new
          obj_def.rect.left   = -rect_string[0, 2].to_i(16)
          obj_def.rect.top    = -rect_string[2, 2].to_i(16)
          obj_def.rect.width  = +rect_string[4, 2].to_i(16)
          obj_def.rect.height = +rect_string[6, 2].to_i(16)
          obj_def.speed = (ini['ObjSpeed', hex_id] || 3).to_i
          obj_def.jump_x = (ini['ObjJump', "#{hex_id}X"] || 0).to_i
          obj_def.jump_y = (ini['ObjJump', "#{hex_id}Y"] || 0).to_i
        end
      end
    end
    @all[pmid]
  end
end
