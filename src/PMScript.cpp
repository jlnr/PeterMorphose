#include "PMScript.hpp"
#include "Map.hpp"
#include "helpers/Audio.hpp"
#include "helpers/String.hpp"
#include "objects/GameObject.hpp"
#include "objects/LivingObject.hpp"
#include "states/GameState.hpp"
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <stdexcept>
#include <string>
#include <vector>

static int hex_digit(char c)
{
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    return 0;
}

PMScript::PMScript(GameState& game)
    : m_game(game)
{
}

void PMScript::execute_script(const std::string& script, const std::string& caller)
{
    if (script.empty()) {
        return;
    }
    for (const std::string& command : split(script, '\\')) {
        execute_command(command, caller);
    }
}

void PMScript::forget_object(GameObject* object)
{
    for (GameObject*& slot : m_obj_vars) {
        if (slot == object) {
            slot = nullptr;
        }
    }
}

GameObject* PMScript::get_obj_var(const std::string& var) const
{
    if (var == "$P") {
        return &m_game.player();
    }
    if (var.starts_with('$')) {
        return m_obj_vars[hex_digit(var.back())];
    }
    return nullptr;
}

void PMScript::set_obj_var(const std::string& var, GameObject* object)
{
    if (var.starts_with('$')) {
        m_obj_vars[hex_digit(var.back())] = object;
    }
}

int PMScript::get_obj_attribute(GameObject* object, const std::string& attr)
{
    if (attr == "ex") {
        return object && !object->marked ? 1 : 0;
    }
    if (!object) {
        return 0;
    }
    if (attr == "px") {
        return object->x;
    }
    if (attr == "py") {
        return object->y;
    }
    if (attr == "vx") {
        return object->vx;
    }
    if (attr == "vy") {
        return object->vy;
    }
    if (attr == "id") {
        return object->pmid;
    }
    LivingObject* living = dynamic_cast<LivingObject*>(object);
    if (!living) {
        return 0;
    }
    if (attr == "lf") {
        return living->life;
    }
    if (attr == "ac") {
        return living->action;
    }
    if (attr == "dr") {
        return living->direction;
    }
    return 0;
}

void PMScript::set_obj_attribute(GameObject* object, const std::string& attr, int value)
{
    if (!object) {
        return;
    }
    if (attr == "px") {
        object->x = value;
    }
    else if (attr == "py") {
        object->y = value;
    }
    else if (attr == "vx") {
        object->vx = value;
    }
    else if (attr == "vy") {
        object->vy = value;
    }
    else if (attr == "id") {
        object->pmid = PMID(value);
    }
    LivingObject* living = dynamic_cast<LivingObject*>(object);
    if (!living) {
        return;
    }
    if (attr == "lf") {
        living->life = value;
    }
    else if (attr == "ac") {
        living->action = Action(value);
    }
    else if (attr == "dr") {
        living->direction = Direction(value);
    }
}

int PMScript::get_var(const std::string& var) const
{
    if (var.size() == 4 && var.starts_with("var")) {
        return vars[hex_digit(var[3])];
    }
    if (!var.empty() && var.starts_with('?')) {
        return rand(hex_chars_to_int(var, 1, 3, 0) + 1);
    }
    if (var.size() == 4 && var.starts_with('$')) {
        return get_obj_attribute(get_obj_var(var.substr(0, 2)), var.substr(2));
    }
    if (var == "keys") {
        return m_game.keys;
    }
    if (var == "ammo") {
        return m_game.ammo;
    }
    if (var == "bomb") {
        return m_game.bombs;
    }
    if (var == "star") {
        return m_game.stars;
    }
    if (var == "scor") {
        return m_game.score;
    }
    if (var == "time") {
        return m_game.time_left;
    }
    if (var == "tspd") {
        return m_game.speed_time_left;
    }
    if (var == "tjmp") {
        return m_game.jump_time_left;
    }
    if (var == "tfly") {
        return m_game.fly_time_left;
    }
    if (var == "lpos") {
        return m_game.map.lava_pos;
    }
    if (var == "lspd") {
        return m_game.map.lava_speed;
    }
    if (var == "lmod") {
        return m_game.map.lava_mode;
    }
    throw std::runtime_error("PMScript: unknown variable '" + var + "'");
}

void PMScript::set_var(const std::string& var, int value)
{
    if (var.size() == 4 && var.starts_with("var")) {
        vars[hex_digit(var[3])] = value;
    }
    else if (var.size() == 4 && var.starts_with('$')) {
        set_obj_attribute(get_obj_var(var.substr(0, 2)), var.substr(2), value);
    }
    else if (var == "keys") {
        m_game.keys = value;
    }
    else if (var == "ammo") {
        m_game.ammo = value;
    }
    else if (var == "bomb") {
        m_game.bombs = value;
    }
    else if (var == "star") {
        m_game.stars = value;
    }
    else if (var == "scor") {
        m_game.score = value;
    }
    else if (var == "time") {
        m_game.time_left = value;
    }
    else if (var == "tspd") {
        m_game.speed_time_left = value;
    }
    else if (var == "tjmp") {
        m_game.jump_time_left = value;
    }
    else if (var == "tfly") {
        m_game.fly_time_left = value;
    }
    else if (var == "lpos") {
        m_game.map.lava_pos = value;
    }
    else if (var == "lspd") {
        m_game.map.lava_speed = value;
    }
    else if (var == "lmod") {
        m_game.map.lava_mode = value;
    }
    else {
        throw std::runtime_error("PMScript: cannot set unknown variable '" + var + "'");
    }
}

