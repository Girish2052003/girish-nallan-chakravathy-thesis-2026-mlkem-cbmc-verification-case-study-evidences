# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cbmc-primitives
# Build directory: /workspace/build/regression/cbmc-primitives
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-primitives-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-C" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;0;")
add_test(cbmc-primitives-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-T" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;0;")
add_test(cbmc-primitives-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-F" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;0;")
add_test(cbmc-primitives-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-K" "-X" "smt-backend")
set_tests_properties(cbmc-primitives-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-primitives" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;16;add_test_pl_tests;/workspace/source/regression/cbmc-primitives/CMakeLists.txt;0;")
