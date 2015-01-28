#!/bin/bash

set -e

./refreshsourcedata.sh monaco-latest
./refreshsourcedata.sh liechtenstein-latest

osmosis --read-pbf file=monaco-latest.osm.pbf --read-pbf file=liechtenstein-latest.osm.pbf \
					--merge --write-pbf file=countries.osm.pbf

#./dobuild.sh

./preparedirectories.sh


