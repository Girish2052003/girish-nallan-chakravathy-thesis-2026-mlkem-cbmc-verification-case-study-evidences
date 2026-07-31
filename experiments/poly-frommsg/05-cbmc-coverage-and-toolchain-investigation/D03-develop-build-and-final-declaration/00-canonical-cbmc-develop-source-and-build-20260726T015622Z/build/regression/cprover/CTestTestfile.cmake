# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cprover
# Build directory: /workspace/build/regression/cprover
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cprover-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cprover" "-C")
set_tests_properties(cprover-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cprover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/cprover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cprover/CMakeLists.txt;0;")
add_test(cprover-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cprover" "-T")
set_tests_properties(cprover-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cprover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/cprover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cprover/CMakeLists.txt;0;")
add_test(cprover-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cprover" "-F")
set_tests_properties(cprover-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cprover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/cprover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cprover/CMakeLists.txt;0;")
add_test(cprover-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cprover" "-K")
set_tests_properties(cprover-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cprover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/cprover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cprover/CMakeLists.txt;0;")
