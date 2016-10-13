
-- Database name, files & location
 
SELECT sd.name AS [Database Name],
			mf.name AS Filename, 
		    mf.physical_name AS [File Location]
FROM sys.master_files mf
 INNER JOIN sys.databases sd ON sd.database_id = mf.database_id

