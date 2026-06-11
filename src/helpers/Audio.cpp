#include "Audio.hpp"
#include <map>

// No need for thread synchronization here, everything happens on the main thread.

Gosu::Song& song(const std::string& name)
{
    static std::map<std::string, Gosu::Song> songs;
    if (!songs.contains(name)) {
        songs.emplace(name, "media/" + name + ".ogg");
    }
    return songs.at(name);
}

const Gosu::Sample& sound(const std::string& name)
{
    static std::map<std::string, Gosu::Sample> sounds;
    if (!sounds.contains(name)) {
        sounds.emplace(name, "media/" + name + ".wav");
    }
    return sounds.at(name);
}
