
-- Query #1

SELECT DISTINCT
    SUBSTRING(volume_mount_point, 1, 1) AS volume_mount_point
    ,total_bytes/1024/1024 AS total_bytes
    ,available_bytes/1024/1024 AS available_bytes
FROM
    sys.master_files AS f
CROSS APPLY
    sys.dm_os_volume_stats(f.database_id, f.file_id);




