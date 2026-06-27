#pragma once

#include "Constants.hpp"
#include "Map.hpp"
#include "PMScript.hpp"
#include "State.hpp"
#include "helpers/Rect.hpp"
#include <functional>
#include <memory>
#include <string>
#include <vector>

class IniFile;
class GameObject;
class LivingObject;

class GameState : public State
{
public:
    // The public state is inspired by TPMData in the original Delphi source code.
    Map map;
    int view_pos = 0;
    // Initial values taken from TFormPeterM.StartGame.
    int frame = 1;
    // All "time" measured in frames.
    int time_left = 0;
    int inv_time_left = 0;
    int speed_time_left = 0;
    int jump_time_left = 0;
    int fly_time_left = 0;

    int keys = 0;
    int stars = 0;
    int stars_goal = 0;
    int ammo = 0;
    int bombs = 0;
    int score = 0;

    explicit GameState(const IniFile& ini);

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

    void lose(std::string reason);

    /// The player object, owned by m_objects. Used by other objects (e.g. collectibles).
    LivingObject& player() { return *m_player; }

    /// x/y/width/height is a centered rectangle in this case, hence no "const Rect&" for now.
    void cast_fx(int smoke, int flames, int sparks, int x, int y, int width, int height, //
                 int vx, int vy, int randomness);
    void cast_objects(PMID pmid, int count, int vx, int vy, int randomness, const Rect& rect);
    GameObject* create_object(PMID pmid, std::string extra_data, int x, int y, int vx, int vy);
    void explosion(int x, int y, int radius, bool do_score);
    void burn_everything(const Rect& rect);
    void burn_enemies(const Rect& rect);
    /// Plays a sound the louder the closer it is to the player.
    void emit_sound(int y, const std::string& name);
    GameObject* find_object(PMID min_id, PMID max_id, const Rect& rect);
    LivingObject* find_living(PMID min_id, PMID max_id, Action min_act, Action max_act,
                              const Rect& rect);
    LivingObject* launch_projectile(int x, int y, Direction direction, PMID min_id, PMID max_id);

    /// Runs a PMScript, see PMScript.hpp/PMScript.cpp for details.
    void execute_script(const std::string& script, const std::string& caller);
    /// Sets or replaces the current message being shown on-screen.
    void set_message(const std::string& message);
    /// Clears a deleted object from the PMScript object variables so they never dangle.
    void forget_object(GameObject* object);

private:
    enum class Result
    {
        PLAYING,
        WON,
        LOST,
    };

    void draw_status_bar();

    Result m_result = Result::PLAYING;
    bool m_paused = false;
    std::string m_reason;

    int m_frame_fading_box = 16;
    std::string m_message_text;
    int m_message_opacity = 0;

    PMScript m_script;
    /// The highest tile rows the lava and the player have reached (for PMScripts triggers).
    int m_lava_top_pos = TILES_Y;
    int m_player_top_pos = TILES_Y;

    std::shared_ptr<LivingObject> m_player;
    std::vector<std::shared_ptr<GameObject>> m_objects;

    /// Calls the given functor for each LivingObject. This is safer than a for-loop over m_objects
    /// because sometimes we want to create new objects while iterating.
    void for_each_living(std::function<void(LivingObject&)> f);
};
