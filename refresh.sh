#!/bin/bash

set -e


#download country data
curl "http://download.geofabrik.de/europe/great-britain-latest.osm.pbf">great-britan-latest.osm.pbf
curl "http://download.geofabrik.de/europe/france-latest.osm.pbf">france-latest.osm.pbf

#import country data


#build osrm
./buildosrm.sh

#combine


#run
./preparedirectories.sh
