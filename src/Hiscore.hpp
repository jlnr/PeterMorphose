#pragma once

#include <optional>
#include <string>

/// Highscore persistence, ported from the Delphi PeterM.ini [Hiscore] handling.

/// Obfuscates a non-negative integer into the binary Müsli string used in the hiscore file.
/// The result is not valid UTF-8! It can be treated as Latin-1.
std::string muesli(int value);
/// Decodes a binary Müsli string back into an integer. Returns std::nullopt if it is invalid.
std::optional<int> demuesli(const std::string& encoded);

/// Returns the stored highscore for the given level file, or std:nullopt if there is none.
std::optional<int> load_hiscore(const std::string& level_filename);
/// Stores the score as the level's new highscore if it is higher than the previous one.
void save_hiscore(const std::string& level_filename, int score);
