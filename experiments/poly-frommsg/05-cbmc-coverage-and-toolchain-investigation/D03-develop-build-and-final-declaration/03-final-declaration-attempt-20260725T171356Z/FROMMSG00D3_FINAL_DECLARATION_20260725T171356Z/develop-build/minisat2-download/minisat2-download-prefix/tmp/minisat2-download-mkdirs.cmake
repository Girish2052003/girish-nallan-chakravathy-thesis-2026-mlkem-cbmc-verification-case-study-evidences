# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/build/minisat2-src"
  "/build/minisat2-build"
  "/build/minisat2-download/minisat2-download-prefix"
  "/build/minisat2-download/minisat2-download-prefix/tmp"
  "/build/minisat2-download/minisat2-download-prefix/src/minisat2-download-stamp"
  "/build/minisat2-download/minisat2-download-prefix/src"
  "/build/minisat2-download/minisat2-download-prefix/src/minisat2-download-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/build/minisat2-download/minisat2-download-prefix/src/minisat2-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/build/minisat2-download/minisat2-download-prefix/src/minisat2-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
