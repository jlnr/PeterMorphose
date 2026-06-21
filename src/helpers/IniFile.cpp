#include "IniFile.hpp"
#include "String.hpp"
#include <fstream>
#include <regex>

IniFile::IniFile(std::istream&& input)
{
    if (!input) {
        throw std::runtime_error("Cannot read the given INI file");
    }

    static const std::regex section_regex(R"(^\[(.+)\]\r?$)");
    static const std::regex entry_regex(R"(^([^=]*)=(.*)\r?$)");

    std::string line;
    std::string current_section;

    while (std::getline(input, line)) {
        std::smatch match;
        if (std::regex_match(line, match, section_regex)) {
            current_section = match[1];
        }
        else if (std::regex_match(line, match, entry_regex)) {
            std::string key = match[1];
            std::string value = match[2];
            latin1_to_utf8(value);
            m_sections[current_section].insert_or_assign(std::move(key), std::move(value));
        }
    }
}

std::optional<std::string> IniFile::operator[](const std::string& section,
                                               const std::string& name) const
{
    if (!m_sections.contains(section) || !m_sections.at(section).contains(name)) {
        return std::nullopt;
    }
    return m_sections.at(section).at(name);
}

#include <doctest.h>
#include <sstream>

TEST_CASE("IniFile")
{
    SUBCASE("empty file")
    {
        std::stringstream ss;
        const IniFile ini(std::move(ss));
        CHECK(!ini["Section", "key"].has_value());
    }

    SUBCASE("IniFile basic parsing and case-insensitivity")
    {
        std::stringstream ss;
        ss << "[Section1]\n";
        ss << "key1=value1\n";
        ss << "key2=value2\n";
        ss << "\n";
        ss << "[Section2]\n";
        ss << "key3=value3\n";

        const IniFile ini(std::move(ss));

        CHECK(ini["Section1", "key1"] == "value1");
        CHECK(ini["Section1", "key2"] == "value2");
        CHECK(ini["Section2", "key3"] == "value3");
        CHECK(!ini["Section1", "nonexistent"].has_value());
        CHECK(!ini["Nonexistent", "key1"].has_value());
    }

    SUBCASE("IniFile can parse jr_Gemuetlicher_Aufstieg.pml (PML=Peter Morphose Level)")
    {
        const IniFile ini(std::ifstream("levels/jr_Gemuetlicher_Aufstieg.pml"));

        CHECK(ini["Info", "Version"] == "Final");
        CHECK(ini["Info", "Skill"] == "Sehr einfach");
        CHECK(ini["Info", "Title"] == "Gemütlicher Aufstieg");
    }
}
