#include "String.hpp"
#include <charconv>
#include <cstddef>
#include <cstdint>
#include <stdexcept>

int string_to_int(std::string_view str, int base)
{
    int value = 0;
    const auto [end, error] = std::from_chars(str.data(), str.data() + str.size(), value, base);
    // The whole string must be consumed and parse cleanly.
    if (error != std::errc() || end != str.data() + str.size()) {
        throw std::invalid_argument("string_to_int: not an integer: '" + std::string(str) + "'");
    }
    return value;
}

int hex_chars_to_int(std::string_view str, std::size_t offset, std::size_t length,
                     std::optional<int> fallback)
{
    if (offset >= str.size()) {
        if (fallback) {
            return *fallback;
        }
        throw std::invalid_argument("hex_chars_to_int: Cannot read from index "
                                    + std::to_string(offset) + " in " + std::string(str));
    }

    try {
        return string_to_int(str.substr(offset, length), 16);
    } catch (const std::invalid_argument&) {
        if (fallback) {
            return *fallback;
        }
        throw;
    }
}

std::string byte_to_hex(std::uint8_t byte)
{
    constexpr std::string_view hex = "0123456789ABCDEF";
    return { hex[byte / 16 % 16], hex[byte % 16] };
}

void latin1_to_utf8(std::string& str)
{
    for (std::size_t i = 0; i < str.length(); ++i) {
        const auto byte = static_cast<std::uint8_t>(str[i]);
        if (byte >= 0x80) {
            // Characters beyond basic ASCII become a two-byte UTF-8 sequence.
            const char utf8[2] = {
                static_cast<char>(0b1100'0000 | (byte >> 6)),
                static_cast<char>(0b1000'0000 | (byte & 0b0011'1111)),
            };

            str.replace(i, 1, utf8, 2);
            // Skip the second byte that we inserted.
            ++i;
        }
    }
}

std::vector<std::string> split(std::string_view str, char delimiter)
{
    std::vector<std::string> parts;
    std::size_t start = 0;
    for (;;) {
        const std::size_t pos = str.find(delimiter, start);
        parts.emplace_back(str.substr(start, pos == std::string_view::npos ? pos : pos - start));
        if (pos == std::string_view::npos) {
            return parts;
        }
        start = pos + 1;
    }
}

#include <doctest.h>

TEST_CASE("String")
{
    SUBCASE("string_to_int")
    {
        CHECK(string_to_int("0") == 0);
        CHECK(string_to_int("963") == 963);
        CHECK(string_to_int("-11") == -11);
        CHECK(string_to_int("2C", 16) == 0x2C);
        CHECK(string_to_int("ff", 16) == 0xFF);

        CHECK_THROWS_AS(string_to_int(""), std::invalid_argument);
        CHECK_THROWS_AS(string_to_int("abc"), std::invalid_argument);
        CHECK_THROWS_AS(string_to_int("12x"), std::invalid_argument);
        CHECK_THROWS_AS(string_to_int("3.5"), std::invalid_argument);
        CHECK_THROWS_AS(string_to_int(" 5"), std::invalid_argument);
        CHECK_THROWS_AS(string_to_int("7 "), std::invalid_argument);
    }

    SUBCASE("byte_to_hex")
    {
        CHECK(byte_to_hex(0) == "00");
        CHECK(byte_to_hex(15) == "0F");
        CHECK(byte_to_hex(251) == "FB");
    }

    SUBCASE("latin1_to_utf8")
    {
        std::string s = "\xe4\xf6\xfc\xdf"; // äöüß in Latin-1
        latin1_to_utf8(s);
        CHECK(s == "äöüß");

        std::string ascii = "Peter Morphose 2001"; // plain ASCII survives unchanged
        latin1_to_utf8(ascii);
        CHECK(ascii == "Peter Morphose 2001");
    }

    SUBCASE("split")
    {
        CHECK(split("a\\b\\c", '\\') == std::vector<std::string> { "a", "b", "c" });
        CHECK(split("a  b", ' ') == std::vector<std::string> { "a", "", "b" });
        CHECK(split("x|", '|') == std::vector<std::string> { "x", "" });
        CHECK(split("hello", ',') == std::vector<std::string> { "hello" });
        CHECK(split("", ',') == std::vector<std::string> { "" });
    }
}