int PMScript::param_to_int(const std::string& param)
{
    if (param.length() == 5 && param.starts_with('+')) {
        return +string_to_int(param.substr(1), 16);
    }
    if (param.length() == 5 && param.starts_with('-')) {
        return -string_to_int(param.substr(1), 16);
    }
    constexpr const char* hex_digits = "0123456789ABCDEFabcdef";
    if (param.size() == 4 && param.find_first_not_of(hex_digits) == std::string::npos) {
        return string_to_int(param, 16);
    }
    if (param.length() == 4) {
        return get_var(param);
    }
    throw std::runtime_error("PMScript: invalid integer parameter: " + param);
}

bool PMScript::condition_is_true(const std::string& condition)
{
    if (condition == "always") {
        return true;
    }
    // Conditions must be two expressions (four chars each) plus one operator in between.
    if (condition.size() != 9) {
        return false;
    }
    const int left = param_to_int(condition.substr(0, 4));
    const int right = param_to_int(condition.substr(5, 4));
    switch (condition[4]) {
    case '=':
        return left == right;
    case '!':
        return left != right;
    case '<':
        return left < right;
    case '>':
        return left > right;
    case '"':
        return std::abs(left - right) <= 16;
    case '\'':
        return std::abs(left - right) > 16;
    case '{':
        return left <= right;
    case '}':
        return left >= right;
    default:
        return false;
    }
}

void PMScript::execute_command(const std::string& command, const std::string& caller)
{
    if (command.empty()) {
        return;
    }

    if (command.starts_with('_')) {
        // Chain operator: only run if the previous command's condition was true.
        if (m_last_cond) {
            run_action(command.substr(1));
            return;
        }
        return;
    }

    if (!command.starts_with(caller + "(")) {
        // Meant for a different caller. Counts as a failed condition for chaining.
        m_last_cond = false;
        return;
    }

    const std::size_t open = command.find('(');
    const std::size_t close = command.find("):");
    if (close == std::string::npos) {
        return;
    }
    const std::vector conditions = split(command.substr(open + 1, close - open - 1), '&');
    m_last_cond = std::ranges::all_of(
        conditions, [this](const std::string& condition) { return condition_is_true(condition); });
    if (m_last_cond) {
        run_action(command.substr(close + 2));
    }
}

