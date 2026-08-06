cmake_minimum_required(VERSION 3.20)
project(locus_core LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

set(EIGEN_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(EIGEN_BUILD_DOC OFF CACHE BOOL "" FORCE)
set(EIGEN_BUILD_PKGCONFIG OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
  eigen
  URL https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz
)
FetchContent_MakeAvailable(eigen)

find_package(Python COMPONENTS Interpreter Development.Module REQUIRED)
find_package(pybind11 CONFIG REQUIRED)

pybind11_add_module(_locus_core MODULE cpp/core.cpp)
target_link_libraries(_locus_core PRIVATE Eigen3::Eigen)
install(TARGETS _locus_core LIBRARY DESTINATION .)

include(CTest)
if(BUILD_TESTING)
  FetchContent_Declare(
    catch2
    URL https://github.com/catchorg/Catch2/archive/refs/tags/v3.7.1.tar.gz
  )
  FetchContent_MakeAvailable(catch2)
  add_executable(core_tests cpp/tests/core_tests.cpp)
  target_link_libraries(core_tests PRIVATE Catch2::Catch2WithMain Eigen3::Eigen)
  include(Catch)
  catch_discover_tests(core_tests)
endif()
