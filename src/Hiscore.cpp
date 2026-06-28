#include "Hiscore.hpp"
#include <Gosu/Directories.hpp>
#include "helpers/IniFile.hpp"
#include "helpers/String.hpp"
#include <filesystem>
#include <fstream>
#include <stdexcept>

// Path of the settings file that stores the highscores. Creates the file if it does not yet exist.
static std::string ini_path()
{
    const std::string path = Gosu::user_settings_path("jlnr", "PeterMorphose", "PeterM.ini");
    if (!std::ofstream(path, std::ios::app)) {
        throw std::runtime_error("Unable to write to: " + path);
    }
    return path;
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
    IniFile ini(std::ifstream(ini_path(), std::ios::binary));
    return ini.binary("Hiscore", level_key(level_filename)).and_then(demuesli);
}

void save_hiscore(const std::string& level_filename, int score)
{
    const std::string key = level_key(level_filename);
    if (key.empty()) {
        return;
    }
    const std::string path = ini_path();
    IniFile ini(std::ifstream(path, std::ios::binary));
    const std::optional<int> previous = ini.binary("Hiscore", key).and_then(demuesli);
    if (score > previous) {
        ini.set_binary("Hiscore", key, muesli(score));
        // Write the new file next to the real one and atomically rename it into place to avoid
        // data loss, especially if (when!) we implement Steam Cloud sync later.
        const std::string temp_path = path + ".tmp";
        {
            std::ofstream temp(temp_path, std::ios::binary | std::ios::trunc);
            ini.write(temp);
        }
        std::filesystem::rename(temp_path, path);
    }
}

#include <doctest.h>

TEST_CASE("Hiscore")
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
