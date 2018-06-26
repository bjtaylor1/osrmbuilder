#!/bin/bash
set -ex

curl "http://download.geofabrik.de/europe/$1.md5">$1.md5
md5sum -c $1.md5 | curl "http://download.geofabrik.de/europe/$1.osm.pbf">$1


