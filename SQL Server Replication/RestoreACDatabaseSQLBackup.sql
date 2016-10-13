
USE Master
GO
DECLARE @dbname sysname
SET @dbname = 'bbt_marketplace_ac_main'

DECLARE @spid INT
SELECT @spid = MIN(spid) 
	FROM Master.dbo.sysprocesses
		WHERE DBID = db_id(@dbname)
	WHILE @spid Is Not Null
	BEGIN
        EXECUTE ('Kill ' + @spid)
			SELECT @spid = MIN(spid) 
				FROM Master.dbo.sysprocesses
			WHERE DBID = DB_ID(@dbname) and spid > @spid
END

GO

RESTORE DATABASE [bbt_marketplace_ac_main] 
	FROM  DISK = N'\\Sqlclu1\s$\MSSQL\DUMP\bbt_marketplace_ac_main\bbt_marketplace_ac_main.bak' 	WITH  FILE = 1,  
		MOVE N'bbt_main' TO N'S:\MSSQL\DATA\bbt_marketplace_ac_main.mdf',  
		MOVE N'bbt_main_log' TO N'E:\MSSQL\LOG\bbt_marketplace_ac_main_log.ldf',  
		NOUNLOAD,  REPLACE,  STATS = 5
