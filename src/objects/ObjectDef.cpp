#include "objects/ObjectDef.hpp"
#include "helpers/IniFile.hpp"
#include "helpers/String.hpp"
#include "Constants.hpp"
#include <algorithm>
#include <fstream>
#include <string_view>
#include <vector>

static std::string id_to_hex(PMID id)
{
    constexpr std::string_view hex = "0123456789ABCDEF";
    return { hex[id / 16 % 16], hex[id % 16] };
}

static int hex_byte(std::string_view str, std::size_t offset)
{
    return string_to_int(str.substr(offset, 2), 16);
}

const ObjectDef& ObjectDef::get(PMID pmid)
{
    static const std::vector<ObjectDef> all = [] {
        const IniFile ini(std::ifstream("objects.ini"));
        std::vector<ObjectDef> defs;
        for (int id = 0; id <= ID_MAX; ++id) {
            const std::string id_string = id_to_hex(static_cast<PMID>(id));
            ObjectDef def;
            def.name = ini["ObjName", id_string].value_or("<no name>");
            def.life = string_to_int(ini["ObjLife", id_string].value_or("3"));
            // Rect string is packed as "LLTTWWHH", where left and top are negative.
            const std::string rect_string = ini["ObjRect", id_string].value_or("10102020");
            def.rect.left = -hex_byte(rect_string, 0);
            def.rect.top = -hex_byte(rect_string, 2);
            def.rect.width = hex_byte(rect_string, 4);
            def.rect.height = hex_byte(rect_string, 6);
            def.speed = string_to_int(ini["ObjSpeed", id_string].value_or("3"));
            def.jump_x = string_to_int(ini["ObjJump", id_string + "X"].value_or("0"));
            def.jump_y = string_to_int(ini["ObjJump", id_string + "Y"].value_or("0"));
            defs.push_back(def);
        }
        return defs;
    }();

    return all.at(pmid);
}

#include <doctest.h>

TEST_CASE("ObjectDef")
{
    SUBCASE("ID_PLAYER")
    {
        const ObjectDef& peter = ObjectDef::get(ID_PLAYER);
        CHECK(peter.name == "Peter");
        CHECK(peter.life == 4);
        CHECK(peter.speed == 3);
        CHECK(peter.jump_x == 2);
        CHECK(peter.jump_y == -11);

        // ObjRect "03050711":
        CHECK(peter.rect.left == -0x03);
        CHECK(peter.rect.top == -0x05);
        CHECK(peter.rect.width == 0x07);
        CHECK(peter.rect.height == 0x11);
        CHECK(peter.rect.right() == -0x03 + 0x07);
        CHECK(peter.rect.bottom() == -0x05 + 0x11);
    }

    SUBCASE("ID_ENEMY")
    {
        const ObjectDef& enemy = ObjectDef::get(ID_ENEMY);
        CHECK(enemy.name == "Kinderschreck");
        CHECK(enemy.life == 2);
        CHECK(enemy.speed == 2);
    }

    SUBCASE("ID_KEY")
    {
        const ObjectDef& key = ObjectDef::get(ID_KEY);
        CHECK(key.name == "Schlüssel");
        CHECK(key.life == 3);
        CHECK(key.speed == 3);
        CHECK(key.jump_x == 0);
        CHECK(key.jump_y == 0);
    }
}
