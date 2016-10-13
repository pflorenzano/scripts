
-- Compression tutorial

USE [AdventureWorks]
GO
BEGIN TRANSACTION
CREATE PARTITION FUNCTION [fnSalesOrderDetail_PartitionBySalesOrderDetailID] (int)
AS RANGE LEFT FOR VALUES (N'50000', N'65000', N'80000')

CREATE PARTITION SCHEME [psSalesOrderDetail]
AS PARTITION [fnSalesOrderDetail_PartitionBySalesOrderDetailID]
TO ([FG1], [FG2], [FG3], [FG4])

ALTER TABLE [Sales].[SalesOrderDetail]
DROP CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID]

ALTER TABLE [Sales].[SalesOrderDetail]
ADD CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] PRIMARY KEY
CLUSTERED
(		[SalesOrderID] ASC,
		[SalesOrderDetailID] ASC
)ON	[psSalesOrderDetail]([SalesOrderID])

COMMIT TRANSACTION

--

USE [AdventureWorks]
ALTER TABLE [Sales].[SalesOrderDetail] REBUILD PARTITION = 2 WITH(DATA_COMPRESSION = ROW )
USE [AdventureWorks]
ALTER TABLE [Sales].[SalesOrderDetail] REBUILD PARTITION = 3 WITH(DATA_COMPRESSION = PAGE )
USE [AdventureWorks]
ALTER TABLE [Sales].[SalesOrderDetail] REBUILD PARTITION = 4 WITH(DATA_COMPRESSION = PAGE )

--

EXEC sp_configure 'backup compression default', 1
RECONFIGURE WITH OVERRIDE;

BACKUP DATABASE AdventureWorks
TO DISK='C:\SQL_BACKUPS\AdvWorksData.BAK'
WITH FORMAT,
		NAME='AdventureWorks Full Compressed Backup'
GO

USE msdb
SELECT name,
		   backup_size,
		   compressed_backup_size,
		   backup_size/compressed_backup_size as ratio
	FROM msdb..backupset
	WHERE name = 'AdventureWorks Full Compressed Backup'   
	
-- Create resource pool and workload group

USE master
GO
CREATE RESOURCE POOL [BackupPool]
WITH (MAX_CPU_PERCENT=20)
GO
CREATE WORKLOAD GROUP [BackupGroup]
USING [BackupPool]
GO

-- Create classifier function
CREATE FUNCTION [dbo].[fnClassifier]()
RETURNS SYSNAME
WITH SCHEMABINDING
BEGIN
	RETURN
		CAST(
			CASE SUSER_SNAME()
				WHEN 'PCC\Florenza' THEN 'BackupGROUP'
			END
		AS SYSNAME)
END
GO

-- Associate classifier with Resource Governor
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION=dbo.fnCLassifier)
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

-- Original classifier function
CREATE FUNCTION [dbo].[fnClassifyByApp]()
RETURNS SYSNAME WITH SCHEMABINDING
BEGIN
	RETURN
		CAST(
			CASE APP_NAME()
				WHEN		'MonitorApp'		THEN 'MonitorGroup'
				WHEN		'DashboardApp'	THEN	'MonitorGroup'
				WHEN		'RealtimeApp'		THEN	'RealtimeGroup'
			END AS SYSNAME)
END
GO

-- Altered classifier function to accommodate backup process login
ALTER FUNCTION [dbo].[fnClassifyByApp]()
RETURNS SYSNAME WITH SCHEMABINDING
BEGIN
	RETURN
		CAST(
			CASE SUSER_SNAME()
				WHEN 'PCC\Florenza'		THEN 'BackupGroup'
				ELSE CASE APP_NAME()
					WHEN		'MonitorApp'		THEN 'MonitorGroup'
					WHEN		'DashboardApp'	THEN	'MonitorGroup'
					WHEN		'RealtimeApp'		THEN	'RealtimeGroup'
			END 
		END AS SYSNAME)
END
GO