SET CLIENT_ENCODING TO UTF8;
SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
DROP TABLE IF EXISTS "urbanness";

CREATE TABLE "urbanness" (gid serial,
"oa11cd" varchar(9),
"lad11cd" varchar(254),
"lad11nm" varchar(254),
"area_hect" varchar(254),
"area_hec_1" varchar(254),
"ru_def_des" varchar(254),
"ru_def_cod" varchar(254),
"oid_" int4,
"oa11cd_1" varchar(9),
"lep" varchar(254),
"ru_def_num" numeric
);
ALTER TABLE "urbanness" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','urbanness','geom','27700','MULTIPOLYGON',2);
SELECT AddGeometryColumn('','urbanness','geom2','900913','MULTIPOLYGON',2);
COMMIT;
