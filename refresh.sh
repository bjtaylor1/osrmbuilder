#!/bin/bash

set -e


#download country data
./refreshsourcedata.sh "ireland-and-northern-ireland-latest.osm.pbf"
./refreshsourcedata.sh "great-britain-latest.osm.pbf"
./refreshsourcedata.sh "france-latest.osm.pbf"



