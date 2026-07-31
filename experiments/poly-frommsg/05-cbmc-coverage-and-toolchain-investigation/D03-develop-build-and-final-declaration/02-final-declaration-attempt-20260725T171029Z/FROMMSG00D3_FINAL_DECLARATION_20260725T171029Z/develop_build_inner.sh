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
  pkg-config \
  libxml2-dev \
  zlib1g-dev

rm -rf /build/*
cmake \
  -S /src \
  -B /build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release

cmake \
  --build /build \
  --target cbmc \
  --parallel 2

find /build -type f -name cbmc -perm -111 -print
