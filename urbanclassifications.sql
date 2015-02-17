drop table if exists urbanness_defs;

create table urbanness_defs(
ru_def_des character varying(254) not null primary key
, description character varying(256) not null
, score float not null
);



insert into urbanness_defs(ru_def_des, description, score) values
  ('R_TF', 'Rural: Town and Fringe', 1.0 )
, ('R_TF_S', 'Rural: Town and Fringe, Sparse', 1.0)
, ('U_CT', 'Urban: City and Town', 0.5)
, ('U_CT_S', 'Urban: City and Town, Sparse', 0.5 )
, ('R_HD', 'Rural: Hamlets and Dwellings', 1.0)
, ('R_HD_S', 'Urban: Hamlets and Dwellings, Sparse', 0.5)
, ('U_MJ_C', 'Urban: Major connurbation', 0.5)
, ('U_MN_C', 'Urban: Minor Connurbation', 0.5)
, ('R_V', 'Rural: Village', 1.0)
, ('R_V_S', 'Rural: Village, Sparse', 1.0)
;

