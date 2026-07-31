# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-incr-oneloop
# Build directory: /build/regression/cbmc-incr-oneloop
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-incr-oneloop-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 25 /build/bin/cbmc --slice-formula" "-C")
set_tests_properties(cbmc-incr-oneloop-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr-oneloop" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;0;")
add_test(cbmc-incr-oneloop-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 25 /build/bin/cbmc --slice-formula" "-T")
set_tests_properties(cbmc-incr-oneloop-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr-oneloop" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;0;")
add_test(cbmc-incr-oneloop-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 25 /build/bin/cbmc --slice-formula" "-F")
set_tests_properties(cbmc-incr-oneloop-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr-oneloop" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;0;")
add_test(cbmc-incr-oneloop-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "perl ../timeout.pl 25 /build/bin/cbmc --slice-formula" "-K")
set_tests_properties(cbmc-incr-oneloop-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr-oneloop" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-incr-oneloop/CMakeLists.txt;0;")
