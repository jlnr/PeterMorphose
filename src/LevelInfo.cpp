#include "LevelInfo.hpp"
#include "Constants.hpp"
#include "Options.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/I18n.hpp"
#include "helpers/String.hpp"
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <string_view>

LevelInfo::LevelInfo(const std::string& filename)
    : filename(filename),
      ini_file(std::ifstream(filename))
{
    title = ini_file.string("Info", "Title").value_or("Unbenanntes Level");
    difficulty = ini_file.string("Info", "Skill").value_or("");
    description = ini_file.string("Info", "Desc").value_or("");
    author = ini_file.string("Info", "Author").value_or("");

    // The goal is composed from translated() parts, like t() in the Ruby version. The English
    // parts are worded so that they work in the same order as the German original.
    goal = ini_file.string("Map", "StarsGoal").value_or("100");
    if (goal == "0") {
        goal = t("Durchkommen");
    }
    else {
        goal += " " + t("Sterne einsammeln");
    }

    int hostages_count = 0;
    std::optional<std::string> hostage_name;
    for (int i = 0;; ++i) {
        const std::optional obj = ini_file.string("Objects", std::to_string(i));
        if (!obj) {
            break;
        }
        if (obj->starts_with(byte_to_hex(ID_HOSTAGE))) {
            hostages_count += 1;
            const std::optional extra_data = ini_file.string("Objects", std::to_string(i) + "Y");
            if (extra_data && extra_data->length() > 2) {
                hostage_name = extra_data->substr(2);
            }
        }
    }

    if (hostages_count == 1) {
        goal += " " + t("und") + " " + hostage_name.value_or("Carolin");
        if (const std::string rescue = t("retten"); !rescue.empty()) {
            goal += " " + rescue; // "retten" trails the name in German, but is empty in English
        }
    }
    else if (hostages_count > 1) {
        goal += " " + t("und") + " " + std::to_string(hostages_count) + " "
            + t("Gefangene retten");
    }

    hiscore = load_hiscore(filename);
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
            // The goal is language-dependent; accept the German and the English composition.
            CHECK((it->goal == "100 Sterne einsammeln und Tanja retten"
                   || it->goal == "100 stars to collect & need to rescue Tanja"));
        }
    }
}
