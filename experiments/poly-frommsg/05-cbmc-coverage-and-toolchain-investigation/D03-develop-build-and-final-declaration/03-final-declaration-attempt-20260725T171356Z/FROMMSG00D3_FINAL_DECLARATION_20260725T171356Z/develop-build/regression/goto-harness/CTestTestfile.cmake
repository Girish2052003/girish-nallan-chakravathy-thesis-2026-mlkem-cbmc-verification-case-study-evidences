# CMake generated Testfile for 
# Source directory: /src/regression/goto-harness
# Build directory: /build/regression/goto-harness
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-harness-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/goto-harness    /build/bin/cbmc    false" "-C")
set_tests_properties(goto-harness-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-harness" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-harness/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-harness/CMakeLists.txt;0;")
add_test(goto-harness-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/goto-harness    /build/bin/cbmc    false" "-T")
set_tests_properties(goto-harness-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-harness" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-harness/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-harness/CMakeLists.txt;0;")
add_test(goto-harness-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/goto-harness    /build/bin/cbmc    false" "-F")
set_tests_properties(goto-harness-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-harness" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-harness/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-harness/CMakeLists.txt;0;")
add_test(goto-harness-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/goto-harness    /build/bin/cbmc    false" "-K")
set_tests_properties(goto-harness-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-harness" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-harness/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-harness/CMakeLists.txt;0;")
