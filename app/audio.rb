SONGS, SAMPLES = {}, {}

def song(name)
  SONGS[name.to_sym] ||= Gosu::Song.new("media/#{name}.ogg")
end

def sound(name)
  SAMPLES[name.to_sym] ||= Gosu::Sample.new("media/#{name}.wav")
end
