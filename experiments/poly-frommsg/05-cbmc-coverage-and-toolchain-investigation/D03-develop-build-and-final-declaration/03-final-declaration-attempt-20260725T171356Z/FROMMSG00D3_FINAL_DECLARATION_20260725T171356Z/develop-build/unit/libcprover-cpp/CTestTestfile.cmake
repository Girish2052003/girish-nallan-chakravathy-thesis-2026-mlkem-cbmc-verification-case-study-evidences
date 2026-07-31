# CMake generated Testfile for 
# Source directory: /src/unit/libcprover-cpp
# Build directory: /build/unit/libcprover-cpp
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(lib-unit "/build/bin/lib-unit")
set_tests_properties(lib-unit PROPERTIES  LABELS "CORE;CBMC" WORKING_DIRECTORY "/src/unit/libcprover-cpp" _BACKTRACE_TRIPLES "/src/unit/libcprover-cpp/CMakeLists.txt;13;add_test;/src/unit/libcprover-cpp/CMakeLists.txt;0;")
