# CMake generated Testfile for 
# Source directory: /src/regression/cpp
# Build directory: /build/regression/cpp
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cpp-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-cc" "-C")
set_tests_properties(cpp-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cpp" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cpp/CMakeLists.txt;7;add_test_pl_tests;/src/regression/cpp/CMakeLists.txt;0;")
add_test(cpp-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-cc" "-T")
set_tests_properties(cpp-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cpp" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cpp/CMakeLists.txt;7;add_test_pl_tests;/src/regression/cpp/CMakeLists.txt;0;")
add_test(cpp-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-cc" "-F")
set_tests_properties(cpp-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cpp" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cpp/CMakeLists.txt;7;add_test_pl_tests;/src/regression/cpp/CMakeLists.txt;0;")
add_test(cpp-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/goto-cc" "-K")
set_tests_properties(cpp-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cpp" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cpp/CMakeLists.txt;7;add_test_pl_tests;/src/regression/cpp/CMakeLists.txt;0;")
