# CMakeList.txt : CMake project for planner, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.8)

project ("planner")

find_package( Boost REQUIRED COMPONENTS program_options system filesystem)
include_directories( ${Boost_INCLUDE_DIRS} )

# Add source to this project's executable.
add_executable (planner "planner.cpp" "planner.h" "map_loader.cpp" "map_load.h")



# TODO: Add tests and install targets if needed.
