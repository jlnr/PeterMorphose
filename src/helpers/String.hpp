#pragma once

#include <cstdint>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

/// Parses an integer in the given base. Stricter than std::stoi, and not dependent on locale.
/// @throw std::invalid_argument when out of range, or when there are extra characters in the input.
int string_to_int(std::string_view str, int base = 10);

/// Peter Morphose often uses strings with a fixed number of hex bytes at a given offset.
/// This function converts them to an integer.
/// In Delphi, this was: StrToIntDef('$' + Copy(str, offset + 1, length), fallback)
/// @param fallback The value to return if the string cannot be parsed.
/// @throw std::invalid_argument If the
int hex_chars_to_int(std::string_view str, std::size_t offset, std::size_t length,
                     std::optional<int> fallback = std::nullopt);

// Converts a value between 0 and 255 (inclusive) to a two-digit upper-case hex string.
std::string byte_to_hex(std::uint8_t byte);

/// Converts a string from ISO Latin-1 to UTF-8 in place. This is a quick & dirty conversion based
/// on the fact that the first 256 Unicode code points are roughly equivalent to the Windows
/// codepage that this game used back in 2001.
void latin1_to_utf8(std::string& str);

/// Converts a string from UTF-8 to ISO Latin-1 in place, the inverse of latin1_to_utf8.
/// Code points beyond 255 become a question mark.
void utf8_to_latin1(std::string& str);

/// Splits a string into the parts separated by the given delimiter.
/// The result always has one more element than the number of delimiters.
std::vector<std::string> split(std::string_view str, char delimiter);
