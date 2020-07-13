SELECT n.nspname::varchar(50) AS schemaname,
       c.relname::varchar(50) AS tablename,
       c.relowner::varchar(50) AS tableowner,
       t.spcname AS "tablespace",
       c.relhasindex AS hasindexes,
       c.relhasrules AS hasrules,
       (c.reltriggers > 0) AS hastriggers
FROM ((pg_class c
       LEFT JOIN pg_namespace n ON ((n.oid = c.relnamespace)))
      LEFT JOIN pg_tablespace t ON ((t.oid = c.reltablespace)))
WHERE (c.relkind = 'r'::"char");
