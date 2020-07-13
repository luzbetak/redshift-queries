SELECT *
FROM
  (SELECT nspname,
          nspowner,
          array_to_string(nspacl, ' ') acl
   FROM pg_namespace)
WHERE acl LIKE '%&lt;username&gt;%';
