
/* Author:			Peter M. Florenzano
 * Date:				08/07/2013
 * Version:			1
 * Purpose:		The purpose of this script is to capture and store database integrity history in a custom table that can be used for historical 
						analysis on an on-going basis as part of your maintenance routine. 
*/

-- Step #1 - Create the dbcc_history table

CREATE TABLE [dbo].[dbcc_history](
					[Error] [int] NULL,
					[Level] [int] NULL,
					[State] [int] NULL,
					[MessageText] [varchar](7000) NULL,
					[RepairLevel] [int] NULL,
					[Status] [int] NULL,
					[DbId] [int] NULL,
					[Id] [int] NULL,
					[IndId] [int] NULL,
					[PartitionID] [int] NULL,
					[AllocUnitID] [int] NULL,
					[File] [int] NULL,
					[Page] [int] NULL,
					[Slot] [int] NULL,
					[RefFile] [int] NULL,
					[RefPage] [int] NULL,
					[RefSlot] [int] NULL,
					[Allocation] [int] NULL,
					[TimeStamp] [datetime] NULL CONSTRAINT [DF_dbcc_history_TimeStamp] DEFAULT (GETDATE())
) ON [PRIMARY]
GO

-- Step #2 
-- Create stored procedure usp_CheckDBIntegrity

/****** Object: StoredProcedure [dbo].[usp_CheckDBIntegrity] Created by Robert Pearl ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_CheckDBIntegrity]
@database_name SYSNAME=NULL
AS
IF @database_name IS NULL -- Run against all databases
BEGIN
DECLARE database_cursor CURSOR FOR
SELECT name
	FROM sys.databases db
		WHERE name NOT IN ('master','model','msdb','tempdb')
			AND db.state_desc = 'ONLINE'
			AND source_database_id IS NULL -- REAL DBS ONLY (Not Snapshots)
			AND is_read_only = 0

OPEN database_cursor
FETCH next FROM database_cursor INTO @database_name
WHILE @@FETCH_STATUS=0
BEGIN

INSERT INTO dbcc_history 
	([Error], [Level], [State], MessageText, RepairLevel, [Status],
	[DbId], Id, IndId, PartitionId, AllocUnitId, [File], Page, Slot, RefFile, RefPage,
	RefSlot,Allocation)
EXEC ('dbcc checkdb(''' + @database_name + ''') with tableresults')

FETCH next FROM database_cursor INTO @database_name
END

CLOSE database_cursor
DEALLOCATE database_cursor
END

ELSE -- run against a specified database (ie: usp_CheckDBIntegrity 'DB Name Here'

INSERT INTO dbcc_history ([Error], [Level], [State], MessageText, RepairLevel, [Status],
[DbId], Id, IndId, PartitionId, AllocUnitId, [File], Page, Slot, RefFile, RefPage, RefSlot,Allocation)
EXEC ('dbcc checkdb(''' + @database_name + ''') with tableresults')
GO 

-- Step #3 
/*  Execute stored procedure against the specific database.  Below are three options in which this stored procedure
     could be executed:

    #1 Create a SQL Server Agent job/step
    #2 Include this code within the SSIS Nightly Job
*/

EXEC usp_CheckDBIntegrity 'bbt_base_vm_shaft' -- specifies particular database, otherwise ALL DBS
GO 

-- Step #4 
-- Query the 'dbcc_history' table to view the result set

SELECT Error, 
		    LEVEL, 
			DB_NAME(dbid) AS DBName, 
			OBJECT_NAME(id,dbid) AS ObjectName, 
			Messagetext, 
			TimeStamp
FROM dbcc_history


