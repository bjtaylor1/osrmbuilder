alter table ways add column ref varchar(255);
alter table ways add column junction varchar(255);
alter table ways add column highway varchar(255);
alter table ways add column source_way_id bigint;

update ways set ref = tags->'ref';
update ways set junction = tags->'junction';
update ways set junction = '' where junction is null;

update ways set highway = tags->'highway';
update ways set highway = '' where highway is null;

alter table ways alter column junction set not null;
alter table ways alter column highway set not null;

create index idx_ways_ref on ways(ref);
create index idx_ways_junction on ways(junction);
create index idx_ways_highway on ways(highway);
create index idx_way_nodes_way_id on way_nodes(way_id);

select wn.way_id as way_id,
    w2.ref
into staggeredjunctions
from ways w
join  way_nodes wn on w.id = wn.way_id
join nodes n on wn.node_id = n.id
join way_nodes wn2 on wn.node_id = wn2.node_id
join ways w2 on wn2.way_id = w2.id
where
w.junction != 'roundabout' and
w.highway != 'trunk_link' and
w.highway != 'primary_link' and
w.hidhway != '' and
wn.way_id != wn2.way_id and
w.ref != w2.ref
group by wn.way_id, w.junction, w2.ref
having count(*) = 2;

