# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cbmc-concurrency
# Build directory: /workspace/build/regression/cbmc-concurrency
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-concurrency-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-C")
set_tests_properties(cbmc-concurrency-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;0;")
add_test(cbmc-concurrency-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-T")
set_tests_properties(cbmc-concurrency-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;0;")
add_test(cbmc-concurrency-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-F")
set_tests_properties(cbmc-concurrency-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;0;")
add_test(cbmc-concurrency-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-K")
set_tests_properties(cbmc-concurrency-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-concurrency" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;2;add_test_pl_tests;/workspace/source/regression/cbmc-concurrency/CMakeLists.txt;0;")
