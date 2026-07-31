# CMake generated Testfile for 
# Source directory: /src/regression/acceleration
# Build directory: /build/regression/acceleration
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(acceleration-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../accelerate.sh    /build/bin/goto-cc    /build/bin/goto-instrument    /build/bin/cbmc    false" "-C")
set_tests_properties(acceleration-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/acceleration" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/acceleration/CMakeLists.txt;7;add_test_pl_tests;/src/regression/acceleration/CMakeLists.txt;0;")
add_test(acceleration-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../accelerate.sh    /build/bin/goto-cc    /build/bin/goto-instrument    /build/bin/cbmc    false" "-T")
set_tests_properties(acceleration-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/acceleration" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/acceleration/CMakeLists.txt;7;add_test_pl_tests;/src/regression/acceleration/CMakeLists.txt;0;")
add_test(acceleration-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../accelerate.sh    /build/bin/goto-cc    /build/bin/goto-instrument    /build/bin/cbmc    false" "-F")
set_tests_properties(acceleration-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/acceleration" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/acceleration/CMakeLists.txt;7;add_test_pl_tests;/src/regression/acceleration/CMakeLists.txt;0;")
add_test(acceleration-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../accelerate.sh    /build/bin/goto-cc    /build/bin/goto-instrument    /build/bin/cbmc    false" "-K")
set_tests_properties(acceleration-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/acceleration" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/acceleration/CMakeLists.txt;7;add_test_pl_tests;/src/regression/acceleration/CMakeLists.txt;0;")
