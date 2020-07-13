select * from stl_vacuum where table_id=<table id> order by eventtime; 

select a.userid,a.query,b.xid,a.service_class,trim("database") as dbname,b.starttime,b.endtime,a.query_blocks_read,a.query_execution_time,query_cpu_usage_percent,segment_execution_time,cpu_skew,est_peak_mem,io_skew,scan_row_count,aborted,trim(querytxt) as text from svl_query_metrics_summary a join stl_query b using (query) join (select distinct xid from stl_vacuum) using (xid) join stl_wlm_query using (query) order by b.xid,b.starttime;

select userid,query,xid,pid,trim("database") as "database",starttime,endtime,datediff(s,starttime,endtime) as duration_s,aborted,trim(querytxt) as text from stl_query a join (select distinct xid from stl_vacuum) using (xid) order by starttime;

select stvd.userid,stvd.query,stq.xid,stq.pid,stq.starttime,stq.endtime,datediff(s,stq.starttime,stq.endtime) as duration_s,stvd.slice,stvd.part,stvd.start_row,stvd.end_row,stvd.num_new_rows,stvd.num_blocks_replaced,stvd.total_block_io_estimate,stvd.window_num,stvd.num_deleted_rows,stvd.compact,stvd.num_new_blocks,stvd.empty_space_size,stq.aborted,trim(stq.querytxt) as querytxt
from 
stl_vacuum_detail stvd join stl_query stq on stvd.query=stq.query order by 2,3;

create or replace view v_vacuum_summary as
select a.userid,a.xid,trim(d.datname) as database_name,a.table_id,trim(c.name) as tablename,trim(a.status) as vac_start_status,
case when a.status ilike 'skipped%' then 'Skipped' 
when f.xid is not null then 'Running' 
when b.status is null then 'Failed' 
else trim(b.status) end as vac_end_status,
a.eventtime as vac_start_time,b.eventtime as vac_end_time,a.rows as vac_start_rows,b.rows as vac_end_rows,a.sortedrows as vac_start_sorted_rows,b.sortedrows as vac_end_sorted_rows,a.blocks as vac_start_blocks,b.blocks as vac_end_blocks,b.blocks - a.blocks as vac_block_diff,nvl(e.empty_blk_cnt,0,e.empty_blk_cnt) as empty_blk_cnt
 from 
 (select * from stl_vacuum where status<>'Finished') a 
 left join (select * from stl_vacuum where status='Finished') b 
 using (xid) 
 left join (select id,name,db_id from stv_tbl_perm where slice=0) c on a.table_id=c.id
 join pg_database d on c.db_id=d.oid
 left join (select tbl,count(*) as empty_blk_cnt from stv_blocklist where num_values=0 group by 1) e on a.table_id=e.tbl
 left join (select xid from svv_transactions where lockable_object_type='transactionid') f using (xid)
order by xid;

select stvd.userid,stvd.query,stq.xid,stvs.node,stvd.part,min(stvd.start_row) as start_row,max(stvd.end_row) as end_row,sum(stvd.num_new_rows) as total_num_new_rows,sum(stvd.num_blocks_replaced) as total_num_blocks_replaced,sum(stvd.total_block_io_estimate) as total_block_io_estimate,sum(stvd.num_deleted_rows) as total_num_deleted_rows,sum(stvd.num_new_blocks) as total_num_new_blocks,sum(stvd.empty_space_size) as total_empty_space_size,stq.aborted,trim(stq.querytxt) as querytxt from stl_vacuum_detail stvd join stl_query stq using (query) join stv_slices stvs using (slice) group by 1,2,3,4,5,14,15 order by 3,2,5,4;


select stvd.userid,stvd.query,stq.xid,stvs.node,stvd.part,min(stvd.start_row) as start_row,max(stvd.end_row) as end_row,sum(stvd.num_new_rows) as total_num_new_rows,sum(stvd.num_blocks_replaced) as total_num_blocks_replaced,sum(stvd.total_block_io_estimate) as total_block_io_estimate,sum(stvd.num_deleted_rows) as total_num_deleted_rows,sum(stvd.num_new_blocks) as total_num_new_blocks,sum(stvd.empty_space_size) as total_empty_space_size,stq.aborted,trim(stq.querytxt) as querytxt from stl_vacuum_detail stvd join stl_query stq using (query) join stv_slices stvs using (slice) group by 1,2,3,4,5,14,15 order by 2,3;

select stvs.node,stq.xid,sum(stvd.num_blocks_replaced) as total_num_blocks_replaced,sum(stvd.total_block_io_estimate) as total_block_io_estimate,sum(stvd.num_deleted_rows) as total_num_deleted_rows,sum(stvd.num_new_blocks) as total_num_new_blocks,sum(stvd.empty_space_size) as total_empty_space_size,stq.aborted from stl_vacuum_detail stvd join stl_query stq using (query) join stv_slices stvs using (slice) group by 1,2,8 order by 2,1;


