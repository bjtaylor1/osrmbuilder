#/!bin/bash

set -e

#download urbanness data from the government!
mkdir urbannessdata
cd urbannessdata
../downloadurbandata.sh
for z in *.zip; do unzip $z; done
../importurbannessdata.sh

#download country data
wget http://download.geofabrik.de/europe/great-britain-latest.osm.pbf
wget http://download.geofabrik.de/europe/france-latest.osm.pbf
