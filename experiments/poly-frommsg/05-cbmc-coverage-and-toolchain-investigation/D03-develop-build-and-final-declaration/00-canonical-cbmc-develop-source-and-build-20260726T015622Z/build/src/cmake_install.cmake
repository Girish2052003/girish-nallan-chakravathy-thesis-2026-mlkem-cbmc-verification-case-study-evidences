# Install script for directory: /workspace/source/src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/workspace/build/src/analyses/cmake_install.cmake")
  include("/workspace/build/src/ansi-c/cmake_install.cmake")
  include("/workspace/build/src/assembler/cmake_install.cmake")
  include("/workspace/build/src/big-int/cmake_install.cmake")
  include("/workspace/build/src/cpp/cmake_install.cmake")
  include("/workspace/build/src/xmllang/cmake_install.cmake")
  include("/workspace/build/src/goto-checker/cmake_install.cmake")
  include("/workspace/build/src/goto-programs/cmake_install.cmake")
  include("/workspace/build/src/goto-symex/cmake_install.cmake")
  include("/workspace/build/src/goto-inspect/cmake_install.cmake")
  include("/workspace/build/src/json/cmake_install.cmake")
  include("/workspace/build/src/json-symtab-language/cmake_install.cmake")
  include("/workspace/build/src/langapi/cmake_install.cmake")
  include("/workspace/build/src/linking/cmake_install.cmake")
  include("/workspace/build/src/pointer-analysis/cmake_install.cmake")
  include("/workspace/build/src/solvers/cmake_install.cmake")
  include("/workspace/build/src/statement-list/cmake_install.cmake")
  include("/workspace/build/src/util/cmake_install.cmake")
  include("/workspace/build/src/cbmc/cmake_install.cmake")
  include("/workspace/build/src/cprover/cmake_install.cmake")
  include("/workspace/build/src/crangler/cmake_install.cmake")
  include("/workspace/build/src/goto-cc/cmake_install.cmake")
  include("/workspace/build/src/goto-instrument/cmake_install.cmake")
  include("/workspace/build/src/goto-analyzer/cmake_install.cmake")
  include("/workspace/build/src/goto-diff/cmake_install.cmake")
  include("/workspace/build/src/goto-harness/cmake_install.cmake")
  include("/workspace/build/src/goto-synthesizer/cmake_install.cmake")
  include("/workspace/build/src/symtab2gb/cmake_install.cmake")
  include("/workspace/build/src/libcprover-cpp/cmake_install.cmake")
  include("/workspace/build/src/goto-bmc/cmake_install.cmake")
  include("/workspace/build/src/memory-analyzer/cmake_install.cmake")

endif()

