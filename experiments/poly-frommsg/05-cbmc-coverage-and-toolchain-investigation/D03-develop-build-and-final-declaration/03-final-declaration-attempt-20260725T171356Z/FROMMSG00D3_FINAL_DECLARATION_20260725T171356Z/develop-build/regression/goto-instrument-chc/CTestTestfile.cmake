# CMake generated Testfile for 
# Source directory: /src/regression/goto-instrument-chc
# Build directory: /build/regression/goto-instrument-chc
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-instrument-chc-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-instrument-chc/chain.sh /build/bin/goto-cc /build/bin/goto-instrument" "-C")
set_tests_properties(goto-instrument-chc-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-instrument-chc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-instrument-chc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-instrument-chc/CMakeLists.txt;0;")
add_test(goto-instrument-chc-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-instrument-chc/chain.sh /build/bin/goto-cc /build/bin/goto-instrument" "-T")
set_tests_properties(goto-instrument-chc-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-instrument-chc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-instrument-chc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-instrument-chc/CMakeLists.txt;0;")
add_test(goto-instrument-chc-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-instrument-chc/chain.sh /build/bin/goto-cc /build/bin/goto-instrument" "-F")
set_tests_properties(goto-instrument-chc-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-instrument-chc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-instrument-chc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-instrument-chc/CMakeLists.txt;0;")
add_test(goto-instrument-chc-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-instrument-chc/chain.sh /build/bin/goto-cc /build/bin/goto-instrument" "-K")
set_tests_properties(goto-instrument-chc-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-instrument-chc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-instrument-chc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-instrument-chc/CMakeLists.txt;0;")
