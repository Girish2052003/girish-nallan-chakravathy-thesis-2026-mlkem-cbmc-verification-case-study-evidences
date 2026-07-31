# CMake generated Testfile for 
# Source directory: /src/regression/catch-framework
# Build directory: /build/regression/catch-framework
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(catch-framework-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/unit" "-C")
set_tests_properties(catch-framework-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/catch-framework" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/catch-framework/CMakeLists.txt;2;add_test_pl_tests;/src/regression/catch-framework/CMakeLists.txt;0;")
add_test(catch-framework-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/unit" "-T")
set_tests_properties(catch-framework-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/catch-framework" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/catch-framework/CMakeLists.txt;2;add_test_pl_tests;/src/regression/catch-framework/CMakeLists.txt;0;")
add_test(catch-framework-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/unit" "-F")
set_tests_properties(catch-framework-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/catch-framework" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/catch-framework/CMakeLists.txt;2;add_test_pl_tests;/src/regression/catch-framework/CMakeLists.txt;0;")
add_test(catch-framework-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/unit" "-K")
set_tests_properties(catch-framework-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/catch-framework" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/catch-framework/CMakeLists.txt;2;add_test_pl_tests;/src/regression/catch-framework/CMakeLists.txt;0;")
