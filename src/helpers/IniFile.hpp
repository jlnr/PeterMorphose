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
    std::optional<std::string> operator[](const std::string& section,
                                          const std::string& name) const;

    /// Converts a key from ISO Latin-1 to UTF-8. Public for testing.
    static void convert_latin1_to_utf8(std::string& str);

private:
    std::map<std::string, std::map<std::string, std::string>> m_sections;
};
