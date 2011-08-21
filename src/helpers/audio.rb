SONGS, SAMPLES = {}, {}

def song(name)
  # Music stubbed out, not yet converted
  SONGS[name.to_sym] ||= Struct.new(:play).new #Gosu::Song.new("media/#{name}.ogg")
end

def sample(name)
  SAMPLES[name.to_sym] ||= Gosu::Sample.new("media/#{name}.wav")
end
