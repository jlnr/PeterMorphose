#include "Audio.hpp"
#include "Gosu/Audio.hpp"
#include <map>
#include <utility>

// No need for thread synchronization here, everything happens on the main thread.

void play_song(const std::string& name)
{
    static std::map<std::string, Gosu::Song> songs;
    if (!songs.contains(name)) {
        songs.emplace(name, "media/" + name + ".ogg");
    }
    songs.at(name).play(true);
}

void play_sound(const std::string& name, double volume, double speed)
{
    static std::map<std::string, Gosu::Sample> sounds;
    if (!sounds.contains(name)) {
        sounds.emplace(name, "media/" + name + ".wav");
    }
    std::ignore = sounds.at(name).play(volume, speed);
}
