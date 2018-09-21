#/bin/bash
set -e
set -x

dropdb --if-exists osm
createdb osm

psql -d osm -c "create extension postgis;"
psql -d osm -c "create extension hstore;"

psql -d osm -f /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6.sql
psql -d osm -f /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6_bbox.sql
psql -d osm -f /usr/share/doc/osmosis/examples/pgsnapshot_schema_0.6_linestring.sql

osmosis --truncate-pgsql database=osm user=osm password=osm
osmosis --read-pbf rawdata.osm.pbf --log-progress --write-pgsql database=osm user=osm password=osm

# after import, change trunks to highway
# they have issues with lane_count being available
# (see logged issue for more info)
# psql -d osm -c "update ways set tags = tags || 'highway=>primary'::hstore where tags->'highway' = 'trunk'"

# psql -d osm -f staggered/procedure.sql
# psql -d osm -f staggered/process.sql

# psql -d osm -c "select staggered();"

# osmosis --read-pgsql database=osm user=osm password=osm --dataset-dump --write-pbf countries-processed.osm.pbf
