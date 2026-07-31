# CMake generated Testfile for 
# Source directory: /src/regression/invariants
# Build directory: /build/regression/invariants
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(invariants-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/driver" "-C")
set_tests_properties(invariants-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/invariants" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/src/regression/invariants/CMakeLists.txt;0;")
add_test(invariants-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/driver" "-T")
set_tests_properties(invariants-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/invariants" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/src/regression/invariants/CMakeLists.txt;0;")
add_test(invariants-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/driver" "-F")
set_tests_properties(invariants-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/invariants" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/src/regression/invariants/CMakeLists.txt;0;")
add_test(invariants-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/driver" "-K")
set_tests_properties(invariants-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/invariants" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/src/regression/invariants/CMakeLists.txt;0;")
