alter table ways add column ref varchar(255);
alter table ways add column junction varchar(255);

update ways set ref = tags->'ref';

update ways set junction = tags->'junction';
update ways set junction = '' where junction is null;
alter table ways alter column junction set  not null;

create index idx_ways_ref on ways(ref);
create index idx_ways_junction on ways(junction);

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
wn.way_id != wn2.way_id and
w.ref != w2.ref
group by wn.way_id, w.junction, w2.ref
having count(*) = 2
