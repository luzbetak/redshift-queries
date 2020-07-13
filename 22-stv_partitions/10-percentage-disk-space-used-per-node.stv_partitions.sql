/*
(50% faster and accounts for dc2.8x node type but values are hardcoded)
*/
CREATE OR REPLACE VIEW ADMIN.V_DISK_USAGE AS with 
stvp as (select host,sum(used-tossed)::numeric as used,sum(capacity)::numeric as capacity 
	from stv_partitions where owner=host group by owner,host),
size as (select host, 
 case 
 when capacity in (381407,190633,361859) then 160*1024
 when capacity in (380319,760956) then 2.56*1024*1024
 when capacity in (1906314,952455) then 2*1024*1024
 when capacity = 945026 then 16*1024*1024
 end::int as nominal
 from stv_partitions where diskno=0 and part_begin=0)
select stvp.host,stvp.used as used_mb,size.nominal as nominal_mb,round(stvp.used/size.nominal*100,2) as pctused_nominal,stvp.capacity,round((stvp.used/stvp.capacity *100),2) as pctused_capacity from
stvp left join size using (host) order by host;
