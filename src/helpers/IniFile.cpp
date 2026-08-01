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
            // Values are kept in their original CP1252 encoding; string() converts on access.
            m_sections[current_section].insert_or_assign(std::move(key), std::move(value));
        }
    }
}

void IniFile::write(std::ostream& output) const
{
    for (const auto& [section, entries] : m_sections) {
        output << '[' << section << ']';
        output.write("\r\n", 2); // always write CRLF
        for (const auto& [key, value] : entries) {
            output << key << '=' << value;
            output.write("\r\n", 2); // always write CRLF
        }
        output.write("\r\n", 2); // always write CRLF
    }
}

std::optional<std::string> IniFile::string(const std::string& section,
                                           const std::string& name) const
{
    std::optional<std::string> value = binary(section, name);
    if (value) {
        cp1252_to_utf8(*value);
    }
    return value;
}

std::optional<std::string> IniFile::binary(const std::string& section,
                                           const std::string& name) const
{
    if (!m_sections.contains(section) || !m_sections.at(section).contains(name)) {
        return std::nullopt;
    }
    return m_sections.at(section).at(name);
}

std::optional<int> IniFile::integer(const std::string& section, const std::string& name) const
{
    return string(section, name).transform([&section, &name](const std::string& s) {
        try {
            return string_to_int(s);
        } catch (const std::invalid_argument& e) {
            throw std::invalid_argument("Invalid integer in [" + section + "]: " + name + "=" + s);
        }
    });
}

void IniFile::set_binary(const std::string& section, const std::string& name,
                         const std::string& value)
{
    m_sections[section].insert_or_assign(name, value);
}

void IniFile::set_integer(const std::string& section, const std::string& name, int value)
{
    m_sections[section].insert_or_assign(name, std::to_string(value));
}

#include <doctest.h>
#include <sstream>

TEST_CASE("IniFile")
{
    SUBCASE("empty file")
    {
        std::stringstream ss;
        const IniFile ini(std::move(ss));
        CHECK(!ini.string("Section", "key").has_value());
        CHECK(!ini.integer("Section", "key").has_value());
    }

    SUBCASE("IniFile basic parsing and case-insensitivity")
    {
        std::stringstream ss;
        ss << "[Section1]\n";
        ss << "key1=value1\n";
        ss << "key2=value2\n";
        ss << "\n";
        ss << "[Section2]\n";
        ss << "key3=3\n";

        const IniFile ini(std::move(ss));

        CHECK(ini.string("Section1", "key1") == "value1");
        CHECK(ini.string("Section1", "key2") == "value2");
        CHECK(ini.string("Section2", "key3") == "3");
        CHECK(ini.integer("Section2", "key3") == 3);

        CHECK_THROWS_WITH_AS(ini.integer("Section1", "key1"),
                             "Invalid integer in [Section1]: key1=value1", std::invalid_argument);

        CHECK(!ini.string("Section1", "nonexistent").has_value());
        CHECK(!ini.string("Nonexistent", "key1").has_value());
    }

    SUBCASE("IniFile can parse jr_Gemuetlicher_Aufstieg.pml (PML=Peter Morphose Level)")
    {
        const IniFile ini(std::ifstream("levels/jr_Gemuetlicher_Aufstieg.pml"));

        CHECK(ini.string("Info", "Version") == "Final");
        CHECK(ini.string("Info", "Skill") == "Sehr einfach");
        CHECK(ini.string("Info", "Title") == "Gemütlicher Aufstieg");
        CHECK(ini.integer("Map", "StarsGoal") == 50);
    }

    SUBCASE("binary() keeps raw CP1252, and set()/write() round-trip high bytes")
    {
        std::istringstream empty;

        IniFile ini(std::move(empty));
        ini.set_binary("Hiscore", "level.pml", "\x8f\x98");
        CHECK(ini.binary("Hiscore", "level.pml") == "\x8f\x98");

        std::stringstream out;
        ini.write(out);
        CHECK(out.view() == "[Hiscore]\r\nlevel.pml=\x8f\x98\r\n\r\n");
        const IniFile reloaded(std::move(out));
        CHECK(reloaded.binary("Hiscore", "level.pml") == "\x8f\x98");
    }
}
