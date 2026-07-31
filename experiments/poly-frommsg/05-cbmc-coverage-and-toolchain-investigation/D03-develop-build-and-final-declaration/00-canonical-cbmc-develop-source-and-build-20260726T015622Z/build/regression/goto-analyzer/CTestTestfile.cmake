# CMake generated Testfile for 
# Source directory: /workspace/source/regression/goto-analyzer
# Build directory: /workspace/build/regression/goto-analyzer
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-analyzer-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-analyzer" "-C")
set_tests_properties(goto-analyzer-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-analyzer" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-analyzer/CMakeLists.txt;0;")
add_test(goto-analyzer-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-analyzer" "-T")
set_tests_properties(goto-analyzer-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-analyzer" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-analyzer/CMakeLists.txt;0;")
add_test(goto-analyzer-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-analyzer" "-F")
set_tests_properties(goto-analyzer-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-analyzer" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-analyzer/CMakeLists.txt;0;")
add_test(goto-analyzer-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-analyzer" "-K")
set_tests_properties(goto-analyzer-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-analyzer" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-analyzer/CMakeLists.txt;0;")
