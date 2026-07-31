# CMake generated Testfile for 
# Source directory: /workspace/source/regression/invariants
# Build directory: /workspace/build/regression/invariants
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(invariants-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/driver" "-C")
set_tests_properties(invariants-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/invariants" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/workspace/source/regression/invariants/CMakeLists.txt;0;")
add_test(invariants-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/driver" "-T")
set_tests_properties(invariants-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/invariants" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/workspace/source/regression/invariants/CMakeLists.txt;0;")
add_test(invariants-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/driver" "-F")
set_tests_properties(invariants-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/invariants" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/workspace/source/regression/invariants/CMakeLists.txt;0;")
add_test(invariants-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/driver" "-K")
set_tests_properties(invariants-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/invariants" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/invariants/CMakeLists.txt;4;add_test_pl_tests;/workspace/source/regression/invariants/CMakeLists.txt;0;")
