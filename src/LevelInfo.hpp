#pragma once

#include "helpers/IniFile.hpp"
#include <string>
#include <vector>

struct LevelInfo
{
    std::string filename;
    IniFile ini_file;
    std::string title;
    std::string difficulty;
    std::string description;
    std::string author;
    std::string goal;
    std::optional<int> hiscore;

    explicit LevelInfo(const std::string& filename);

    static std::vector<LevelInfo> list_levels();
};
