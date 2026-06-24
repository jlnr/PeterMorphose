#pragma once

#include <Gosu/Gosu.hpp>
#include <memory>

class State : Gosu::Noncopyable
{
public:
    virtual ~State() = default;
    virtual void update() { }
    virtual void draw() { }
    virtual void button_down(Gosu::Button id) { }
    virtual void button_up(Gosu::Button id) { }

    static State* current();
    static void push_state(std::unique_ptr<State> state);
    static void pop_state();
};
