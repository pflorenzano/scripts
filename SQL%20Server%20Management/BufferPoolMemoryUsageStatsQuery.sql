
-- Buffer Pool Memory Usage Stats query
 
SELECT  CAST(physical_memory_in_bytes / (1024.0 * 1024.0 * 1024.0) AS DECIMAL(20, 2)) AS physical_memory_in_GB,
        CAST(virtual_memory_in_bytes / (1024.0 * 1024 * 1024) AS DECIMAL(20, 2)) AS VAS_GB,
        CAST((bpool_committed * 8) / (1024.0 * 1024.0) AS DECIMAL(20, 2)) AS buffer_pool_committed_memory_in_GB,
        CAST((bpool_commit_target * 8) / (1024.0 * 1024.0) AS DECIMAL(20, 2)) AS buffer_pool_target_memory_in_GB,
        CAST((bpool_visible * 8) / (1024.0 * 1024.0) AS DECIMAL(20, 2)) AS buffer_pool_visible_memory_in_GB,
        (
         SELECT CAST(CAST(value_in_use AS INT) / 1024.0 AS DECIMAL(20, 2))
         FROM   sys.configurations
         WHERE  name = 'min server memory (MB)'
        ) AS [min server memory (GB)],
        (
         SELECT CAST(CAST(value_in_use AS INT) / 1024.0 AS DECIMAL(20, 2))
         FROM   sys.configurations
         WHERE  name = 'max server memory (MB)'
        ) AS [max server memory (GB)]
FROM    sys.dm_os_sys_info ;
