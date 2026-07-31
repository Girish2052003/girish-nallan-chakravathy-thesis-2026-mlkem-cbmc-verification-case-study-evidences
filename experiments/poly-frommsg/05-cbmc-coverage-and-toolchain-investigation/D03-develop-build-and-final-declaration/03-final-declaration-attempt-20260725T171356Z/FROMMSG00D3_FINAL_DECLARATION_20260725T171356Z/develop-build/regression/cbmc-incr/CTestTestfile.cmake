# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-incr
# Build directory: /build/regression/cbmc-incr
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-incr-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 30 /build/bin/cbmc --incremental --magic-numbers" "-C")
set_tests_properties(cbmc-incr-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-incr/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr/CMakeLists.txt;0;")
add_test(cbmc-incr-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 30 /build/bin/cbmc --incremental --magic-numbers" "-T")
set_tests_properties(cbmc-incr-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-incr/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr/CMakeLists.txt;0;")
add_test(cbmc-incr-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 30 /build/bin/cbmc --incremental --magic-numbers" "-F")
set_tests_properties(cbmc-incr-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-incr/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr/CMakeLists.txt;0;")
add_test(cbmc-incr-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 30 /build/bin/cbmc --incremental --magic-numbers" "-K")
set_tests_properties(cbmc-incr-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-incr/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr/CMakeLists.txt;0;")
