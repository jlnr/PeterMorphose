#pragma once

#include "LevelInfo.hpp"
#include "State.hpp"
#include <memory>
#include <vector>

class LevelSelectionState : public State
{
public:
    LevelSelectionState();
    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;

private:
    static void draw_level_info(const LevelInfo& info, int y, bool active);

    const Gosu::Image m_title_image;
    const std::vector<LevelInfo> m_levels;
    int m_top_index = 0;
    int m_selected_index = 0;
};
