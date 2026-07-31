# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-primitives
# Build directory: /build/regression/cbmc-primitives
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-primitives-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-C" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/src/regression/cbmc-primitives/CMakeLists.txt;0;")
add_test(cbmc-primitives-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-T" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/src/regression/cbmc-primitives/CMakeLists.txt;0;")
add_test(cbmc-primitives-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-F" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/src/regression/cbmc-primitives/CMakeLists.txt;0;")
add_test(cbmc-primitives-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-K" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/src/regression/cbmc-primitives/CMakeLists.txt;0;")
