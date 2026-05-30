cmake_minimum_required(VERSION 4.2) # using Ubuntu 26.04 LTS as baseline
project(PeterMorphose)
set(CMAKE_CXX_STANDARD 23)
find_package(SDL3 REQUIRED)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS "src/*.cpp")
add_executable(
        PeterMorphose
        ${SOURCES}
)
target_link_libraries(PeterMorphose PRIVATE SDL3::SDL3)
