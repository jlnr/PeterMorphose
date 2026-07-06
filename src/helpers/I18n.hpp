#pragma once

#include <string>

/// Like t() in the Ruby version: In English mode, it looks the source string up in assets/en.yml,
/// and returns the translation if it exists. Otherwise, the original value is returned.
std::string t(std::string str);

// In-place version of t().
void translate(std::string& str);
