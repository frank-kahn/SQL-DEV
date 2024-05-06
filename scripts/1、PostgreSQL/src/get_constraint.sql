create schema IF NOT EXISTS  dba;
create view dba.get_constraint as 
select pgc.conname as constraint_name,
       ccu.table_schema as table_schema,
       ccu.table_name,
       ccu.column_name,
       pg_get_constraintdef(pgc.oid) as cons_def
from pg_constraint pgc
join pg_namespace nsp on nsp.oid = pgc.connamespace
join pg_class  cls on pgc.conrelid = cls.oid
left join information_schema.constraint_column_usage ccu
          on pgc.conname = ccu.constraint_name
          and nsp.nspname = ccu.constraint_schema
where
        nsp.nspname not in ('pg_catalog','information_schema','pg_toast')
--        and ccu.table_name = 'TABLE_NAME'
order by pgc.conname;
select * from dba.get_constraint;

create view dba.get_constraint2 as 
SELECT * FROM (  
    SELECT  
       c.connamespace::regnamespace::text as table_schema,  
       c.conrelid::regclass::text as table_name,  
       con.column_name,  
       c.conname as constraint_name,  
       pg_get_constraintdef(c.oid)  
    FROM  
        pg_constraint c  
    JOIN  
        pg_namespace ON pg_namespace.oid = c.connamespace  
    JOIN  
        pg_class ON c.conrelid = pg_class.oid  
    LEFT JOIN  
        information_schema.constraint_column_usage con ON  
        c.conname = con.constraint_name AND pg_namespace.nspname = con.constraint_schema     
    UNION ALL  
    SELECT  
        table_schema, table_name, column_name, NULL, 'NOT NULL'  
    FROM information_schema.columns  
    WHERE  
        is_nullable = 'NO'  
) all_constraints  
WHERE  
    table_schema NOT IN ('pg_catalog', 'information_schema')  
ORDER BY table_schema, table_name, column_name, constraint_name ;  
select * from dba.get_constraint2;
