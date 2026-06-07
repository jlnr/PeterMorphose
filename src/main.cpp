#include <Gosu/Gosu.hpp>

#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest.h>

int main(int argc, const char* argv[])
{
#ifndef DOCTEST_CONFIG_DISABLE
    doctest::Context context;
    context.applyCommandLine(argc, argv);

    int result = context.run();
    if (context.shouldExit() || argc > 1) {
        return result;
    }
#endif

    Gosu::Window window(640, 480);
    window.show();
    return 0;
}
