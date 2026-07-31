# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cbmc-shadow-memory
# Build directory: /workspace/build/regression/cbmc-shadow-memory
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-shadow-memory-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-C")
set_tests_properties(cbmc-shadow-memory-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
add_test(cbmc-shadow-memory-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-T")
set_tests_properties(cbmc-shadow-memory-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
add_test(cbmc-shadow-memory-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-F")
set_tests_properties(cbmc-shadow-memory-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
add_test(cbmc-shadow-memory-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-K")
set_tests_properties(cbmc-shadow-memory-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-shadow-memory" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-shadow-memory/CMakeLists.txt;0;")