void PMScript::run_action(const std::string& action)
{
    if (action.empty()) {
        return;
    }
    const std::size_t space = action.find(' ');
    if (space == std::string::npos) {
        return;
    }
    const std::string verb = action.substr(0, space);
    const std::string rest = action.substr(space + 1);
    const std::vector<std::string> args = split(rest, ' ');
    const auto have_args = [&](std::size_t n) { return args.size() >= n; };

    if (verb == "set" && have_args(2)) {
        // set $var value
        set_var(args[0], param_to_int(args[1]));
    }
    else if (verb == "add" && have_args(2)) {
        // add $var value
        set_var(args[0], get_var(args[0]) + param_to_int(args[1]));
    }
    else if (verb == "mul" && have_args(2)) {
        // mul $var value
        set_var(args[0], get_var(args[0]) * param_to_int(args[1]));
    }
    else if (verb == "div" && have_args(2)) {
        // div $var value
        const int divisor = param_to_int(args[1]);
        if (divisor != 0) {
            set_var(args[0], get_var(args[0]) / divisor);
        }
    }
    else if (verb == "kill" && have_args(1)) {
        // kill $obj
        if (GameObject* object = get_obj_var(args[0])) {
            object->kill();
        }
    }
    else if (verb == "hit" && have_args(1)) {
        // hit $obj
        if (LivingObject* living = dynamic_cast<LivingObject*>(get_obj_var(args[0]))) {
            living->hit();
        }
    }
    else if (verb == "hurt" && have_args(1)) {
        // hurt $obj
        if (LivingObject* living = dynamic_cast<LivingObject*>(get_obj_var(args[0]))) {
            living->hurt(false);
        }
    }
    else if (verb == "mapsolid" && have_args(3)) {
        // mapsolid $var tile_x tile_y
        set_var(args[0], m_game.map.is_solid(param_to_int(args[1]), param_to_int(args[2])) ? 1 : 0);
    }
    else if (verb == "createobject" && have_args(4)) {
        // createobject id x y $store_in_var
        GameObject* object
            = m_game.create_object(PMID(param_to_int(args[0])), "", //
                                   param_to_int(args[1]), param_to_int(args[2]), 0, 0);
        if (args[3] != "no" && args[3].size() >= 2) {
            m_obj_vars[hex_digit(args[3][1])] = object;
        }
    }
    else if (verb == "setxd" && have_args(1)) { // we allow an absent (empty) second arg
        // setxd $obj Extra data for the object
        if (GameObject* object = get_obj_var(args[0])) {
            object->extra_data = rest.length() > 3 ? rest.substr(3) : "";
        }
    }
    else if (verb == "message") {
        // message Hello world!
        m_game.set_message(rest);
    }
    else if (verb == "message2") {
        // message2 Hello player at position x = $Ppx / y = $Ppy!
        // (Replace each "^XXXX" with the value of XXXX.)
        std::string message;
        for (std::size_t i = 0; i < rest.size();) {
            if (rest[i] == '^' && i + 5 <= rest.size()) {
                message += std::to_string(param_to_int(rest.substr(i + 1, 4)));
                i += 5;
            }
            else {
                message += rest[i++];
            }
        }
        m_game.set_message(message);
    }
    else if (verb == "sound") {
        // sound Filename
        play_sound(rest);
    }
    else if (verb == "casteffects" && have_args(5)) {
        // casteffects smoke flames sparks x y
        m_game.cast_fx(param_to_int(args[0]), param_to_int(args[1]), param_to_int(args[2]), //
                       param_to_int(args[3]), param_to_int(args[4]), TILE_SIZE, TILE_SIZE, 0, 0, 5);
    }
    else if (verb == "casteffects2" && have_args(10)) {
        // casteffects2 smoke flames sparks x y w h vx vy randomness
        m_game.cast_fx(param_to_int(args[0]), param_to_int(args[1]), param_to_int(args[2]),
                       param_to_int(args[3]), param_to_int(args[4]), param_to_int(args[5]),
                       param_to_int(args[6]), param_to_int(args[7]), param_to_int(args[8]),
                       param_to_int(args[9]));
    }
    else if (verb == "changetile" && have_args(3)) {
        // changetile tile_x tile_y tile_id
        m_game.map[param_to_int(args[0]), param_to_int(args[1])] = Tile(param_to_int(args[2]));
    }
    else if (verb == "explosion" && have_args(3)) {
        // explosion x y radius
        m_game.explosion(param_to_int(args[0]), param_to_int(args[1]), param_to_int(args[2]), true);
    }
    else if (verb == "find" && have_args(7) && args[0].size() >= 2) {
        // find $obj min_id max_id x y w h
        set_obj_var(args[0],
                    m_game.find_object(PMID(param_to_int(args[1])), PMID(param_to_int(args[2])),
                                       Rect { param_to_int(args[3]), param_to_int(args[4]),
                                              param_to_int(args[5]), param_to_int(args[6]) }));
    }
}

void GameState::execute_script(const std::string& script, const std::string& caller)
{
    m_script.execute_script(script, caller);
}

void GameState::set_message(const std::string& message)
{
    m_message_text = message;
    m_message_opacity = 255;
}

void GameState::forget_object(GameObject* object)
{
    m_script.forget_object(object);
}

#include "helpers/IniFile.hpp"
#include <doctest.h>
#include <sstream>

TEST_CASE("PMScript")
{
    std::stringstream ss;
    ss << "[Map]\nLavaPos=1024\n[Objects]\nPlayerID=0\n";
    const IniFile ini(std::move(ss));
    GameState game(ini);

    SUBCASE("hex parameters and arithmetic")
    {
        game.execute_script("do(always):set scor 0064", "do"); // 0x64 = 100
        CHECK(game.score == 100);
        game.execute_script("do(always):add scor 000A", "do"); // 0x0A = 10
        CHECK(game.score == 110);
        game.execute_script("do(always):mul scor 0002", "do"); // 0x02 = 2
        CHECK(game.score == 220);
        game.execute_script("do(always):div scor 000B", "do"); // 0x0B = 11
        CHECK(game.score == 20);
    }

    SUBCASE("conditions gate the action")
    {
        game.execute_script("do(always):set keys 0005", "do");
        game.execute_script("do(keys>0003):set star 0001", "do"); // 5 > 3 -> runs
        CHECK(game.stars == 1);
        game.execute_script("do(keys<0003):set star 0002", "do"); // 5 < 3 -> skipped
        CHECK(game.stars == 1);
    }

    SUBCASE("the caller must match")
    {
        game.execute_script("lava(always):set keys 00FF", "do"); // wrong caller -> skipped
        CHECK(game.keys == 0);
        game.execute_script("do(always):set keys 00FF", "do");
        CHECK(game.keys == 255);
    }

    SUBCASE("the _ operator repeats the previous condition")
    {
        game.execute_script("do(0001=0001):set keys 0007\\_set star 0007", "do");
        CHECK(game.keys == 7);
        CHECK(game.stars == 7);
        game.execute_script("do(0001=0002):set ammo 0007\\_set bomb 0007", "do");
        CHECK(game.ammo == 0); // condition false -> neither command runs
        CHECK(game.bombs == 0);
    }

    SUBCASE("changetile changes the map")
    {
        CHECK(game.map[5, 6] != 0xAB);
        game.execute_script("do(always):changetile 0005 0006 00AB", "do");
        CHECK(game.map[5, 6] == 0xAB);
    }
}
