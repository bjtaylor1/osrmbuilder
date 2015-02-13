#/!bin/bash

psql osm -c "select u.ru_def_des, u.ru_def_cod, u.ru_def_num, uc.description from urbanness u join urbanness_defs uc on u.ru_def_des = uc.ru_def_des where ST_Intersects(u.geom2, ST_Transform( ST_PointFromText('POINT($2 $1)',4326), 900913));"
