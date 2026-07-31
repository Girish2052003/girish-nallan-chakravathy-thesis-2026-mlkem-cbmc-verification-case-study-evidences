# CMake generated Testfile for 
# Source directory: /src/regression/goto-interpreter
# Build directory: /build/regression/goto-interpreter
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-interpreter-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-interpreter/chain.sh /build/bin/goto-cc /build/bin/goto-instrument false" "-C")
set_tests_properties(goto-interpreter-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-interpreter" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-interpreter/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-interpreter/CMakeLists.txt;0;")
add_test(goto-interpreter-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-interpreter/chain.sh /build/bin/goto-cc /build/bin/goto-instrument false" "-T")
set_tests_properties(goto-interpreter-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-interpreter" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-interpreter/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-interpreter/CMakeLists.txt;0;")
add_test(goto-interpreter-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-interpreter/chain.sh /build/bin/goto-cc /build/bin/goto-instrument false" "-F")
set_tests_properties(goto-interpreter-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-interpreter" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-interpreter/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-interpreter/CMakeLists.txt;0;")
add_test(goto-interpreter-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-interpreter/chain.sh /build/bin/goto-cc /build/bin/goto-instrument false" "-K")
set_tests_properties(goto-interpreter-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-interpreter" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-interpreter/CMakeLists.txt;7;add_test_pl_tests;/src/regression/goto-interpreter/CMakeLists.txt;0;")
