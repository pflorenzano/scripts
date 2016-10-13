
SELECT 
      database_name = DB_NAME(database_id)
    , total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2))
    , data_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
    , log_size_mb = CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
FROM sys.master_files WITH(NOWAIT)
WHERE database_id = 26
GROUP BY database_id


