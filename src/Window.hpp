#pragma once

#include <Gosu/Gosu.hpp>

class Window : public Gosu::Window {
public:
    Window();

    void update() override;
    void draw() override;
    void button_down(Gosu::Button id) override;
    void button_up(Gosu::Button id) override;
    bool needs_cursor() const override;
};
