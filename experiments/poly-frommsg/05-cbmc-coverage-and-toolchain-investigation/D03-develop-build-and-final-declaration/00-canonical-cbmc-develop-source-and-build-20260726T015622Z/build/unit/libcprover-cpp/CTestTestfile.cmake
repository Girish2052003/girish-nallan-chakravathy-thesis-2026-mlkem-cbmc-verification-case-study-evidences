# CMake generated Testfile for 
# Source directory: /workspace/source/unit/libcprover-cpp
# Build directory: /workspace/build/unit/libcprover-cpp
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(lib-unit "/workspace/build/bin/lib-unit")
set_tests_properties(lib-unit PROPERTIES  LABELS "CORE;CBMC" WORKING_DIRECTORY "/workspace/source/unit/libcprover-cpp" _BACKTRACE_TRIPLES "/workspace/source/unit/libcprover-cpp/CMakeLists.txt;13;add_test;/workspace/source/unit/libcprover-cpp/CMakeLists.txt;0;")
