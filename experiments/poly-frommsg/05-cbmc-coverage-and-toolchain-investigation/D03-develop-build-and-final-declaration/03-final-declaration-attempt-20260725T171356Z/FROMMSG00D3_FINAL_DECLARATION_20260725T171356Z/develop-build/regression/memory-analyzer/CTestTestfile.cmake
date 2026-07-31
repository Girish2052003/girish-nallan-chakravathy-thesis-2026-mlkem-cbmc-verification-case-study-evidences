# CMake generated Testfile for 
# Source directory: /src/regression/memory-analyzer
# Build directory: /build/regression/memory-analyzer
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(memory-analyzer-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/memory-analyzer /build/bin/goto-gcc" "-C")
set_tests_properties(memory-analyzer-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/memory-analyzer" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;42;add_test_pl_profile;/src/regression/memory-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/memory-analyzer/CMakeLists.txt;0;")
add_test(memory-analyzer-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/memory-analyzer /build/bin/goto-gcc" "-T")
set_tests_properties(memory-analyzer-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/memory-analyzer" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;43;add_test_pl_profile;/src/regression/memory-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/memory-analyzer/CMakeLists.txt;0;")
add_test(memory-analyzer-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/memory-analyzer /build/bin/goto-gcc" "-F")
set_tests_properties(memory-analyzer-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/memory-analyzer" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;44;add_test_pl_profile;/src/regression/memory-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/memory-analyzer/CMakeLists.txt;0;")
add_test(memory-analyzer-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "../chain.sh    /build/bin/memory-analyzer /build/bin/goto-gcc" "-K")
set_tests_properties(memory-analyzer-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/memory-analyzer" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;45;add_test_pl_profile;/src/regression/memory-analyzer/CMakeLists.txt;1;add_test_pl_tests;/src/regression/memory-analyzer/CMakeLists.txt;0;")
