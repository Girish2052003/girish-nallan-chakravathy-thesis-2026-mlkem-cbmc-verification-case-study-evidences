# CMake generated Testfile for 
# Source directory: /src/regression/goto-synthesizer
# Build directory: /build/regression/goto-synthesizer
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(goto-synthesizer-CORE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-synthesizer/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/goto-synthesizer /build/bin/cbmc false" "-C")
set_tests_properties(goto-synthesizer-CORE PROPERTIES  LABELS "CORE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-synthesizer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;50;add_test_pl_profile;/src/regression/goto-synthesizer/CMakeLists.txt;15;add_test_pl_tests;/src/regression/goto-synthesizer/CMakeLists.txt;0;")
add_test(goto-synthesizer-THOROUGH "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-synthesizer/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/goto-synthesizer /build/bin/cbmc false" "-T")
set_tests_properties(goto-synthesizer-THOROUGH PROPERTIES  LABELS "THOROUGH;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-synthesizer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;51;add_test_pl_profile;/src/regression/goto-synthesizer/CMakeLists.txt;15;add_test_pl_tests;/src/regression/goto-synthesizer/CMakeLists.txt;0;")
add_test(goto-synthesizer-FUTURE "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-synthesizer/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/goto-synthesizer /build/bin/cbmc false" "-F")
set_tests_properties(goto-synthesizer-FUTURE PROPERTIES  LABELS "FUTURE;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-synthesizer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;52;add_test_pl_profile;/src/regression/goto-synthesizer/CMakeLists.txt;15;add_test_pl_tests;/src/regression/goto-synthesizer/CMakeLists.txt;0;")
add_test(goto-synthesizer-KNOWNBUG "perl" "/src/regression/test.pl" "-e" "-p" "-c" "/src/regression/goto-synthesizer/chain.sh /build/bin/goto-cc /build/bin/goto-instrument /build/bin/goto-synthesizer /build/bin/cbmc false" "-K")
set_tests_properties(goto-synthesizer-KNOWNBUG PROPERTIES  LABELS "KNOWNBUG;CBMC" TIMEOUT "1200" WORKING_DIRECTORY "/src/regression/goto-synthesizer" _BACKTRACE_TRIPLES "/src/regression/CMakeLists.txt;4;add_test;/src/regression/CMakeLists.txt;53;add_test_pl_profile;/src/regression/goto-synthesizer/CMakeLists.txt;15;add_test_pl_tests;/src/regression/goto-synthesizer/CMakeLists.txt;0;")
