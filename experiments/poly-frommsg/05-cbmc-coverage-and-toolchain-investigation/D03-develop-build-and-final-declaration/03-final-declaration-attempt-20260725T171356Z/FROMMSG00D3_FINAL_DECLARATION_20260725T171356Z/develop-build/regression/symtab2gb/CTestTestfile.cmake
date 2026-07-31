# CMake generated Testfile for 
# Source directory: /src/regression/symtab2gb
# Build directory: /build/regression/symtab2gb
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(symtab2gb-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/symtab2gb/chain.sh /build/bin/symtab2gb /build/bin/cbmc" "-C")
set_tests_properties(symtab2gb-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/symtab2gb" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/symtab2gb/CMakeLists.txt;1;add_test_pl_tests;/src/regression/symtab2gb/CMakeLists.txt;0;")
add_test(symtab2gb-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/symtab2gb/chain.sh /build/bin/symtab2gb /build/bin/cbmc" "-T")
set_tests_properties(symtab2gb-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/symtab2gb" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/symtab2gb/CMakeLists.txt;1;add_test_pl_tests;/src/regression/symtab2gb/CMakeLists.txt;0;")
add_test(symtab2gb-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/symtab2gb/chain.sh /build/bin/symtab2gb /build/bin/cbmc" "-F")
set_tests_properties(symtab2gb-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/symtab2gb" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/symtab2gb/CMakeLists.txt;1;add_test_pl_tests;/src/regression/symtab2gb/CMakeLists.txt;0;")
add_test(symtab2gb-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/symtab2gb/chain.sh /build/bin/symtab2gb /build/bin/cbmc" "-K")
set_tests_properties(symtab2gb-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/symtab2gb" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/symtab2gb/CMakeLists.txt;1;add_test_pl_tests;/src/regression/symtab2gb/CMakeLists.txt;0;")
