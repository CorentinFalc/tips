
	--Sélection des champs avec commentaire
SELECT c.table_schema,c.table_name,c.column_name,pgd.description
FROM pg_catalog.pg_statio_all_tables as st
  LEFT join pg_catalog.pg_description pgd on (pgd.objoid=st.relid)
  LEFT join information_schema.columns c on (pgd.objsubid=c.ordinal_position
  and c.table_schema=st.schemaname and c.table_name=st.relname)

   order by table_name;



	--Difference efficace
Create materialized view sandbox.vm_mos_2015_rest_v2t as
with tmp as (
  select b.gid, st_union(a.geom) as geom
  from sandbox.vm_mos_2015_parcellaire b 
  join sandbox.vm_geo_parc_subd_for_comp a on st_intersects(a.geom, b.new_geom)
  group by b.gid
) select b.gid, st_difference(b.new_geom,coalesce(t.geom, 'GEOMETRYCOLLECTION EMPTY'::geometry)) as newgeom
from sandbox.vm_mos_2015_parcellaire b left join tmp t on b.gid = t.gid;

						  
						  
	--Commit during a function
drop table data_corentin.test_function ;
create table data_corentin.test_function 
(
	oid serial,
	libell varchar,
	constraint pk_test_function primary key (oid)
);

DO 
LANGUAGE plpgsql
$BODY$
    DECLARE
	v_test varchar = 'Bonjour';
    BEGIN
	For i in 1..100000 LOOP
	raise notice '%', i;
		PERFORM dblink_connect('dblk','dbname=sandbox');
		PERFORM dblink('dblk', format('INSERT INTO data_corentin.test_function(libell) values (''%1$s'')', v_test));
		PERFORM dblink('dblk','COMMIT;');
		PERFORM dblink_disconnect('dblk'); 
	END LOOP;
    END;
$BODY$;
					      
	--Update commune from spatial intersection
update sandbox.mos_payb_prod3_clean x 
set code_insee = y.code_insee, nom_commune = y.nom
From data_exo.communes_pays_brest_bd_topo_2017 y where st_intersects(st_pointonsurface(x.geom), y.geom);
					      
	--REset sequence
ALTER SEQUENCE seq RESTART WITH 1;
UPDATE t SET idcolumn=nextval('seq');
