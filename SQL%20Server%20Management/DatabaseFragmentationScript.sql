
SELECT DISTINCT 'ALTER INDEX ALL ON '+ (object_name(object_id))+ ' REBUILD WITH (ONLINE = OFF FILLFACTOR = 80, SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = ON);',
avg_fragmentation_in_percent 
FROM
sys.dm_db_index_physical_stats (DB_ID(N'LW_Merchants'),NULL, NULL, NULL, 'LIMITED')
Where avg_fragmentation_in_percent >= 30
order by avg_fragmentation_in_percent desc

SELECT *
 FROM sys.dm_db_index_physical_stats 