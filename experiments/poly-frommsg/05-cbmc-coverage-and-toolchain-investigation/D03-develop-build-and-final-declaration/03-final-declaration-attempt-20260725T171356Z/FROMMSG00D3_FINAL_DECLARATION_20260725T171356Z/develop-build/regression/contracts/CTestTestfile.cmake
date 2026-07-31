# CMake generated Testfile for 
# Source directory: /src/regression/contracts
# Build directory: /build/regression/contracts
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(contracts-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/contracts/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-C")
set_tests_properties(contracts-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/contracts" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/contracts/CMakeLists.txt;16;add_test_pl_tests;/src/regression/contracts/CMakeLists.txt;0;")
add_test(contracts-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/contracts/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-T")
set_tests_properties(contracts-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/contracts" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/contracts/CMakeLists.txt;16;add_test_pl_tests;/src/regression/contracts/CMakeLists.txt;0;")
add_test(contracts-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/contracts/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-F")
set_tests_properties(contracts-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/contracts" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/contracts/CMakeLists.txt;16;add_test_pl_tests;/src/regression/contracts/CMakeLists.txt;0;")
add_test(contracts-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/contracts/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/cbmc false" "-K")
set_tests_properties(contracts-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/contracts" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/contracts/CMakeLists.txt;16;add_test_pl_tests;/src/regression/contracts/CMakeLists.txt;0;")
