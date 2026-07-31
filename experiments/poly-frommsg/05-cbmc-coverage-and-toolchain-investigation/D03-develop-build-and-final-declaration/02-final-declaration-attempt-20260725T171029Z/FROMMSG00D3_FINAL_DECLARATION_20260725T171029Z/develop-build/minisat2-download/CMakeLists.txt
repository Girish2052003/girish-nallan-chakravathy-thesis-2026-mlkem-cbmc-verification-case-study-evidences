# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.8)

project(minisat2-download NONE)

include(ExternalProject)
ExternalProject_Add(minisat2-download
                    URL;http://ftp.debian.org/debian/pool/main/m/minisat2/minisat2_2.2.1.orig.tar.gz;PATCH_COMMAND;patch;-p1;-i;/src/scripts/minisat-2.2.1-patch;COMMAND;cmake;-E;copy;/src/scripts/minisat2_CMakeLists.txt;CMakeLists.txt;URL_MD5;27faa19ee0508660bd6fb7f894646d42
                    SOURCE_DIR          "/build/minisat2-src"
                    BINARY_DIR          "/build/minisat2-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
