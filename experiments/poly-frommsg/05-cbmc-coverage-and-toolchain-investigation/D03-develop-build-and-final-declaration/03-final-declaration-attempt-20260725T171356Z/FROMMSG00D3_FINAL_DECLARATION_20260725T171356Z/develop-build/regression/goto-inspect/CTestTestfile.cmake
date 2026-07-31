# CMake generated Testfile for 
# Source directory: /src/regression/goto-inspect
# Build directory: /build/regression/goto-inspect
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-inspect-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-inspect/chain.sh /build/bin/goto-cc /build/bin/goto-inspect false" "-C")
set_tests_properties(goto-inspect-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-inspect" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-inspect/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-inspect/CMakeLists.txt;0;")
add_test(goto-inspect-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-inspect/chain.sh /build/bin/goto-cc /build/bin/goto-inspect false" "-T")
set_tests_properties(goto-inspect-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-inspect" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-inspect/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-inspect/CMakeLists.txt;0;")
add_test(goto-inspect-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-inspect/chain.sh /build/bin/goto-cc /build/bin/goto-inspect false" "-F")
set_tests_properties(goto-inspect-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-inspect" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-inspect/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-inspect/CMakeLists.txt;0;")
add_test(goto-inspect-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-inspect/chain.sh /build/bin/goto-cc /build/bin/goto-inspect false" "-K")
set_tests_properties(goto-inspect-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-inspect" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-inspect/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-inspect/CMakeLists.txt;0;")
