#pragma once

#include "Constants.hpp"
#include "Map.hpp"
#include "State.hpp"
#include "helpers/Rect.hpp"
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
    int ammo = 0;
    int bombs = 0;
    int score = 0;

    explicit GameState(const IniFile& ini);

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

    /// x/y/width/height is a centered rectangle in this case, hence no "const Rect&" for now.
    void cast_fx(int smoke, int flames, int sparks, int x, int y, int width, int height, //
                 int vx, int vy, int count);
    void cast_objects(PMID pmid, int count, int vx, int vy, int randomness, const Rect& rect);
    GameObject* create_object(int pmid, int x, int y, std::optional<std::string> xdata);
    void explosion(int x, int y, int radius, bool do_score);
    /// Plays a sound the louder the closer it is to the player.
    void emit_sound(int y, const std::string& name);
    GameObject* find_object(PMID min_id, PMID max_id, const Rect& rect);
    GameObject* find_living(PMID min_id, PMID max_id, Action min_act, Action max_act,
                            const Rect& rect);
    GameObject* launch_projectile(int x, int y, Direction direction, PMID min_id, PMID max_id);

private:
    enum class Result
    {
        PLAYING,
        WON,
        LOST,
    };

    void lose(const std::string& reason);
    void draw_status_bar();

    Result m_result = Result::PLAYING;
    bool m_paused = false;
    std::string m_reason;

    int m_frame_fading_box = 16;
    std::string m_message_text;
    int m_message_opacity = 0;

    int m_stars_goal = 0;

    std::shared_ptr<LivingObject> m_player;
    std::vector<std::shared_ptr<GameObject>> m_objects;
};
