require 'locale'
require 'yaml'

if Locale.current.language == 'de' then
  def t string
    string
  end
else
  def t string
    @translations ||= YAML.load_file(File.expand_path("#{__FILE__}/../en.yml"))
    @translations[string] ||= begin
      puts "Localization TODO: '#{string}': '...'"
      string
    end
  end
end
