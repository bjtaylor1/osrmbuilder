#!/bin/bash

set -e

./refreshsourcedata.sh great-britain-latest
./refreshsourcedata.sh france-latest

osmosis --read-pbf file=great-britain-latest.osm.pbf --read-pbf file=france-latest.osm.pbf \
					--merge --write-pbf file=countries.osm.pbf

./dobuild.sh

./preparedirectories.sh


