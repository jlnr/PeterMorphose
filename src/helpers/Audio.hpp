#pragma once

#include <Gosu/Gosu.hpp>
#include <string>

Gosu::Song& song(const std::string& name);
const Gosu::Sample& sound(const std::string& name);
