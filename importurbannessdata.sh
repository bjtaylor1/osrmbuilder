#!/bin/bash

set -e

psql osm -f ../urbanness.sql

for s in *.shp; do
echo $s
shp2pgsql -a -s 27700 $s urbanness | psql osm > $s.log 2> >(tee $s.errlog >&2)
done

psql osm -c "update urbanness set geom2 = ST_Transform(geom, 900913);"
psql osm -c "create index urbanness_geometry on public.urbanness using gist(geom2);"
psql osm -c "select dropgeometrycolumn('urbanness', 'geom');"



