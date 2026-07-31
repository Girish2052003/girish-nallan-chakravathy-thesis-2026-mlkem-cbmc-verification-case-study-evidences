#!/usr/bin/env bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  cmake \
  ninja-build \
  flex \
  bison \
  git \
  curl \
  patch \
  pkg-config \
  libxml2-dev \
  zlib1g-dev

rm -rf /workspace/source /workspace/build
mkdir -p /workspace/source /workspace/build

# CBMC's ANSI-C library check creates temporary files in the source tree.
# Keep the authoritative checkout read-only and build from an exact writable copy.
cp -a /src_ro/. /workspace/source/

echo "COPIED_SOURCE_COMMIT=$(git -C /workspace/source rev-parse HEAD)"
echo "COPIED_SOURCE_TREE=$(git -C /workspace/source rev-parse 'HEAD^{tree}')"

cmake \
  -S /workspace/source \
  -B /workspace/build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_JBMC=OFF

cmake \
  --build /workspace/build \
  --target cbmc \
  --parallel 2

echo "COPIED_SOURCE_STATUS_BEGIN"
git -C /workspace/source status --porcelain
echo "COPIED_SOURCE_STATUS_END"

find /workspace/build -type f -name cbmc -perm -111 -print
