# CMake generated Testfile for 
# Source directory: /workspace/source/regression/smt2_strings
# Build directory: /workspace/build/regression/smt2_strings
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(smt2_strings-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/smt2_solver" "-C")
set_tests_properties(smt2_strings-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/smt2_strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/smt2_strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/smt2_strings/CMakeLists.txt;0;")
add_test(smt2_strings-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/smt2_solver" "-T")
set_tests_properties(smt2_strings-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/smt2_strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/smt2_strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/smt2_strings/CMakeLists.txt;0;")
add_test(smt2_strings-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/smt2_solver" "-F")
set_tests_properties(smt2_strings-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/smt2_strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/smt2_strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/smt2_strings/CMakeLists.txt;0;")
add_test(smt2_strings-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/smt2_solver" "-K")
set_tests_properties(smt2_strings-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/smt2_strings" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/smt2_strings/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/smt2_strings/CMakeLists.txt;0;")
