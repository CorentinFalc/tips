
	--Sélection des champs avec commentaire
SELECT c.table_schema,c.table_name,c.column_name,pgd.description
FROM pg_catalog.pg_statio_all_tables as st
  LEFT join pg_catalog.pg_description pgd on (pgd.objoid=st.relid)
  LEFT join information_schema.columns c on (pgd.objsubid=c.ordinal_position
  and c.table_schema=st.schemaname and c.table_name=st.relname)

   order by table_name;
