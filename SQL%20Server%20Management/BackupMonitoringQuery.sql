
-- This query will find all databases that have not been backed up within the past day:

SELECT MAX(ISNULL(DATEDIFF(dd,ISNULL(b.backup_start_date, '01/01/1900'),GETDATE()),0)) AS 'NumDays'
, d.name as 'DBName'
FROM master..sysdatabases d 
LEFT JOIN msdb..backupset b ON d.name = b.database_name
AND b.backup_start_date = (SELECT MAX(backup_start_date)
FROM msdb..backupset b2
WHERE b.database_name = b2.database_name AND b2.type IN ('D','I'))
WHERE d.name != 'tempdb'
--AND d.name NOT IN (SELECT db_name FROM dbautility.dbo.db_exclude)
AND DATABASEPROPERTYEX(d.name, 'Status') = 'ONLINE'
GROUP BY d.name, b.type, b.backup_size
HAVING MAX(ISNULL(DATEDIFF(dd,ISNULL(b.backup_start_date, '01/01/1900'),GETDATE()),0)) > 1