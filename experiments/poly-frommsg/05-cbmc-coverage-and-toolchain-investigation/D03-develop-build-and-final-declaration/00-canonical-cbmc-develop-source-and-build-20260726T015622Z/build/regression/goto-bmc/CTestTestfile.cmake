# CMake generated Testfile for 
# Source directory: /workspace/source/regression/goto-bmc
# Build directory: /workspace/build/regression/goto-bmc
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-bmc-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-bmc" "-C")
set_tests_properties(goto-bmc-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-bmc" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-bmc/CMakeLists.txt;0;")
add_test(goto-bmc-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-bmc" "-T")
set_tests_properties(goto-bmc-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-bmc" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-bmc/CMakeLists.txt;0;")
add_test(goto-bmc-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-bmc" "-F")
set_tests_properties(goto-bmc-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-bmc" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-bmc/CMakeLists.txt;0;")
add_test(goto-bmc-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-bmc" "-K")
set_tests_properties(goto-bmc-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/goto-bmc" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/goto-bmc/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/goto-bmc/CMakeLists.txt;0;")
