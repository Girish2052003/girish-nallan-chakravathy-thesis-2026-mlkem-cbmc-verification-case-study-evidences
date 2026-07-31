# CMake generated Testfile for 
# Source directory: /src/regression/goto-ld
# Build directory: /build/regression/goto-ld
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-ld-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-ld" "-C")
set_tests_properties(goto-ld-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-ld" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-ld/CMakeLists.txt;4;add_test_pl_tests;/src/regression/goto-ld/CMakeLists.txt;0;")
add_test(goto-ld-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-ld" "-T")
set_tests_properties(goto-ld-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-ld" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-ld/CMakeLists.txt;4;add_test_pl_tests;/src/regression/goto-ld/CMakeLists.txt;0;")
add_test(goto-ld-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-ld" "-F")
set_tests_properties(goto-ld-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-ld" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-ld/CMakeLists.txt;4;add_test_pl_tests;/src/regression/goto-ld/CMakeLists.txt;0;")
add_test(goto-ld-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-ld" "-K")
set_tests_properties(goto-ld-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-ld" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-ld/CMakeLists.txt;4;add_test_pl_tests;/src/regression/goto-ld/CMakeLists.txt;0;")
