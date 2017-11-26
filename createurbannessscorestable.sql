select r.osm_id, min(ud.score) as score into urbannessscores from urbanness u join urbanness_defs ud on u.ru_def_des = ud.ru_def_des join osm_roads r on ST_Intersects(r.geometry, u.geom2) group by r.osm_id;

alter table urbannessscores add constraint urbannessscores_pkey primary key (osm_id);

cluster urbannessscores using urbannessscores_pkey;
