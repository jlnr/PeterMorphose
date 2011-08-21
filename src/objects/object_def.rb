class ObjectDef < Struct.new(:name, :life, :rect, :speed, :jump_x, :jump_y)
  def self.[](pmid)
    @all ||= begin
      ini = INIFile.new('objects.ini')
      (0..ID_MAX).map do |id|
        ObjectDef.new.tap do |obj_def|
          hex_id = "%02x" % id
          obj_def.name = ini['ObjName',  hex_id] || '<no name>'
          obj_def.life = (ini['ObjLife',  hex_id] || 3).to_i
          rect_string = ini['ObjRect',  hex_id] || '10102020'
          obj_def.rect = rect_string.each_char.each_slice(2).map(&:join).map { |str| str.to_i(16) }
          obj_def.speed = (ini['ObjSpeed', hex_id] || 3).to_i
          obj_def.jump_x = (ini['ObjJump', "#{hex_id}X"] || 0).to_i
          obj_def.jump_y = (ini['ObjJump', "#{hex_id}Y"] || 0).to_i
        end
      end
    end
    @all[pmid]
  end
end
