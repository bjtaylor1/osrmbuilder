#!/bin/bash

cd ..
rm -rf Project-OSRM
git clone https://github.com/Project-OSRM/osrm-backend Project-OSRM --branch master

cd Project-OSRM
rm -f CMakeCache.txt
rm -rf build
mkdir build
cd build
cmake ..
make

