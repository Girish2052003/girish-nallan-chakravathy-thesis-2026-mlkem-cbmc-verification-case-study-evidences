# CMake generated Testfile for 
# Source directory: /src/regression/libcprover-cpp/model_loading
# Build directory: /build/regression/libcprover-cpp/model_loading
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(model_loading-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/api-binary-driver" "-C")
set_tests_properties(model_loading-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/libcprover-cpp/model_loading" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;42;add_test_pl_profile;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;1;add_test_pl_tests;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;0;")
add_test(model_loading-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/api-binary-driver" "-T")
set_tests_properties(model_loading-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/libcprover-cpp/model_loading" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;43;add_test_pl_profile;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;1;add_test_pl_tests;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;0;")
add_test(model_loading-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/api-binary-driver" "-F")
set_tests_properties(model_loading-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/libcprover-cpp/model_loading" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;44;add_test_pl_profile;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;1;add_test_pl_tests;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;0;")
add_test(model_loading-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/api-binary-driver" "-K")
set_tests_properties(model_loading-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/libcprover-cpp/model_loading" _BACKTRACE_TRIPLES "/src/regression/libcprover-cpp/CMakeLists.txt;16;add_test;/src/regression/libcprover-cpp/CMakeLists.txt;45;add_test_pl_profile;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;1;add_test_pl_tests;/src/regression/libcprover-cpp/model_loading/CMakeLists.txt;0;")
