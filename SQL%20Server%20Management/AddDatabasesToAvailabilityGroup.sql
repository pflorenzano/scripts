
-- #1 Backup databases 

Use SSMS

-- #2 Add database to Availability Group

ALTER AVAILABILITY GROUP [dca2sql01-ag] ADD DATABASE [dca2-eu2-usermanagement]

-- #3 - Copy backups to secondary database servers

Use MS Windows copy or Powershell

-- #4  - Restore databases to secondary nodes and add the database to the availability group

USE [master]
GO

RESTORE DATABASE [dca2-eu2-adaptive] 
	FROM  DISK = N'D:\SQLTEMP\adaptive.bak' 
		WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 5

GO

RESTORE LOG [dca2-eu2-adaptive] 
	FROM  DISK = N'D:\SQLTEMP\adaptive.trn' 
		WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
GO

ALTER DATABASE [dca2-eu2-adaptive] SET HADR AVAILABILITY GROUP = [dca2sql01-ag];