# CMake generated Testfile for 
# Source directory: /src/regression/goto-analyzer
# Build directory: /build/regression/goto-analyzer
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-analyzer-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-analyzer" "-C")
set_tests_properties(goto-analyzer-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-analyzer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-analyzer/CMakeLists.txt;0;")
add_test(goto-analyzer-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-analyzer" "-T")
set_tests_properties(goto-analyzer-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-analyzer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-analyzer/CMakeLists.txt;0;")
add_test(goto-analyzer-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-analyzer" "-F")
set_tests_properties(goto-analyzer-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-analyzer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-analyzer/CMakeLists.txt;0;")
add_test(goto-analyzer-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-analyzer" "-K")
set_tests_properties(goto-analyzer-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-analyzer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-analyzer/CMakeLists.txt;0;")
