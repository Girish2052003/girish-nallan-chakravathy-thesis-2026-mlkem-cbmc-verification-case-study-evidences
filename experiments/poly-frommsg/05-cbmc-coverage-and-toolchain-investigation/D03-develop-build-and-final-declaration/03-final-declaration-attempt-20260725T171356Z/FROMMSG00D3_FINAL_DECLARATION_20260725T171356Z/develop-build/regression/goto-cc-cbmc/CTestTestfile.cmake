# CMake generated Testfile for 
# Source directory: /src/regression/goto-cc-cbmc
# Build directory: /build/regression/goto-cc-cbmc
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-cc-cbmc-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-cc-cbmc/chain.sh /build/bin/goto-cc /build/bin/cbmc false" "-C")
set_tests_properties(goto-cc-cbmc-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-cc-cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-cc-cbmc/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-cc-cbmc/CMakeLists.txt;0;")
add_test(goto-cc-cbmc-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-cc-cbmc/chain.sh /build/bin/goto-cc /build/bin/cbmc false" "-T")
set_tests_properties(goto-cc-cbmc-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-cc-cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-cc-cbmc/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-cc-cbmc/CMakeLists.txt;0;")
add_test(goto-cc-cbmc-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-cc-cbmc/chain.sh /build/bin/goto-cc /build/bin/cbmc false" "-F")
set_tests_properties(goto-cc-cbmc-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-cc-cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-cc-cbmc/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-cc-cbmc/CMakeLists.txt;0;")
add_test(goto-cc-cbmc-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-cc-cbmc/chain.sh /build/bin/goto-cc /build/bin/cbmc false" "-K")
set_tests_properties(goto-cc-cbmc-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-cc-cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-cc-cbmc/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-cc-cbmc/CMakeLists.txt;0;")
