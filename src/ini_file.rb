# A wrapper for INI files, used for levels and other stuff.

require 'iconv'

class INIFile
  def initialize filename, sections
    @sections = {}
    current_section = nil

    File.open(filename) do |file|
      file.each_line do |line|
        case Iconv.conv('utf-8', 'ISO-8859-1', line.chomp)
        when /^\[(.+)\]$/ then
          if sections.include? $1 then
            current_section = @sections[$1] = {}
          else
            current_section = nil
          end
        when /^(.*)=(.*)$/ then
          current_section[$1] = $2 if current_section
        end
      end
    end
  end
  
  def [](section, name)
    if @sections[section].nil? then
      throw "Section #{section} not loaded"
    else
      @sections[section][name.to_s]
    end
  end
end
