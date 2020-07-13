/*
Minimum Vacuum memory 3x * num_columns * 1MB bytes of memory
*/
SELECT userid,
       pid,
       trim(status) status,
       starttime,
       duration,
       trim(user_name) username,
       trim(db_name) databasename,
       substring(query, 1, 60) querytxt
FROM stv_recents
WHERE userid>1;
