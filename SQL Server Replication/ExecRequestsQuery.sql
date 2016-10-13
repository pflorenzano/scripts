
--alter database usedcarinvoice_vehicleinfo set NEW_BROKER

-- EXEC sp_who2

-- EXEC sp_whoisactive
 
-- KILL 91 WITH STATUSONLY

	select	T.text, 
			R.Status, 
			R.Command, 
			DatabaseName = db_name(R.database_id), 
			R.cpu_time, 
			R.total_elapsed_time, 
			R.percent_complete
	from   sys.dm_exec_requests R
		   cross apply sys.dm_exec_sql_text(R.sql_handle) T
	order by Command

-----------------------------------------
/*
SELECT snapshot_isolation_state_desc from sys.databases 
where name='bbt_marketplace_main'
*/
-----------------------------------------

