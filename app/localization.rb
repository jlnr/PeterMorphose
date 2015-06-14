def t string
  if Gosu::language.downcase == 'de' then
    string
  else
    $translations ||= YAML.load(File.read('en.yml'))
    $translations[string] || string
  end
end
