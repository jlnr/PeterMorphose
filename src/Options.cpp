#include "Options.hpp"
#include <Gosu/Audio.hpp>
#include <Gosu/Directories.hpp>
#include "helpers/IniFile.hpp"
#include "helpers/String.hpp"
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <stdexcept>

// Path of the settings file that stores options and highscores.
static std::string ini_path()
{
    return Gosu::user_settings_path("jlnr", "PeterMorphose", "PeterM.ini");
}

static IniFile& settings_ini()
{
    static IniFile ini = [path = ini_path()] {
        // This tests for write permissions, but also makes sure the file exists so we can open it.
        if (!std::ofstream(path, std::ios::app)) {
            throw std::runtime_error("Unable to write to: " + path);
        }
        return IniFile(std::ifstream(path));
    }();
    return ini;
}

// Writes the INI back to disk atomically (to a temp file, then rename it into place) to avoid data
// loss, especially if (when!) we implement Steam Cloud sync later.
static void write_ini()
{
    const std::string path = ini_path();
    const std::string temp_path = path + ".tmp";
    {
        std::ofstream temp(temp_path, std::ios::binary | std::ios::trunc);
        settings_ini().write(temp);
    }
    std::filesystem::rename(temp_path, path);
}

static std::string level_key(const std::string& level_filename)
{
    // Not std::filesystem::path::filename(): we want to strip both / and \, not just the current
    // platform's separator, so the key is identical no matter which OS produced the path.
    const std::size_t separator = level_filename.find_last_of("/\\");
    return separator == std::string::npos ? level_filename : level_filename.substr(separator + 1);
}

std::string muesli(int value)
{
    const std::string digits = std::to_string(value);
    std::string result;
    for (int i = 1; i <= digits.length(); ++i) {
        int c = static_cast<unsigned char>(digits[i - 1]);
        result += static_cast<char>(c * 2 + 48 + i * 2 - (i % 2) * 5);
    }
    return result;
}

std::optional<int> demuesli(const std::string& encoded)
{
    std::string digits;
    for (int i = 1; i <= encoded.length(); ++i) {
        int c = static_cast<unsigned char>(encoded[i - 1]);
        digits += static_cast<char>((c + (i % 2) * 5 - i * 2 - 48) / 2);
    }
    try {
        return string_to_int(digits);
    } catch (const std::invalid_argument&) {
        return std::nullopt;
    }
}

std::optional<int> load_hiscore(const std::string& level_filename)
{
    return settings_ini().binary("Hiscore", level_key(level_filename)).and_then(demuesli);
}

void save_hiscore(const std::string& level_filename, int score)
{
    const std::string key = level_key(level_filename);
    if (key.empty()) {
        return;
    }
    const std::optional<int> previous = settings_ini().binary("Hiscore", key).and_then(demuesli);
    if (score > previous) {
        settings_ini().set_binary("Hiscore", key, muesli(score));
        write_ini();
    }
}

static Language find_default_language()
{
    // See if the user explicitly prefers a language we offer...
    for (const std::string& locale : Gosu::user_languages()) {
        if (locale.starts_with("de")) {
            return Language::German;
        }
        if (locale.starts_with("en")) {
            return Language::English;
        }
    }
    // ...otherwise default to English:
    return Language::English;
}

Language language()
{
    const std::string code = settings_ini().binary("Options", "Language").value_or("");
    if (code == "de") {
        return Language::German;
    }
    if (code == "en") {
        return Language::English;
    }
    static const Language default_language = find_default_language();
    return default_language;
}

void set_language(Language language)
{
    settings_ini().set_binary("Options", "Language", language == Language::German ? "de" : "en");
    write_ini();
}

int music_volume()
{
    return settings_ini().integer("Options", "MusicVolume").value_or(100);
}

void set_music_volume(int volume)
{
    settings_ini().set_integer("Options", "MusicVolume", volume);
    write_ini();

    if (Gosu::Song* current = Gosu::Song::current_song()) {
        current->set_volume(volume / 100.0);
    }
}

int sound_volume()
{
    return settings_ini().integer("Options", "SoundVolume").value_or(100);
}

void set_sound_volume(int volume)
{
    settings_ini().set_integer("Options", "SoundVolume", volume);
    write_ini();
}

bool minimap_enabled()
{
    return settings_ini().integer("Options", "ShowStatus") == 1;
}

void set_minimap_enabled(bool enabled)
{
    settings_ini().set_integer("Options", "ShowStatus", enabled ? 1 : 0);
    write_ini();
}

#include <doctest.h>

TEST_CASE("Options")
{
    SUBCASE("Muesli obfuscation roundtrip")
    {
        CHECK(demuesli(muesli(0)) == 0);
        CHECK(demuesli(muesli(5)) == 5);
        CHECK(demuesli(muesli(12345)) == 12345);
        CHECK(demuesli(muesli(987654)) == 987654);
    }

    SUBCASE("invalid encodings decode to nullopt")
    {
        CHECK(demuesli("") == std::nullopt);
        CHECK(demuesli("not a real encoding") == std::nullopt);
    }

    SUBCASE("PeterM.ini roundtrip") // should work even on test machines
    {
        int prev_score = load_hiscore("foo/bar/Hiscore.cpp").value_or(-1);
        int new_score = prev_score + 1;
        save_hiscore("qux\\Hiscore.cpp", new_score);
        CHECK(new_score == load_hiscore("Hiscore.cpp"));
    }
}
