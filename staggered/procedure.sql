create or replace function staggered ()
returns void
as $$
declare	thecursor cursor for select way_id, ref from staggeredjunctions;-- where way_id = 173688433;
v_way_id int;
v_ref varchar(255);
nodeid1 bigint;
nodeid2 bigint;
geom1 geometry;
geom2 geometry;
newwayline geometry;
newwaybbox geometry;
newwaytags hstore;
nodescursor refcursor;
distance float;
newwayid int;
nodecount int;

begin
	drop table if exists staggerednodes;
	create temporary table staggerednodes(id bigint, geom geometry);

	delete from ways where source_way_id is not null;
	open thecursor;
	loop
		fetch thecursor into v_way_id, v_ref;

		exit when not found;

		truncate table staggerednodes;
		-- we want exactly two nodes, BOTH of which...
		insert into staggerednodes(id, geom)
		select n.id, geom
		    from nodes n
		    where exists (select * from way_nodes wn1 -- ... intersect with the target way (the 'main' road)...
			where wn1.way_id = v_way_id 
			and wn1.node_id = n.id)
		    and exists (select * from way_nodes wn2 -- ... and also intersect with the ref (the 'crossing' road).
		        join ways w on wn2.way_id = w.id 
		        where w.ref = v_ref 
		        and wn2.node_id = n.id);

		if (select count(*) from staggerednodes) = 2 then
			open nodescursor for select id, geom from staggerednodes;
			fetch nodescursor into nodeid1, geom1;
		        fetch nodescursor into nodeid2, geom2;
			close nodescursor;

			distance = ST_DistanceSphere(geom1, geom2);

			if distance < 50 then

				newwaytags = (select tags from ways where id = v_way_id);
				newwaytags = newwaytags || 'highway=>secondary'::hstore;
				newwayline = ST_MakeLine(geom1, geom2);
				newwaybbox = ST_Envelope(newwayline);
				insert into ways(version, user_id, tstamp, changeset_id, tags, nodes, bbox, linestring, ref, junction, source_way_id)
				select version, user_id, tstamp, changeset_id, newwaytags, ARRAY[nodeid1, nodeid2], newwaybbox, newwayline, ref, '', v_way_id from ways where id = v_way_id;

				raise notice  'way_id = %, ref = %, nodeid1 = %, nodeid2 = %', v_way_id, v_ref, nodeid1, nodeid2;

			end if;
		end if;
	end loop;
	close thecursor;
end; $$
language plpgsql;
