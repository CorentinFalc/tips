
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
