# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-orphan-solver
# Build directory: /build/regression/cbmc-orphan-solver
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-orphan-solver-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-orphan-solver/chain.sh" "-C")
set_tests_properties(cbmc-orphan-solver-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-orphan-solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-orphan-solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-orphan-solver/CMakeLists.txt;0;")
add_test(cbmc-orphan-solver-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-orphan-solver/chain.sh" "-T")
set_tests_properties(cbmc-orphan-solver-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-orphan-solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-orphan-solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-orphan-solver/CMakeLists.txt;0;")
add_test(cbmc-orphan-solver-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-orphan-solver/chain.sh" "-F")
set_tests_properties(cbmc-orphan-solver-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-orphan-solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-orphan-solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-orphan-solver/CMakeLists.txt;0;")
add_test(cbmc-orphan-solver-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-orphan-solver/chain.sh" "-K")
set_tests_properties(cbmc-orphan-solver-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-orphan-solver" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-orphan-solver/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-orphan-solver/CMakeLists.txt;0;")
