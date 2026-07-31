# CMake generated Testfile for 
# Source directory: /src/regression/cbmc-output-file
# Build directory: /build/regression/cbmc-output-file
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(cbmc-output-file-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-output-file/chain.py /build/bin/cbmc" "-C" "-f")
set_tests_properties(cbmc-output-file-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-output-file" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/cbmc-output-file/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-output-file/CMakeLists.txt;0;")
add_test(cbmc-output-file-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-output-file/chain.py /build/bin/cbmc" "-T" "-f")
set_tests_properties(cbmc-output-file-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-output-file" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/cbmc-output-file/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-output-file/CMakeLists.txt;0;")
add_test(cbmc-output-file-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-output-file/chain.py /build/bin/cbmc" "-F" "-f")
set_tests_properties(cbmc-output-file-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-output-file" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/cbmc-output-file/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-output-file/CMakeLists.txt;0;")
add_test(cbmc-output-file-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/cbmc-output-file/chain.py /build/bin/cbmc" "-K" "-f")
set_tests_properties(cbmc-output-file-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/cbmc-output-file" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/cbmc-output-file/CMakeLists.txt;1;add_test_pl_tests;/src/regression/cbmc-output-file/CMakeLists.txt;0;")
