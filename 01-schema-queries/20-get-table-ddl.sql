SELECT ddl
FROM
  (SELECT table_id,
          REGEXP_REPLACE (schemaname,
                          '^zzzzzzzz',
                          '') AS schemaname,
                         REGEXP_REPLACE (tablename,
                                         '^zzzzzzzz',
                                         '') AS tablename,
                                        seq,
                                        ddl
   FROM
     (SELECT table_id,
             schemaname,
             tablename,
             seq,
             ddl
      FROM
        (SELECT c.oid::bigint AS table_id,
                n.nspname AS schemanam e,
                c.relname AS tablename,
                0 AS seq,
                '--DROP TABLE ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ';' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         WHERE c.relkind = 'r'
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      2 AS seq,
                      'CREATE TABLE IF NOT     EXISTS ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + '' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         WHERE c.relkind = 'r'
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      5 AS seq,
                      '(' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         WHERE c.relkind = 'r'
         UNION SELECT table_id,
                      schemaname,
                      tablename,
                      seq,
                      '\t' + col_delim + col_name + ' ' + col_datatype + ' ' + col_nullable + ' ' + col_default + ' ' + col_encoding AS ddl
         FROM
           (SELECT c.oid::bigint AS table_id,
                   n.nspname AS schemaname,
                   c.relname AS tablename,
                   100000000 + a.attnum AS seq,
                   CASE
                       WHEN a .attnum > 1 THEN ','
                       ELSE ''
                   END AS col_delim,
                   QUOTE_IDENT(a.attname) AS col_name,
                   CASE
                       WHEN STRPOS(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER VARYING') > 0 THEN REPLACE(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER VARYING', 'VARCHAR')
                       WHEN STRPOS(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER') > 0 THE N REPLACE(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER', 'CHAR')
                       ELSE UPPER(format_type(a.atttypid, a.atttypmod))
                   END AS col_datatype,
                   CASE
                       WHEN format_encoding((a.attencodingtype)::integer) = 'none'THEN 'ENCODE RAW'
                       ELSE 'ENCODE ' + format_encoding((a.attencodingtype)::integer)
                   END AS col_encoding,
                   CASE
                       WHEN a.atthasdef IS T RUE THEN 'DEFAULT ' + adef.adsrc
                       ELSE ''
                   END AS col_default,
                   CASE
                       WHEN a.attnotnull IS TRUE THEN 'NOT NULL'
                       ELSE ''
                   END AS col_nullable
            FROM pg_namespace AS n
            INNER JOIN pg_class AS c ON n.oid = c.relnamespace
            INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
            LEFT OUTER JOIN pg_attrdef AS adef ON a.attrelid = adef.adrelid
            AND a.attnum = adef.adnum
            WHERE c.relkind = 'r'
              AND a.attnum > 0
            ORDER BY a.attnum)
         UNION
           (SELECT c.oid::bigint AS table_id,
                   n.nspname AS schemaname,
                   c.relname AS tablename,
                   200000000 + CAST(con.oid AS INT) AS seq,
                   '\t,' + pg_get_constraintdef(con.oid) AS ddl
            FROM pg_constraint AS con
            INNER JOIN pg_class AS c ON c.relnamespace = con.connamespace A ND c.oid = con.conrelid
            INNER JOIN pg_namespace AS n ON n.oid = c.relnamespace
            WHERE c.relkind = 'r'
              AND pg_get_constraintdef(con.oid) NOT LIKE 'FOREIGN KEY%'
            ORDER BY seq)
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      299999999 AS seq,
                      ')' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         WHERE c.relkind = 'r'
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      300000000 AS seq,
                      'BACKUP NO' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         INNER JOIN
           (SELECT SPLIT_PART(KEY, '_', 5) id
            FROM pg_conf
            WHERE KEY LIKE 'pg_class_backup_%    '
              AND SPLIT_PART(KEY, '_', 4) =
                (SELECT oid
                 FROM pg_database
                 WHERE datname = current_database())) t ON t.id=c.oid
         WHERE c.relkind = 'r'
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      1 AS seq,
                      '--WARNING: This DDL inherited the BACKUP NO property from the source table' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         INNER JOIN
           (SELECT SPLIT_PART(KEY, '_', 5) id
            FROM pg_conf
            WHERE KEY LIKE 'pg_class_backup_%'
              AND SPLIT_PART(KEY, '_', 4) =
                (SELECT oid
                 FROM pg_database
                 WHERE datname = current_database())) t ON t.id=c.oid
         WHERE c.relkind = 'r'
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname ,
                      c.relname AS tablename,
                      300000001 AS seq,
                      CASE
                          WHEN c.reldiststyle = 0 THEN 'DISTSTYLE EVEN'
                          WHEN c.reldiststyle = 1 THEN 'DISTSTYLE KEY'
                          WHEN c.reldiststyle = 8 THEN 'DISTSTYLE ALL'
                          WHEN c.reldiststyle = 9 THEN 'DISTSTYLE AUTO'
                          ELSE 'UNKNOWN'
                      END AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         WHERE c.rel kind = 'r'
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      400000000 + a.attnum AS seq,
                      ' DISTKEY (' + QUOTE_IDENT(a.attname) + ')' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
         WHERE c.relkind = 'r'
           AND a.attisd istkey IS TRUE
           AND a.attnum > 0
         UNION SELECT table_id,
                      schemaname,
                      tablename,
                      seq,
                      CASE
                          WHEN min_sort <0 THEN 'INTERLEAVED SORTKEY ('
                          ELSE ' SORTKEY ('
                      END AS ddl
         FROM
           (SELECT c.oid::bigint AS table_id,
                   n.nspname AS schemaname,
                   c.relname AS tablename,
                   499999999 AS seq,
                   min(attsortkeyord) min_sort
            FROM pg_namespace AS n
            INNER JOIN pg_cl ass AS c ON n.oid = c.relnamespace
            INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
            WHERE c.relkind = 'r'
              AND abs(a.attsortkeyord) > 0
              AND a.attnum > 0
            GROUP BY 1,
                     2,
                     3,
                     4)
         UNION
           (SELECT c.oid::bigint AS table_id,
                   n.nspname AS schemaname,
                   c.relname AS tablename,
                   500000000 + abs(a.attsortkeyord) AS seq,
                   CASE
                       WHEN abs(a.attsortkeyord) = 1 THEN '\t' + QUOTE_IDENT(a.attname)
                       ELSE '\t, ' + QUOTE_IDENT(a.attname)
                   END AS ddl
            FROM pg_namespace AS n
            INNER JOIN pg_class AS c ON n.oid = c.relnamespace
            INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
            WHERE c.relkind = 'r'
              AND abs(a.attsortkeyord) > 0
              AND a.attnum > 0
            ORDER BY abs(a.attsortkeyord))
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      599999999 AS seq,
                      '\t)' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
         WHERE c.relkind = 'r'
           AND abs(a.attsortkeyord) > 0
           AND a.attnum > 0
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      600000000 AS seq,
                      ';' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         WHERE c.relkind = 'r'
         UNION SELECT c.oid::bigint AS table_id,
                      n.nspname AS schemaname,
                      c.relname AS tablename,
                      600500000 AS seq,
                      'ALTER TABLE ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relnam e) + ' owner to '+ QUOTE_IDENT(u.usename) +';' AS ddl
         FROM pg_namespace AS n
         INNER JOIN pg_class AS c ON n.oid = c.relnamespace
         INNER JOIN pg_user AS u ON c.relowner = u.usesysid
         WHERE c.relkind = 'r')
      UNION
        (SELECT c.oid::bigint AS table_id,
                'zzzzzzzz' || n.nspname AS schemaname,
                'zzzzzzzz' || c.relname AS tablename,
                700000000 + CAST (con.oid AS INT) AS seq,
                                 'ALTER TABLE ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ' ADD ' + pg_get_constraintdef(con.oid)::VARCHAR(1024) + ';' AS ddl
         FROM pg_constraint AS con
         INNER JOIN pg_class AS c ON c.relnamespace = con.connamespace
         AND c.oid = con.conrelid
         INNER JOIN pg_namespace AS n ON n.oid = c.relnamespace WHE RE c.relkind = 'r'
         AND con.contype = 'f'
         ORDER BY seq)
      ORDER BY table_id,
               schemaname,
               tablename,
               seq))
WHERE ${filter};

