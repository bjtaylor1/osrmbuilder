#!/bin/bash

set -e

#refresh the data
./refreshsourcedata.sh great-britain-latest
./refreshsourcedata.sh france-latest
./refreshsourcedata.sh ireland-and-northern-ireland-latest

#merge britain and france together
osmosis --read-pbf file=great-britain-latest.osm.pbf --read-pbf file=ireland-and-northern-ireland-latest.osm.pbf --merge --write-pbf file=uk.osm.pbf
osmosis --read-pbf file=uk.osm.pbf --read-pbf file=france-latest.osm.pbf --merge --write-pbf file=countries.osm.pbf

#build osrm
./buildosrm.sh

#create a directory for each one, copies all the lua etc into it
./preparedirectories.sh


