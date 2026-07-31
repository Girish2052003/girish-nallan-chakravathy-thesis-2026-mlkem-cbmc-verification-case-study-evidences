# CMake generated Testfile for 
# Source directory: /src/regression/statement-list
# Build directory: /build/regression/statement-list
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(statement-list-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-C" "-X" "smt-backend")
set_tests_properties(statement-list-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/statement-list" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/statement-list/CMakeLists.txt;1;add_test_pl_tests;/src/regression/statement-list/CMakeLists.txt;0;")
add_test(statement-list-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-T" "-X" "smt-backend")
set_tests_properties(statement-list-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/statement-list" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/statement-list/CMakeLists.txt;1;add_test_pl_tests;/src/regression/statement-list/CMakeLists.txt;0;")
add_test(statement-list-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-F" "-X" "smt-backend")
set_tests_properties(statement-list-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/statement-list" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/statement-list/CMakeLists.txt;1;add_test_pl_tests;/src/regression/statement-list/CMakeLists.txt;0;")
add_test(statement-list-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-K" "-X" "smt-backend")
set_tests_properties(statement-list-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/statement-list" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/statement-list/CMakeLists.txt;1;add_test_pl_tests;/src/regression/statement-list/CMakeLists.txt;0;")
