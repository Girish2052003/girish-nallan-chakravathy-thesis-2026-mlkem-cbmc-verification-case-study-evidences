# CMake generated Testfile for 
# Source directory: /workspace/source/regression/cpp-linter
# Build directory: /workspace/build/regression/cpp-linter
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cpp-linter-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "../../../scripts/cpplint.py --repository=../../../" "-C")
set_tests_properties(cpp-linter-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cpp-linter" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;50;add_test_pl_profile;/workspace/source/regression/cpp-linter/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cpp-linter/CMakeLists.txt;0;")
add_test(cpp-linter-THOROUGH "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "../../../scripts/cpplint.py --repository=../../../" "-T")
set_tests_properties(cpp-linter-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cpp-linter" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;51;add_test_pl_profile;/workspace/source/regression/cpp-linter/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cpp-linter/CMakeLists.txt;0;")
add_test(cpp-linter-FUTURE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "../../../scripts/cpplint.py --repository=../../../" "-F")
set_tests_properties(cpp-linter-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cpp-linter" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;52;add_test_pl_profile;/workspace/source/regression/cpp-linter/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cpp-linter/CMakeLists.txt;0;")
add_test(cpp-linter-KNOWNBUG "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "../../../scripts/cpplint.py --repository=../../../" "-K")
set_tests_properties(cpp-linter-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/cpp-linter" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/CMakeLists.txt;53;add_test_pl_profile;/workspace/source/regression/cpp-linter/CMakeLists.txt;1;add_test_pl_tests;/workspace/source/regression/cpp-linter/CMakeLists.txt;0;")
