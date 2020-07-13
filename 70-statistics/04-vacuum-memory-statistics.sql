SELECT *
FROM
  (SELECT nspname schemaname,
          relname obj_name,
          array_to_string(relacl, ' ') acl
   FROM pg_class pgc
   JOIN pg_namespace pgn ON pgc.relnamespace=pgn.oid
   WHERE relkind IN ('v',
                     'r'))
WHERE acl LIKE '%&lt;username&gt;%';
