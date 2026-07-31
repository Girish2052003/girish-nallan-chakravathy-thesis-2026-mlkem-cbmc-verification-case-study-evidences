# CMake generated Testfile for 
# Source directory: /src/regression/linking-goto-binaries
# Build directory: /build/regression/linking-goto-binaries
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(linking-goto-binaries-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/cbmc    false" "-C")
set_tests_properties(linking-goto-binaries-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/linking-goto-binaries" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/linking-goto-binaries/CMakeLists.txt;7;add_test_pl_tests;/src/regression/linking-goto-binaries/CMakeLists.txt;0;")
add_test(linking-goto-binaries-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/cbmc    false" "-T")
set_tests_properties(linking-goto-binaries-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/linking-goto-binaries" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/linking-goto-binaries/CMakeLists.txt;7;add_test_pl_tests;/src/regression/linking-goto-binaries/CMakeLists.txt;0;")
add_test(linking-goto-binaries-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/cbmc    false" "-F")
set_tests_properties(linking-goto-binaries-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/linking-goto-binaries" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/linking-goto-binaries/CMakeLists.txt;7;add_test_pl_tests;/src/regression/linking-goto-binaries/CMakeLists.txt;0;")
add_test(linking-goto-binaries-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/goto-cc    /build/bin/cbmc    false" "-K")
set_tests_properties(linking-goto-binaries-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/linking-goto-binaries" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/linking-goto-binaries/CMakeLists.txt;7;add_test_pl_tests;/src/regression/linking-goto-binaries/CMakeLists.txt;0;")
