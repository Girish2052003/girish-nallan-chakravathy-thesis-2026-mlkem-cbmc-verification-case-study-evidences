# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cbmc-with-incr
# Build directory: /workspace/build/regression/cbmc-with-incr
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-with-incr-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --incremental" "-C")
set_tests_properties(cbmc-with-incr-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-with-incr" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;0;")
add_test(cbmc-with-incr-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --incremental" "-T")
set_tests_properties(cbmc-with-incr-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-with-incr" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;0;")
add_test(cbmc-with-incr-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --incremental" "-F")
set_tests_properties(cbmc-with-incr-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-with-incr" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;0;")
add_test(cbmc-with-incr-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc --incremental" "-K")
set_tests_properties(cbmc-with-incr-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-with-incr" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-with-incr/CMakeLists.txt;0;")
