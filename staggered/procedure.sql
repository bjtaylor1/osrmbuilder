create or replace function staggered ()
returns void
as $$
declare 
	thecursor cursor for select way_id, ref from staggeredjunctions where way_id = 173688433;
	subcursor cursor (p_way_id integer, p_ref varchar(255)) is
		select distinct n.id, geom
		from nodes n
		join way_nodes wn on n.id = wn.node_id
		join way_nodes wn2 on n.id = wn.node_id
		join ways w2 on wn2.way_id = w2.id
		where wn.way_id = p_way_id
		and w2.ref = p_ref;


declare v_way_id int;
declare v_ref varchar(255);

begin
	open thecursor;
	loop
		fetch thecursor into v_way_id, v_ref;
		exit when not found;

		raise notice  'way_id = %, ref = %', v_way_id, v_ref;
		create temp table staggerednodes as 
		select distinct n.id, geom
		from nodes n
		join way_nodes wn on n.id = wn.node_id
		join way_nodes wn2 on n.id = wn.node_id
		join ways w2 on wn2.way_id = w2.id
		where wn.way_id = v_way_id
		and w2.ref = v_ref;

		if (select count(*) from staggerednodes) = 2 then
			raise notice 'it has got two rows!';
		end if;
		exit;
	end loop;
	close thecursor;
end; $$
language plpgsql;
