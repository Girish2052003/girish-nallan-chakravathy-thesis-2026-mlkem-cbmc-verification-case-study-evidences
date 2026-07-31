# CMake generated Testfile for 
# Source directory: /workspace/source/regression/strings
# Build directory: /workspace/build/regression/strings
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(strings-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-C")
set_tests_properties(strings-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/strings/CMakeLists.txt;0;")
add_test(strings-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-T")
set_tests_properties(strings-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/strings/CMakeLists.txt;0;")
add_test(strings-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-F")
set_tests_properties(strings-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/strings/CMakeLists.txt;0;")
add_test(strings-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-K")
set_tests_properties(strings-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/strings/CMakeLists.txt;0;")
