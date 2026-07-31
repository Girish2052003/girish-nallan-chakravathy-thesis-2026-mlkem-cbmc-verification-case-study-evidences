# CMake generated Testfile for 
# Source directory: /src/regression/goto-bmc
# Build directory: /build/regression/goto-bmc
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-bmc-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-bmc" "-C")
set_tests_properties(goto-bmc-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-bmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-bmc/CMakeLists.txt;0;")
add_test(goto-bmc-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-bmc" "-T")
set_tests_properties(goto-bmc-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-bmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-bmc/CMakeLists.txt;0;")
add_test(goto-bmc-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-bmc" "-F")
set_tests_properties(goto-bmc-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-bmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-bmc/CMakeLists.txt;0;")
add_test(goto-bmc-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-bmc" "-K")
set_tests_properties(goto-bmc-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-bmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/src/regression/goto-bmc/CMakeLists.txt;0;")
