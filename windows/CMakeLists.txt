# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(aden_digital LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "aden_digital")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT IS_MULTICONFIG AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug"
    "Profile"
    "Release"
  )
endif()

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK gtk+-3.0)

# Define the application source files.
set(SOURCES
  "runner/flutter_window.cpp"
  "runner/main.cpp"
  "runner/utils.cpp"
  "runner/utils.h"
)

# Define build settings.
if(MSVC)
  add_compile_definitions(_USE_MATH_DEFINES)
endif(MSVC)

# Visibility of symbols in the Windows DLL.
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Create Flutter library for the current platform.
include(${FLUTTER_ROOT}/windows/cmake/flutter.cmake)
add_flutter_app(${BINARY_NAME}
  SOURCES ${SOURCES}
  PLUGIN_CONFIGURED_DYNAMIC_LIBRARY_PATH ""
)

# Apply the standard set of build settings. This can be removed for highly
# customized builds. For more details, see:
# https://github.com/google/flutter-cmake-template/wiki/Module-documentation
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_AOT")
target_compile_options(${BINARY_NAME} PRIVATE "/MD$<$<CONFIG:Debug>:d>")
target_compile_options(${BINARY_NAME} PRIVATE "/permissive-")
set_target_properties(${BINARY_NAME} PROPERTIES
  WIN32_EXECUTABLE ON
)

# Windows 10 SDK version is used by default.
target_compile_definitions(${BINARY_NAME} INTERFACE "_WIN32_WINNT=0x0A00")

# VS_STARTUP_PROJECT.
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT ${BINARY_NAME})

# To enable Hot reload, go back to cmake >= 3.24.0 which has MSVC_RUNTIME_LIBRARY
# definition.
target_compile_options(${BINARY_NAME} PRIVATE "/std:c++17")
