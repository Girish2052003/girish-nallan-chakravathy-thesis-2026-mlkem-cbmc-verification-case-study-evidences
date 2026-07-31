# CMake generated Testfile for 
# Source directory: /workspace/source/regression/ansi-c
# Build directory: /workspace/build/regression/ansi-c
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(ansi-c-gcc-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-cc --native-compiler gcc" "-C" "-X" "fake-gcc-version" "-X" "clang-only" "-s" "ansi-c-gcc")
set_tests_properties(ansi-c-gcc-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/ansi-c" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/ansi-c/CMakeLists.txt;28;add_test_pl_profile;/workspace/source/regression/ansi-c/CMakeLists.txt;0;")
add_test(ansi-c-fake-gcc-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-cc" "-C" "-I" "fake-gcc-version" "-s" "ansi-c-fake-gcc")
set_tests_properties(ansi-c-fake-gcc-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/ansi-c" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/ansi-c/CMakeLists.txt;34;add_test_pl_profile;/workspace/source/regression/ansi-c/CMakeLists.txt;0;")
add_test(ansi-c-c++-front-end-CORE "perl" "/workspace/source/regression/test.pl" "-e" "-p" "-c" "/workspace/build/bin/goto-cc -xc++ -D_Bool=bool" "-C" "-I" "test-c++-front-end" "-s" "c++-front-end")
set_tests_properties(ansi-c-c++-front-end-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/workspace/source/regression/ansi-c" _BACKTRACE_TRIPLES "/workspace/source/regression/CMakeLists.txt;4;add_test;/workspace/source/regression/ansi-c/CMakeLists.txt;46;add_test_pl_profile;/workspace/source/regression/ansi-c/CMakeLists.txt;0;")
