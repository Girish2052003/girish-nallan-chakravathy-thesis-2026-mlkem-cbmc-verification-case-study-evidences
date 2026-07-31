# CMake generated Testfile for 
# Source directory: /src/unit
# Build directory: /build/unit
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(unit "/build/bin/unit")
set_tests_properties(unit PROPERTIES  LABELS "CORE;CBMC" WORKING_DIRECTORY "/src/unit" _BACKTRACE_TRIPLES "/src/unit/CMakeLists.txt;102;add_test;/src/unit/CMakeLists.txt;0;")
add_test(unit-xfail "/build/bin/unit" "[!shouldfail]")
set_tests_properties(unit-xfail PROPERTIES  LABELS "CORE;CBMC" WORKING_DIRECTORY "/src/unit" _BACKTRACE_TRIPLES "/src/unit/CMakeLists.txt;108;add_test;/src/unit/CMakeLists.txt;0;")
subdirs("testing-utils")
subdirs("libcprover-cpp")
