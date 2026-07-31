# CMake generated Testfile for 
# Source directory: /workspace/source/regression/goto-diff
# Build directory: /workspace/build/regression/goto-diff
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-diff-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-diff" "-C")
set_tests_properties(goto-diff-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-diff" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-diff/CMakeLists.txt;0;")
add_test(goto-diff-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-diff" "-T")
set_tests_properties(goto-diff-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-diff" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-diff/CMakeLists.txt;0;")
add_test(goto-diff-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-diff" "-F")
set_tests_properties(goto-diff-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-diff" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-diff/CMakeLists.txt;0;")
add_test(goto-diff-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-diff" "-K")
set_tests_properties(goto-diff-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-diff" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/goto-diff/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-diff/CMakeLists.txt;0;")
