#!/bin/bash
set -e

cd ../osrm-backend
git pull
rm -f CMakeCache.txt
rm -rf build
mkdir build
cd build
cmake ..
make

