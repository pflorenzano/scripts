
-- Disable all log shipping jobs

USE MSDB;
GO
UPDATE MSDB.dbo.sysjobs
SET Enabled = 0
WHERE [Name] LIKE 'LSBackup_%';
GO



-- Enable all log shipping jobs

USE MSDB;
GO
UPDATE MSDB.dbo.sysjobs
SET Enabled = 1
WHERE [Name] LIKE 'LSBackup_%';
GO