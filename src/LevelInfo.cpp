#include "LevelInfo.hpp"
#include "helpers/Graphics.hpp"
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <string_view>

LevelInfo::LevelInfo(const std::string& filename)
    : filename(filename)
{
    std::ifstream file(filename);
    if (!file) {
        throw std::runtime_error("Could not open level file '" + filename + "'");
    }

    const IniFile ini_file(std::move(file));

    title = ini_file["Info", "Title"].value_or("Unbenanntes Level");
    difficulty = ini_file["Info", "Skill"].value_or("");
    description = ini_file["Info", "Desc"].value_or("");
    author = ini_file["Info", "Author"].value_or("");

    goal = ini_file["Map", "StarsGoal"].value_or("100") + " Sterne einsammeln";
    if (goal == "0 Sterne einsammeln") {
        goal = "Durchkommen";
    }

    // Simplification for hostages for now
    int hostages_count = 0;
    for (int i = 0;; ++i) {
        auto obj_desc = ini_file["Objects", std::to_string(i)];
        if (!obj_desc) {
            break;
        }
        if (obj_desc->starts_with("2C")) { // ID_CAROLIN is 0x2C
            hostages_count++;
        }
    }

    if (hostages_count == 1) {
        goal += " und Carolin retten";
    }
    else if (hostages_count > 1) {
        goal += " und " + std::to_string(hostages_count) + " Gefangene retten";
    }

    // TODO highscore = ...
}

std::vector<LevelInfo> LevelInfo::list_levels()
{
    std::vector<LevelInfo> levels;

    for (const auto& entry : std::filesystem::directory_iterator("levels")) {
        if (entry.path().extension() == ".pml") {
            levels.push_back(LevelInfo(entry.path().string()));
        }
    }

    static constexpr std::string_view first_level = "jr_Gemuetlicher_Aufstieg.pml";
    std::ranges::sort(levels, std::less(), [](const LevelInfo& info) {
        return std::tuple { !info.filename.ends_with(first_level), info.difficulty };
    });

    return levels;
}

#include <doctest.h>

TEST_CASE("LevelInfo")
{
    const std::vector<LevelInfo> levels = LevelInfo::list_levels();
    CHECK(levels.size() >= 10);

    SUBCASE("Gemütlicher Aufstieg comes first")
    {
        // Check if the first level is indeed the one specified in the code
        static constexpr std::string_view first_level = "jr_Gemuetlicher_Aufstieg.pml";
        CHECK(levels.at(0).filename.ends_with(first_level));
        CHECK(levels.at(0).title == "Gemütlicher Aufstieg");
        CHECK(levels.at(0).difficulty == "Sehr einfach");
        CHECK(levels.at(0).author == "Julian Raschke, julian@raschke.de, www.petermorphose.de");
    }

    SUBCASE("Gravialistan can be found")
    {
        // Check another level
        const auto it = std::ranges::find_if(levels, [](const LevelInfo& info) {
            return info.filename.ends_with("sl_Gravialistan.pml");
        });
        CHECK(it != levels.end());
        if (it != levels.end()) {
            CHECK(it->title == "Gravialistan");
        }
    }
}
