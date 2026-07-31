# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-library
# Build directory: /build/regression/cbmc-library
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-library-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-C")
set_tests_properties(cbmc-library-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-library" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-library/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-library/CMakeLists.txt;0;")
add_test(cbmc-library-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-T")
set_tests_properties(cbmc-library-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-library" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-library/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-library/CMakeLists.txt;0;")
add_test(cbmc-library-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-F")
set_tests_properties(cbmc-library-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-library" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-library/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-library/CMakeLists.txt;0;")
add_test(cbmc-library-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/build/bin/cbmc" "-K")
set_tests_properties(cbmc-library-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-library" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-library/CMakeLists.txt;2;add_test_pl_tests;/src/regression/cbmc-library/CMakeLists.txt;0;")
