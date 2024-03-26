-- Find the AWR snapshot details.

select snap_id,begin_interval_time,end_interval_time from sys.wrm$_snapshot order by snap_id;

-- Purge snapshot between snapid 612 to 700

execute dbms_workload_repository.drop_snapshot_range(low_snap_id =>612 , high_snap_id =>700);

-- Verify again

select snap_id,begin_interval_time,end_interval_time from sys.wrm$_snapshot order by snap_id;