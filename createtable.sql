
create table busyness(
	ref character varying(255) not null
,	category character (2) not null
, ScorePC int not null
,Score2WMV int not null
,ScoreCar int not null
,ScoreBUS int not null
,ScoreLGV int not null
,ScoreHGVR2 int not null
,ScoreHGVR3 int not null
,ScoreHGVR4 int not null
,ScoreHGVA3 int not null
,ScoreHGVA5 int not null
,ScoreHGVA6 int not null
,ScoreHGV int not null
,ScoreAll_MV int not null
);

select AddGeometryColumn('busyness', 'geometry', 900913, 'polygon', 2);

alter table busyness alter column "geometry" set not null;


