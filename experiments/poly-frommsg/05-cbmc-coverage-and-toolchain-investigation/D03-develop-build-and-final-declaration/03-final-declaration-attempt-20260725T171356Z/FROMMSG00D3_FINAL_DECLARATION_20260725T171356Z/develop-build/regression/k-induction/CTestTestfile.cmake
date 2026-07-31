# CMake generated Testfile for 
# Source directory: /src/regression/k-induction
# Build directory: /build/regression/k-induction
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(k-induction-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/k-induction/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-C")
set_tests_properties(k-induction-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/k-induction" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/k-induction/CMakeLists.txt;7;add_test_pl_tests;/src/regression/k-induction/CMakeLists.txt;0;")
add_test(k-induction-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/k-induction/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-T")
set_tests_properties(k-induction-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/k-induction" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/k-induction/CMakeLists.txt;7;add_test_pl_tests;/src/regression/k-induction/CMakeLists.txt;0;")
add_test(k-induction-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/k-induction/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-F")
set_tests_properties(k-induction-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/k-induction" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/k-induction/CMakeLists.txt;7;add_test_pl_tests;/src/regression/k-induction/CMakeLists.txt;0;")
add_test(k-induction-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/k-induction/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-K")
set_tests_properties(k-induction-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/k-induction" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/k-induction/CMakeLists.txt;7;add_test_pl_tests;/src/regression/k-induction/CMakeLists.txt;0;")
