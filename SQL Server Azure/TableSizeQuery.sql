
-- Table size query (per table)

select obj.name, 
			sum(reserved_page_count) * 8.0 as "size in KB" 
	from sys.dm_db_partition_stats part, 
			sys.objects obj 
		where part.object_id = obj.object_id 
	group by obj.name

-- Database size query

	select sum(reserved_page_count) * 8.0 / 1024 as "size in MB" from sys.dm_db_partition_stats