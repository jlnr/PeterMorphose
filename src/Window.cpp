#include "Window.hpp"
#include "Constants.hpp"
#include "Map.hpp"
#include "states/State.hpp"
#include "states/TitleState.hpp"

Window::Window()
    : Gosu::Window(WINDOW_WIDTH, WINDOW_HEIGHT, Gosu::WF_FULLSCREEN, 1000.0 / TARGET_FPS)
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
    Gosu::Window::button_down(id);

    if (State* state = State::current()) {
        state->button_down(id);
    }
}

void Window::button_up(Gosu::Button id)
{
    Gosu::Window::button_up(id);

    if (State* state = State::current()) {
        state->button_up(id);
    }
}

bool Window::needs_cursor() const
{
    return false;
}
