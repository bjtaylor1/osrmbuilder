#!/bin/bash

cd ..
rm -rf Project-OSRM
git clone https://github.com/Project-OSRM/osrm-backend Project-OSRM --branch master

cd Project-OSRM
git remote add mine https://github.com/bjtaylor1/osrm-backend
git pull mine master

rm -f CMakeCache.txt
rm -rf build
mkdir build
cd build
cmake ..
make

