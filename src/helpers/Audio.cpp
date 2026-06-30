#include "Audio.hpp"
#include "Constants.hpp"
#include "Gosu/Audio.hpp"
#include "Options.hpp"
#include <filesystem>
#include <map>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

// No need for thread synchronization here, everything happens on the main thread.

void play_song(const std::string& name)
{
    static std::map<std::string, Gosu::Song> songs;
    if (!songs.contains(name)) {
        songs.emplace(name, "assets/" + name + ".ogg");
    }
    Gosu::Song& song = songs.at(name);
    song.set_volume(music_volume() / 100.0);
    song.play(true);
}

void play_sound(const std::string& name, double volume, double speed)
{
    static std::map<std::string, std::vector<Gosu::Sample>> sounds;
    std::vector<Gosu::Sample>& variants = sounds[name];
    if (variants.empty()) {
        // The first variant is the plain name, the rest are numbered (Door, Door2, Door3, ...).
        const std::string plain_filename = "assets/" + name + ".wav";
        if (std::filesystem::exists(plain_filename)) {
            variants.push_back(Gosu::Sample(plain_filename));
        }
        for (int i = 2;; ++i) {
            const std::string variant_filename = "assets/" + name + std::to_string(i) + ".wav";
            if (!std::filesystem::exists(variant_filename)) {
                break;
            }
            variants.push_back(Gosu::Sample(variant_filename));
        }
        if (variants.empty()) {
            throw std::runtime_error("Could not find sound file: " + name);
        }
    }
    std::ignore = variants.at(rand(variants.size())).play(volume * sound_volume() / 100.0, speed);
}
