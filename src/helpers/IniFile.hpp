#pragma once

#include <istream>
#include <map>
#include <optional>
#include <ostream>
#include <string>

/// Helper class to read and write INI files in the specific format that Peter Morphose uses.
/// Originally, this was using the Delphi 5 TIniFile class, which internally seems to be based on
/// the Windows GetPrivateProfileString() API. Because the INI files we have to parse are relatively
/// uniform, we don't have to implement all the edge cases.
class IniFile
{
public:
    /// Consumes the given stream and builds up the internal key-value map.
    explicit IniFile(std::istream&& input);

    /// Writes the whole INI file to the given stream.
    void write(std::ostream& output) const;

    /// Returns the value for the given key, converted from Latin-1 to UTF-8, or std::nullopt.
    std::optional<std::string> string(const std::string& section, const std::string& name) const;
    /// Returns the raw value (without UTF-8 conversion) for the given key, or std::nullopt.
    std::optional<std::string> binary(const std::string& section, const std::string& name) const;
    /// Returns the integer with the given key in the given section. Throws if it cannot be parsed.
    std::optional<int> integer(const std::string& section, const std::string& name) const;

    /// Sets a raw (Latin-1) value, creating the section and key if necessary.
    void set_binary(const std::string& section, const std::string& name, const std::string& value);

private:
    /// Values are stored internally in their original encoding (binary or Latin-1).
    std::map<std::string, std::map<std::string, std::string>> m_sections;
};
