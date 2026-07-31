# CMake generated Testfile for 
# Source directory: /src/regression/goto-gcc
# Build directory: /build/regression/goto-gcc
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-gcc-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-gcc" "-C")
set_tests_properties(goto-gcc-CORE PROPERTIES  ENVIRONMENT "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/build/bin" LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-gcc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-gcc/CMakeLists.txt;10;add_test_pl_tests;/src/regression/goto-gcc/CMakeLists.txt;0;")
add_test(goto-gcc-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-gcc" "-T")
set_tests_properties(goto-gcc-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-gcc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-gcc/CMakeLists.txt;10;add_test_pl_tests;/src/regression/goto-gcc/CMakeLists.txt;0;")
add_test(goto-gcc-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-gcc" "-F")
set_tests_properties(goto-gcc-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-gcc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-gcc/CMakeLists.txt;10;add_test_pl_tests;/src/regression/goto-gcc/CMakeLists.txt;0;")
add_test(goto-gcc-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-gcc" "-K")
set_tests_properties(goto-gcc-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-gcc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-gcc/CMakeLists.txt;10;add_test_pl_tests;/src/regression/goto-gcc/CMakeLists.txt;0;")
