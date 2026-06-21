#pragma once

#include <string>
#include <string_view>

/// Parses an integer in the given base. Stricter than std::stoi, and not dependent on locale.
/// @throw std::invalid_argument when out of range, or when there are extra characters in the input.
int string_to_int(std::string_view str, int base = 10);

/// Converts a string from ISO Latin-1 to UTF-8 in place. This is a quick & dirty conversion based
/// on the fact that the first 256 Unicode code points are roughly equivalent to the Windows
/// codepage that this game used back in 2001.
void latin1_to_utf8(std::string& str);
