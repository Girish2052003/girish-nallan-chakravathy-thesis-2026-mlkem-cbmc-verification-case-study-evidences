# CMake generated Testfile for 
# Source directory: /workspace/source/unit
# Build directory: /workspace/build/unit
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(unit "/workspace/build/bin/unit")
set_tests_properties(unit PROPERTIES  LABELS "CORE;CBMC" WORKING_DIRECTORY "/workspace/source/unit" _BACKTRACE_TRIPLES "/workspace/source/unit/CMakeLists.txt;102;add_test;/workspace/source/unit/CMakeLists.txt;0;")
add_test(unit-xfail "/workspace/build/bin/unit" "[!shouldfail]")
set_tests_properties(unit-xfail PROPERTIES  LABELS "CORE;CBMC" WORKING_DIRECTORY "/workspace/source/unit" _BACKTRACE_TRIPLES "/workspace/source/unit/CMakeLists.txt;108;add_test;/workspace/source/unit/CMakeLists.txt;0;")
subdirs("testing-utils")
subdirs("libcprover-cpp")
