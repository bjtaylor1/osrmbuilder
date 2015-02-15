#/!bin/bash

set -e

#download urbanness data from the government
#https://www.gov.uk/government/statistical-data-sets/local-enterprise-partnerships-leps-rural-urban-gis-shapefiles
mkdir -p urbannessdata && cd urbannessdata
../downloadurbandata.sh
for z in *.zip; do unzip $z; done
../importurbannessdata.sh
cd ..

#download scottish urbanness data:
mkdir -p urbannessdata_scotland && cd urbannessdata_scotland
curl http://www.scotland.gov.uk/Resource/0039/00399160.zip>scotland.zip
unzip scotland.zip
shp2pgsql -s 27700 SGUR_2011_2012_HWM.shp scotland | psql osm
psql osm -c "insert into urbanness(ru_def_des, geom2) select 'U_CT', ST_Transform(geom, 900913) from scotland where ur6fold = 1"

