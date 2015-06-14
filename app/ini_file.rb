# A wrapper for INI files, used for levels and other stuff.

class INIFile
  def initialize filename
    @sections = {}
    current_section = nil

    File.open(filename) do |file|
      file.each_line do |line|
        case line.chomp
        when /^\[(.+)\]$/ then
          current_section = @sections[$1] = {}
        when /^([^=]*)=(.*)$/ then
          current_section[$1] = $2
        end
      end
    end
  end
  
  def [](section, name)
    (@sections[section] || {})[name.to_s]
  end
end
