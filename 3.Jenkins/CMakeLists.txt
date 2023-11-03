cmake_minimum_required(VERSION 3.10)
project(test)

option(BUILD_EXECUTABLE "" OFF)

if (BUILD_EXECUTABLE)
	add_executable(MyExecutable app/main.cpp app/lib.cpp app/lib.h)
endif()