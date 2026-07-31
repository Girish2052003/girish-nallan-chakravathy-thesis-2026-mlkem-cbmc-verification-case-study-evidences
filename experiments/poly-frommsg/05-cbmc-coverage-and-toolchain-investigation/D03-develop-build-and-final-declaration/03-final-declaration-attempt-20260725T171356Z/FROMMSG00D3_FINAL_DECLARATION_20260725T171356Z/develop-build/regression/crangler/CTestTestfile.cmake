# CMake generated Testfile for 
# Source directory: /src/regression/crangler
# Build directory: /build/regression/crangler
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(crangler-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/crangler" "-C")
set_tests_properties(crangler-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/crangler" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/crangler/CMakeLists.txt;1;add_test_pl_tests;/src/regression/crangler/CMakeLists.txt;0;")
add_test(crangler-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/crangler" "-T")
set_tests_properties(crangler-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/crangler" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/crangler/CMakeLists.txt;1;add_test_pl_tests;/src/regression/crangler/CMakeLists.txt;0;")
add_test(crangler-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/crangler" "-F")
set_tests_properties(crangler-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/crangler" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/crangler/CMakeLists.txt;1;add_test_pl_tests;/src/regression/crangler/CMakeLists.txt;0;")
add_test(crangler-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/crangler" "-K")
set_tests_properties(crangler-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/crangler" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/crangler/CMakeLists.txt;1;add_test_pl_tests;/src/regression/crangler/CMakeLists.txt;0;")
