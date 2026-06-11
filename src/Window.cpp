#include "Window.hpp"
#include "states/State.hpp"
#include "states/TitleState.hpp"

Window::Window()
    : Gosu::Window(640, 480, Gosu::WF_WINDOWED, 1000.0 / 30.0)
{
    set_caption("Peter Morphose");
    State::push_state(std::make_unique<TitleState>());
}

void Window::update()
{
    if (State* state = State::current()) {
        state->update();
    }
    else {
        close();
    }
}

void Window::draw()
{
    if (State* state = State::current()) {
        state->draw();
    }
}

void Window::button_down(Gosu::Button id)
{
    if (State* state = State::current()) {
        state->button_down(id);
    }
}

void Window::button_up(Gosu::Button id)
{
    if (State* state = State::current()) {
        state->button_up(id);
    }
}

bool Window::needs_cursor() const
{
    if (State* state = State::current()) {
        return state->needs_cursor();
    }
    return false;
}
