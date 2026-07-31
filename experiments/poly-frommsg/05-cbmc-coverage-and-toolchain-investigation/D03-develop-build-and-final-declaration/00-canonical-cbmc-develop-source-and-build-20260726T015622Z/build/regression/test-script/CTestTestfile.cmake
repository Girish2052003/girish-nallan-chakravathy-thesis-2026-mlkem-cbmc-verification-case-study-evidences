# CMake generated Testfile for 
# Source directory: /workspace/source/regression/test-script
# Build directory: /workspace/build/regression/test-script
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(test-script-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/source/regression/test-script/program_runner.sh" "-C")
set_tests_properties(test-script-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/test-script" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/test-script/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/test-script/CMakeLists.txt;0;")
add_test(test-script-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/source/regression/test-script/program_runner.sh" "-T")
set_tests_properties(test-script-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/test-script" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/test-script/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/test-script/CMakeLists.txt;0;")
add_test(test-script-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/source/regression/test-script/program_runner.sh" "-F")
set_tests_properties(test-script-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/test-script" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/test-script/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/test-script/CMakeLists.txt;0;")
add_test(test-script-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/source/regression/test-script/program_runner.sh" "-K")
set_tests_properties(test-script-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/test-script" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/test-script/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/test-script/CMakeLists.txt;0;")
