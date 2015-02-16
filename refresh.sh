#!/bin/bash

set -e


#download country data
curl "http://download.geofabrik.de/europe/great-britain-latest.osm.pbf">great-britain-latest.osm.pbf
curl "http://download.geofabrik.de/europe/france-latest.osm.pbf">france-latest.osm.pbf

#import country data
imposm --read --write --optimize --deploy-production-tables great-britain-latest.osm.pbf -d osm

#combine
osmosis --read-pbf file=great-britain-latest.osm.pbf --read-pbf file=france-latest.osm.pbf --merge --write-pbf file=countries.osm.pbf

#build osrm
./buildosrm.sh

#run
./preparedirectories.sh
