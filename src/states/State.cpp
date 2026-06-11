#include "State.hpp"

// No need for thread safety, this game is entirely single-threaded.
static std::vector<std::unique_ptr<State>> state_stack;

State* State::current()
{
    return state_stack.empty() ? nullptr : state_stack.back().get();
}

void State::push_state(std::unique_ptr<State> state)
{
    state_stack.push_back(std::move(state));
}

void State::pop_state()
{
    if (!state_stack.empty()) {
        state_stack.pop_back();
    }
}
