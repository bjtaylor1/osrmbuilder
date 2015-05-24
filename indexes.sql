--drop them first cos they could be on old tables that imposm has renamed

drop index if exists osm_mainroads_ref;
drop index if exists osm_minorroads_ref;
drop index if exists osm_motorways_ref;
drop index if exists osm_mainroads_osm_id;
drop index if exists osm_minorroads_osm_id;
drop index if exists osm_motorways_osm_id;
drop index if exists urbanness_geometry;
drop index if exists urbanness_ru_def_des;
drop index if exists urbanness_defs_ru_def_des;

create index osm_mainroads_ref on osm_mainroads(ref);
create index osm_minorroads_ref on osm_minorroads(ref);
create index osm_motorways_ref on osm_motorways(ref);

create index osm_mainroads_osm_id on osm_mainroads(osm_id);
create index osm_minorroads_osm_id on osm_minorroads(osm_id);
create index osm_motorways_osm_id on osm_motorways(osm_id);

create index urbanness_ru_def_des on urbanness(ru_def_des);
create index urbanness_defs_ru_def_des on urbanness_defs(ru_def_des);

create index urbanness_geometry on urbanness using gist(geom2);
cluster urbanness using urbanness_geometry;
cluster urbanness_defs using urbanness_defs_ru_def_des;

vacuum analyze;


vacuum;

