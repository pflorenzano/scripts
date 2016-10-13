
-- Database name & size query, order by name ASC

WITH fs  
AS
(
    SELECT database_id, 
				type, 
				size * 8.0 / 1024 size
		FROM sys.master_files
)
SELECT name AS 'Database Name',
    (SELECT SUM(size) FROM fs WHERE TYPE = 0 AND fs.database_id = db.database_id) DataFileSizeMB,
    (SELECT SUM(size) FROM fs WHERE TYPE = 1 and fs.database_id = db.database_id) LogFileSizeMB  
FROM sys.databases db
ORDER BY name ASC