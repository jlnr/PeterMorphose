#pragma once

#include <string>

/// Like t() in the Ruby version: In English mode, it looks the source string up in assets/en.yml,
/// and replaces it if a translation exists. Otherwise, the original value is preserved..
void translate(std::string& str);
