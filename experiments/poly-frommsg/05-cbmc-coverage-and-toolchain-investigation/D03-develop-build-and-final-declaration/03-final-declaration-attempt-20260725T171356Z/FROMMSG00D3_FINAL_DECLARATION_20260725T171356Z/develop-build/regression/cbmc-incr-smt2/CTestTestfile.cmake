# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-incr-smt2
# Build directory: /build/regression/cbmc-incr-smt2
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-incr-smt2-z3-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --incremental-smt2-solver 'z3 --smt2 -in' --validate-goto-model --validate-ssa-equation" "-C" "-s" "new-smt-z3")
set_tests_properties(cbmc-incr-smt2-z3-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr-smt2" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/cbmc-incr-smt2/CMakeLists.txt;1;add_test_pl_profile;/src/regression/cbmc-incr-smt2/CMakeLists.txt;0;")
add_test(cbmc-incr-smt2-cvc5-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --incremental-smt2-solver 'cvc5 --lang=smtlib2.6 --incremental' --validate-goto-model --validate-ssa-equation" "-C" "-s" "new-smt-cvc5")
set_tests_properties(cbmc-incr-smt2-cvc5-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-incr-smt2" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/cbmc-incr-smt2/CMakeLists.txt;8;add_test_pl_profile;/src/regression/cbmc-incr-smt2/CMakeLists.txt;0;")
