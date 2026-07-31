# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cbmc-incr-smt2
# Build directory: /workspace/build/regression/cbmc-incr-smt2
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-incr-smt2-z3-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --incremental-smt2-solver 'z3 --smt2 -in' --validate-goto-model --validate-ssa-equation" "-C" "-s" "new-smt-z3")
set_tests_properties(cbmc-incr-smt2-z3-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-incr-smt2" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/cbmc-incr-smt2/CMakeLists.txt;1;add_test_pl_profile;/workspace/source/regression/cbmc-incr-smt2/CMakeLists.txt;0;")
add_test(cbmc-incr-smt2-cvc5-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --incremental-smt2-solver 'cvc5 --lang=smtlib2.6 --incremental' --validate-goto-model --validate-ssa-equation" "-C" "-s" "new-smt-cvc5")
set_tests_properties(cbmc-incr-smt2-cvc5-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-incr-smt2" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/cbmc-incr-smt2/CMakeLists.txt;8;add_test_pl_profile;/workspace/source/regression/cbmc-incr-smt2/CMakeLists.txt;0;")
