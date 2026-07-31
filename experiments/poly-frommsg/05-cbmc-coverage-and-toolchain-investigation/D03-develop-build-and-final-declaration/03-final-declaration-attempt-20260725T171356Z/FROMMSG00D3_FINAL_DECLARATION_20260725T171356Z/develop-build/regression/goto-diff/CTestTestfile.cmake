# CMake generated Testfile for 
# Source directory: /src/regression/goto-diff
# Build directory: /build/regression/goto-diff
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-diff-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-diff" "-C")
set_tests_properties(goto-diff-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-diff" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-diff/CMakeLists.txt;0;")
add_test(goto-diff-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-diff" "-T")
set_tests_properties(goto-diff-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-diff" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-diff/CMakeLists.txt;0;")
add_test(goto-diff-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-diff" "-F")
set_tests_properties(goto-diff-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-diff" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-diff/CMakeLists.txt;0;")
add_test(goto-diff-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-diff" "-K")
set_tests_properties(goto-diff-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-diff" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-diff/CMakeLists.txt;0;")
