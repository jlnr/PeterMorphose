#include "helpers/I18n.hpp"
#include <Gosu/Utility.hpp>
#include "IniFile.hpp"
#include "Options.hpp"
#include "String.hpp"
#include <fstream>

static const IniFile& translations()
{
    // Loaded on demand once we need translated strings.
    static const IniFile ini(std::ifstream("assets/I18n.ini"));
    return ini;
}

static std::string english(std::string german)
{
    std::string key = german; // make a backup of the UTF-8 key
    // INI keys are CP1252.
    utf8_to_cp1252(key);
    // Fall back to the source string only when the key is absent.
    return translations().string("English", key).value_or(german);
}

std::string t(std::string str)
{
    translate(str);
    return str;
}

void translate(std::string& str)
{
    if (language() == Language::English) {
        str = english(std::move(str));
    }
}

#include <doctest.h>

TEST_CASE("I18n")
{
    CHECK(english("Musik") == "Music");
    CHECK(english("Optionsmenü") == "Options");
    CHECK(english("404") == "404");
    CHECK(english("Abschnitt 3") == "Section 3");
    CHECK(english("+1 Sekunde") == "+1 second");

    CHECK(t("404") == "404");
}
