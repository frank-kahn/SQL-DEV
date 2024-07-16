DROP VIEW IF EXISTS tab_info_v CASCADE;
CREATE VIEW tab_info_v AS
WITH schemainfo AS (
	SELECT pg_namespace.oid
	      ,pg_namespace.nspname
	  FROM pg_namespace
)
,tbinfo AS (
	SELECT pg_class.oid
	      ,pg_class.relname
		  ,(col_description(pg_class.oid,0))::character varying AS comment
		  ,pg_class.relkind
		  ,pg_class.relnamespace
	  FROM pg_class
)
,colinfo AS (
	SELECT pg_attribute.attrelid
	      ,pg_attribute.attname
		  ,pg_attribute.attnum
		  ,(format_type(pg_attribute.atttypid,pg_attribute.atttypmod))::character varying AS typelen
		  ,(col_description(pg_attribute.attrelid,(pg_attribute.attnum)::integer))::character varying AS comment
	  FROM pg_attribute
)
SELECT schemainfo.nspname AS schema
      ,tbinfo.comment AS t_comment
	  ,tbinfo.relname AS table_name
	  ,colinfo.attname AS column_name
	  ,CASE
	     WHEN ((colinfo.typelen)::text = 'bigint'::text) THEN 'int8'::character varying
		 WHEN ((colinfo.typelen)::text = 'smallint'::text) THEN 'int2'::character varying
		 WHEN ((colinfo.typelen)::text = 'integer'::text) THEN 'int4'::character varying
		 WHEN ("left"((colinfo.typelen)::text,17) = 'character varying'::text) THEN (replace((colinfo.typelen)::text,'character varying'::text,'varchar'::text))::character varying
		 WHEN ("left"((colinfo.typelen)::text,9) = 'character'::text) THEN (replace((colinfo.typelen)::text,'character'::text,'char'::text))::character varying
		 ELSE colinfo.typelen
	   END AS type
	  ,colinfo.comment as c_comment
  FROM tbinfo
      ,colinfo
	  ,schemainfo
 WHERE 1=1
   AND (
         (tbinfo.oid     = colinfo.attrelid) 
	 AND (schemainfo.oid = tbinfo.relnamespace)
	 AND (schemainfo.nspname = CURRENT_SCHEMA)
	 AND (colinfo.attnum > 0)
	 AND (tbinfo.relkind = 'r'::"char")
	 AND (tbinfo.relname !~~'pg_%'::text)
	 AND (tbinfo.relname !~~'sql_%'::text)
	 AND (colinfo.attname !~~'%.....pg.dropped%'::text)
   )
;








