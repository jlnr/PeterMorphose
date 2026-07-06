cmake_minimum_required(VERSION 4.2) # using Ubuntu 26.04 LTS as baseline
project(PeterMorphose)
set(CMAKE_CXX_STANDARD 23)

add_subdirectory(vendor/gosu)
include_directories(vendor/doctest/doctest)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS "src/*.cpp")
add_executable(
        PeterMorphose
        ${SOURCES}
)
target_link_libraries(PeterMorphose PRIVATE Gosu::Gosu)
target_include_directories(PeterMorphose PRIVATE src)

option(ENABLE_TESTING "Build unit tests" ON)
if (ENABLE_TESTING)
    enable_testing()
    # Run from the project root so that tests can load assets/ and levels/ from relative paths.
    # Pass --exit so that the game does not launch after the test run.
    add_test(NAME PeterMorphose COMMAND PeterMorphose --exit WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
else ()
    add_definitions("-DDOCTEST_CONFIG_DISABLE")
endif ()
