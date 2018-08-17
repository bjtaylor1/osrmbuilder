create or replace function staggered ()
returns void
as $$
declare cursor thecursor for
select wn.way_id as way_id,
    w2.ref,
    count(*) as count
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
having count(*) > 1;

begin

end; $$
language plpgsql;
