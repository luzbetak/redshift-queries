SELECT n.nspname::varchar(50),
       c.relname::varchar(50),
       c.relowner,
       u.usename::varchar(50),
       t.spcname::varchar(50),
       c.relhasindex,
       c.relhasrules,
       (c.reltriggers > 0) AS hastriggers
FROM ((pg_class c
       LEFT JOIN pg_namespace n ON ((n.oid = c.relnamespace)))
      LEFT JOIN pg_tablespace t ON ((t.oid = c.reltablespace))
      LEFT JOIN
        (SELECT usename,
                usesysid
         FROM pg_user) u ON (c.relowner=u.usesysid))
WHERE (c.relkind = 'r'::"char");
