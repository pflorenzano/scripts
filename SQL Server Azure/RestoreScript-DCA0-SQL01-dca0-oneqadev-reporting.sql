
-- Restore dca0-oneqadev-reporting onto same machine

USE [master]
RESTORE DATABASE [dca0-oneqadev-reporting] 
	FROM  URL = N'https://thdca0dbbackup.blob.core.windows.net/dca0-sql01/DCA0-SQL01_dca0-oneqadev-reporting_FULL_20160815_074908.bak' WITH  CREDENTIAL = N'dca0rgrscred' ,  
		FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5

GO

-- Restore production reporting database onto another machine

USE [master]
RESTORE DATABASE [dca2-eu2-reporting] 
	FROM URL = N'https://thdca2dbbackup.blob.core.windows.net/dca2sql0/full/dca2sql01-fc$dca2sql01-ag_dca2-eu2-reporting_FULL_COPY_ONLY_20160907_013727.bak' WITH CREDENTIAL = N'weubkupcred', 
		FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5

