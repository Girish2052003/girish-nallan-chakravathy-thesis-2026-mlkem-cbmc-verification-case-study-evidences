# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-shadow-memory
# Build directory: /build/regression/cbmc-shadow-memory
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-shadow-memory-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-C")
set_tests_properties(cbmc-shadow-memory-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
add_test(cbmc-shadow-memory-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-T")
set_tests_properties(cbmc-shadow-memory-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
add_test(cbmc-shadow-memory-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-F")
set_tests_properties(cbmc-shadow-memory-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
add_test(cbmc-shadow-memory-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-K")
set_tests_properties(cbmc-shadow-memory-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
