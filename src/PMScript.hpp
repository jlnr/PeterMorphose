#pragma once

#include "Constants.hpp"
#include <array>
#include <string>

class GameObject;
class GameState;

/// The PMScript interpreter, which lived in TFormPeterM.ExecuteScript in the original game.
/// It reads and writes the game and map state through its reference to GameState.
/// A PMScript is a backslash-separated list of commands. Each command is either:
///   * "<caller>(<cond>&<cond>...):<action>" - run <action> if this command is meant for the
///                                             current caller and all conditions are true.
///   * "_<action>" - a chain: run <action> if the previous conditions were true (as in a block).
/// Example:
///   do($Ppx>00FF)::set keys 0007\_set star 0007 (C++: if (player.x > 255) { keys = stars = 7 })
class PMScript
{
public:
    /// 16 integer variables (var0...varF).
    std::array<int, 16> vars = { };
    /// 16 object variables ($0...$F) - $P is always the player.
    std::array<GameObject*, 16> m_obj_vars = { };
    /// One optional script per tile row. It fires once when the player, and once when the lava
    /// reaches this row.
    std::array<std::string, TILES_Y> scripts;
    /// Timer scripts (Timer0...Timer10 in the [Scripts] section):
    /// The first ten run every 10 frames, the last script runs every frame.
    std::array<std::string, 11> timers;

    explicit PMScript(GameState& game);

    /// Runs a script: a backslash-separated list of commands, if "caller" matches (lava/player/do),
    /// and if all other conditions are true. A no-op for empty strings.
    void execute_script(const std::string& script, const std::string& caller);
    /// Clears a marked object from the object variables so they never dangle.
    void forget_object(GameObject* object);

private:
    GameState& m_game;
    /// Result of the last command's condition, used by the "_" repeat operator.
    bool m_last_cond = false;

    static int get_obj_attribute(GameObject* object, const std::string& attr);
    static void set_obj_attribute(GameObject* object, const std::string& attr, int value);
    // The helpers below correspond to the nested functions in Delphi's TFormPeterM.ExecuteScript.
    GameObject* get_obj_var(const std::string& var) const; // $P or $0...$F
    void set_obj_var(const std::string& var, GameObject* object);
    int get_var(const std::string& var) const;
    void set_var(const std::string& var, int value);
    int param_to_int(const std::string& param);
    bool condition_is_true(const std::string& condition);
    void execute_command(const std::string& command, const std::string& caller);

    void run_action(const std::string& action);
};
