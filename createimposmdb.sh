# run this as postgres user, eg:
# imposm-psqldb > create_db.sh; sudo su postgres; sh ./create_db.sh
set -x
createuser --no-superuser --no-createrole --createdb osm
createdb -E UTF8 -O osm osm

psql -d osm -f /usr/share/postgresql/10/contrib/postgis-2.4/postgis.sql 				# <- CHANGE THIS PATH
psql -d osm -f /usr/share/postgresql/10/contrib/postgis-2.4/spatial_ref_sys.sql 			# <- CHANGE THIS PATH
psql -d osm -f /usr/local/lib/python2.7/dist-packages/imposm/900913.sql
echo "ALTER TABLE geometry_columns OWNER TO osm;" | psql -d osm
echo "ALTER TABLE spatial_ref_sys OWNER TO osm;" | psql -d osm
echo "ALTER USER osm WITH PASSWORD 'osm';" |psql -d osm
#put "local  osm  osm  md5" in /etc/postgresql/10/main/pg_hba.conf 	# <- CHANGE THIS PATH
set +x
echo "Done. Don't forget to restart postgresql!"
