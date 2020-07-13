/*
(50% faster and accounts for dc2.8x node type but values are hardcoded)
with no joins
*/
CREATE OR REPLACE VIEW ADMIN.V_DISK_USAGE AS select 
case 
 when capacity = 361859 or (capacity=190633 and mount ilike '/dev/nvme%') then 'dc2.large'
 when capacity = 381407 or capacity = 190633 then 'dc1.large'
 when capacity = 380319 then 'dc1.8xlarge'
 when capacity = 760956 then 'dc2.8xlarge'
 when capacity in (1906314,952455) then 'ds2.xlarge'
 when capacity = 945026 then 'ds2.8xlarge' 
 else null end as node_type,
 host,
 sum(used-tossed) as used_mb,
 nominal as nominal_mb,
 round(sum(used-tossed)/nominal*100,2) as pct_nominal_mb,
 sum(capacity) as raw_mb,
 round((sum(used-tossed)/sum(capacity) *100),2) as pct_raw_mb 
 from
(select host,mount,used::numeric,tossed::numeric,capacity::numeric,case 
 when capacity in (381407,190633,361859) then 160*1024
 when capacity in (380319,760956) then 2.56*1024*1024
 when capacity in (1906314,952455) then 2*1024*1024
 when capacity = 945026 then 16*1024*1024
 else null
 end::numeric as nominal from stv_partitions where part_begin=0 and failed=0)  group by 1,2,4 order by 2;
