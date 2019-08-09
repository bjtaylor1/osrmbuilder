#!/bin/bash
set -e

export OSRM_RASTER_SOURCE=`pwd`/rasters/
for routetype in shortest optimum quickest urban; do
	
  echo Preparing $routetype
	rm -rf $routetype
	mkdir $routetype

	./preparedirectory.sh $routetype

  cd $routetype
  ln -s ../countries.osm.pbf countries.osm.pbf
  ./osrm-extract countries.osm.pbf -p $routetype.lua
  ./osrm-contract countries.osrm  
  cd ..
  
  
done

echo PrepareDirectoriesFinished
