select wn.way_id as way_id,
    wn.node_id,
    wn2.node_id,
    w2.ref
from ways w 
join  way_nodes wn on w.id = wn.way_id 
join nodes n on wn.node_id = n.id
join way_nodes wn2 on wn.node_id = wn2.node_id 
join ways w2 on wn2.way_id = w2.id
where 
w.junction != 'roundabout' and
wn.way_id != wn2.way_id and 
w.ref != w2.ref and
wn.way_id = 5205712

-- rock hill: 173688433