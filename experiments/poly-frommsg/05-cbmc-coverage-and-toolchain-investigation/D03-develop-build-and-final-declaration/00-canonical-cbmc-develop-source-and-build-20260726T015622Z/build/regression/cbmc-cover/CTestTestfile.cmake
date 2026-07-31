# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cbmc-cover
# Build directory: /workspace/build/regression/cbmc-cover
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-cover-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-C")
set_tests_properties(cbmc-cover-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-cover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/cbmc-cover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-cover/CMakeLists.txt;0;")
add_test(cbmc-cover-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-T")
set_tests_properties(cbmc-cover-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-cover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/cbmc-cover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-cover/CMakeLists.txt;0;")
add_test(cbmc-cover-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-F")
set_tests_properties(cbmc-cover-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-cover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/cbmc-cover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-cover/CMakeLists.txt;0;")
add_test(cbmc-cover-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/cbmc" "-K")
set_tests_properties(cbmc-cover-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cbmc-cover" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/cbmc-cover/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cbmc-cover/CMakeLists.txt;0;")
