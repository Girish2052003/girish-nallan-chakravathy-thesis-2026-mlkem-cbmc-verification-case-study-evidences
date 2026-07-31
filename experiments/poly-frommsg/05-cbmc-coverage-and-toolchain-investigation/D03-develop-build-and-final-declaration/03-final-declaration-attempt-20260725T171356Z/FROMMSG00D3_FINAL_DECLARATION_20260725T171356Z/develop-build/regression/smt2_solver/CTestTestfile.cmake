# CMake generated Testfile for 
# Source directory: /src/regression/smt2_solver
# Build directory: /build/regression/smt2_solver
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(smt2_solver-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/smt2_solver" "-C")
set_tests_properties(smt2_solver-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/smt2_solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/smt2_solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/smt2_solver/CMakeLists.txt;0;")
add_test(smt2_solver-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/smt2_solver" "-T")
set_tests_properties(smt2_solver-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/smt2_solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/smt2_solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/smt2_solver/CMakeLists.txt;0;")
add_test(smt2_solver-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/smt2_solver" "-F")
set_tests_properties(smt2_solver-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/smt2_solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/smt2_solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/smt2_solver/CMakeLists.txt;0;")
add_test(smt2_solver-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/smt2_solver" "-K")
set_tests_properties(smt2_solver-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/smt2_solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/smt2_solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/smt2_solver/CMakeLists.txt;0;")
