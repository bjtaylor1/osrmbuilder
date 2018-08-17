alter table ways add column ref varchar(255);
alter table ways add column junction varchar(255);

update ways set ref = tags->'ref';

update ways set junction = tags->'junction';
update ways set junction = '' where junction is null;
alter table ways alter column junction set  not null;

create index idx_ways_ref on ways(ref);
create index idx_ways_junction on ways(junction);
