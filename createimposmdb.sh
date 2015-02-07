# run this as postgres user, eg:
# imposm-psqldb > create_db.sh; sudo su postgres; sh ./create_db.sh
set -x
createuser --no-superuser --no-createrole --createdb osm
createdb -E UTF8 -O osm osm
createlang plpgsql osm
psql -d osm -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql 				# <- CHANGE THIS PATH
psql -d osm -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql 			# <- CHANGE THIS PATH
psql -d osm -f /usr/local/lib/python2.7/dist-packages/imposm/900913.sql
echo "ALTER TABLE geometry_columns OWNER TO osm;" | psql -d osm
echo "ALTER TABLE spatial_ref_sys OWNER TO osm;" | psql -d osm
echo "ALTER USER osm WITH PASSWORD 'osm';" |psql -d osm
echo "host	osm	osm	127.0.0.1/32	md5" >> /etc/postgresql/9.3/main/pg_hba.conf 	# <- CHANGE THIS PATH
set +x
echo "Done. Don't forget to restart postgresql!"
