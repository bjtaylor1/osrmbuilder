#!/bin/bash

set -e


#combine
osmosis --read-pbf file=great-britain-latest.osm.pbf --read-pbf file=ireland-and-northern-ireland-latest.osm.pbf --merge --write-pbf file=uk.osm.pbf
osmosis --read-pbf file=uk.osm.pbf --read-pbf file=france-latest.osm.pbf --merge --write-pbf file=countries.osm.pbf
