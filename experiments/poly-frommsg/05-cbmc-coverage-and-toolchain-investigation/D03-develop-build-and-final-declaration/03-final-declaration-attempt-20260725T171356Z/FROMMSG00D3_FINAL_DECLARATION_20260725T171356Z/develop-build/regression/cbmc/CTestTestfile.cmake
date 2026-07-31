# CMake generated Testfile for 
# Source directory: /src/regression/cbmc
# Build directory: /build/regression/cbmc
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-C" "-X" "smt-backend")
set_tests_properties(cbmc-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc/CMakeLists.txt;9;add_test_pl_tests;/src/regression/cbmc/CMakeLists.txt;0;")
add_test(cbmc-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-T" "-X" "smt-backend")
set_tests_properties(cbmc-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc/CMakeLists.txt;9;add_test_pl_tests;/src/regression/cbmc/CMakeLists.txt;0;")
add_test(cbmc-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-F" "-X" "smt-backend")
set_tests_properties(cbmc-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc/CMakeLists.txt;9;add_test_pl_tests;/src/regression/cbmc/CMakeLists.txt;0;")
add_test(cbmc-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --validate-goto-model --validate-ssa-equation" "-K" "-X" "smt-backend")
set_tests_properties(cbmc-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc/CMakeLists.txt;9;add_test_pl_tests;/src/regression/cbmc/CMakeLists.txt;0;")
add_test(cbmc-paths-lifo-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --paths lifo" "-C" "-X" "thorough-paths" "-X" "smt-backend" "-X" "paths-lifo-expected-failure" "-s" "paths-lifo")
set_tests_properties(cbmc-paths-lifo-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/cbmc/CMakeLists.txt;13;add_test_pl_profile;/src/regression/cbmc/CMakeLists.txt;0;")
add_test(cbmc-cprover-smt2-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --cprover-smt2" "-C" "-X" "broken-smt-backend" "-X" "thorough-smt-backend" "-X" "broken-cprover-smt-backend" "-X" "thorough-cprover-smt-backend" "-s" "cprover-smt2")
set_tests_properties(cbmc-cprover-smt2-CORE PROPERTIES  ENVIRONMENT "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/build/bin" LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/cbmc/CMakeLists.txt;20;add_test_pl_profile;/src/regression/cbmc/CMakeLists.txt;0;")
add_test(cbmc-new-smt-backend-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc --incremental-smt2-solver 'z3 --smt2 -in'" "-X" "no-new-smt" "-s" "new-smt-backend")
set_tests_properties(cbmc-new-smt-backend-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/cbmc/CMakeLists.txt;28;add_test_pl_profile;/src/regression/cbmc/CMakeLists.txt;0;")
