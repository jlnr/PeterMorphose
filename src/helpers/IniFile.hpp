#pragma once

#include <istream>
#include <map>
#include <optional>
#include <string>

/// Helper class to read an INI file in the specific format that Peter Morphose uses. Originally,
/// this was using the Delphi 5 TIniFile class, which internally seems to be based on the Windows
/// GetPrivateProfileString() API. Because the INI files we have to parse are relatively uniform, we
/// don't have to implement all the edge cases.
/// This class converts all values from their original encoding (Latin-1) to UTF-8.
class IniFile
{
public:
    /// Consumes the given stream and builds up the internal key-value map.
    explicit IniFile(std::istream&& input);

    /// Returns the value for the given key in the given section, or std::nullopt otherwise.
    std::optional<std::string> string(const std::string& section, const std::string& name) const;
    std::optional<int> integer(const std::string& section, const std::string& name) const;

private:
    std::map<std::string, std::map<std::string, std::string>> m_sections;
};
