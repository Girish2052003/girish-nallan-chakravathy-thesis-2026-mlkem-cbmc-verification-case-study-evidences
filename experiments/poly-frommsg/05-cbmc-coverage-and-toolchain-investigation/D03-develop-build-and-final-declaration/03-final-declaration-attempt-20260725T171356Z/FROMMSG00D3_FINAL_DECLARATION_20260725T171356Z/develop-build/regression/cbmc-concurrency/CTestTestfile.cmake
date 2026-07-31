# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-concurrency
# Build directory: /build/regression/cbmc-concurrency
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-concurrency-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-C")
set_tests_properties(cbmc-concurrency-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-concurrency/CMakeLists.txt;0;")
add_test(cbmc-concurrency-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-T")
set_tests_properties(cbmc-concurrency-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-concurrency/CMakeLists.txt;0;")
add_test(cbmc-concurrency-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-F")
set_tests_properties(cbmc-concurrency-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-concurrency/CMakeLists.txt;0;")
add_test(cbmc-concurrency-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-K")
set_tests_properties(cbmc-concurrency-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-concurrency/CMakeLists.txt;0;")
