#!/bin/bash
set -e

for routetype in auk tourist; do
  echo Preparing $routetype
  rm -rf $routetype
  mkdir $routetype
  cp -r lualib $routetype
  cp -r luaspecifics $routetype
  cp $routetype.lua $routetype
  cp ../Project-OSRM/build/osrm-* $routetype
	
	cd $routetype
	ln -s ../countries.osm.pbf countries.osm.pbf
	./osrm-extract countries.osm.pbf -p $routetype.lua
	./osrm-prepare countries.osrm -p $routetype.lua
	cd ..
done

