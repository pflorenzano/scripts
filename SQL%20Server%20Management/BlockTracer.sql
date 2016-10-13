USE [Sysadmin]
GO
/****** Object:  StoredProcedure [dbo].[dba_BlockTracer]    Script Date: 02/17/2009 12:05:00 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROC [dbo].[dba_BlockTracer]
			@saveTrans as	bit = 0
AS
/*--------------------------------------------------
 
Purpose: Shows details of the root blocking process, together with details of any blocked processed

----------------------------------------------------

Parameters: One

Revision History:
      19/07/2007   Ian_Stirk@yahoo.com Initial version
	  06/02/2008   RTyler
		Add input parameter @saveTrans.
		Add test for input parameter, if value = 1 Enter a while loop
		  that will store any blocking transactions into a table.  The while
		  loop will execute every 10 seconds.  This will enable the tracking of blocking
		  over time.

Example Usage:
   -- Usage run with @saveTrans = 0 for ad hoc checking
--  Using @saveTans = 1 is intended to be used for capturing blocking
--  transactions into a table over time.  
-- Running with saveTans = 1 will result in a continous loop running,
--  which will need the Kill command be used to stop the process.

1.  Exec [dbo].[dba_BlockTracer] @saveTrans = 0
		Run ad hoc from query analyzer
2.  Exec [dbo].[dba_BlockTracer] @saveTrans = 1
		Run from a sql Job.  You will need to manually stop
		the job to end the process, or kill the spid the
		procedure is running under.

--------------------------------------------------*/

BEGIN

set nocount on

   -- Do not lock anything, and do not get held up by any locks. 
   SET TRANSACTION ISOLATION LEVEL READ 
      UNCOMMITTED

DECLARE @Blocking tinyint

WHILE 1 = 1
  BEGIN

   -- If there are blocked processes...
   IF EXISTS(SELECT 1 FROM sys.sysprocesses WHERE 
      blocked != 0) 
   BEGIN

	  SET @Blocking = 1

  If @saveTrans = 1
	BEGIN 
	  WHILE 1 = 1
		  BEGIN
		  -- Identify the root-blocking spid(s)
		  INSERT INTO dbo.dba_BlockingInfo
		  SELECT  distinct t1.spid  AS [Root blocking spids]
			 , t1.[blocked]
			 , t1.[loginame] AS [Owner]
			 , dbo.dba_GetSQLForSpid(t1.spid) AS 
				'SQL Text' 
			 , t1.[cpu]
			 , t1.[physical_io]
			 , DatabaseName = DB_NAME(t1.[dbid])
			 , t1.[program_name]
			 , t1.[hostname]
			 , t1.[status]
			 , t1.[cmd]
			 , t1.[ecid]
			 , t1.lastWaittype
			 , t1.Waitresource
			 , getdate() AS Createdate
		  FROM  sys.sysprocesses t1, sys.sysprocesses t2
		  WHERE t1.spid = t2.blocked
			AND t1.ecid = t2.ecid
			AND t1.blocked = 0 
		  ORDER BY t1.spid, t1.ecid

		  -- Identify the spids being blocked.
		  INSERT INTO dbo.dba_BlockingInfo
		  SELECT t2.spid AS 'Blocked spid'
			 , t2.[blocked] AS 'Blocked By'
			 , t2.[loginame] AS [Owner]
			 , dbo.dba_GetSQLForSpid(t2.spid) AS 
				'SQL Text' 
			 , t2.[cpu]
			 , t2.[physical_io]
			 , DatabaseName = DB_NAME(t2.[dbid])
			 , t2.[program_name]
			 , t2.[hostname]
			 , t2.[status]
			 , t2.[cmd]
			 , t2.[ecid]
			 , t2.lastWaittype
			 , t2.Waitresource
			 , getdate() AS Createdate
		  FROM sys.sysprocesses t1, sys.sysprocesses t2 
		  WHERE t1.spid = t2.blocked
			AND t1.ecid = t2.ecid
		  ORDER BY t2.blocked, t2.spid, t2.ecid

		  WAITFOR DELAY '00:00:10'	-- Wait for 10 seconds

			END		-- End While Loop
	END

	ELSE		-- End If @saveTrans = 1
	BEGIN
		Print 'If @saveTrans = 0  Loop was not envoked. '
  
		---    @saveTrans = 1  So save transactions to disk
		IF  @Blocking = 1
		BEGIN 
		 -- Identify the root-blocking spid(s)
		
		   SELECT  distinct t1.spid  AS [Root blocking spids]
			 , t1.[blocked]
			 , t1.[loginame] AS [Owner]
			 , dbo.dba_GetSQLForSpid(t1.spid) AS 
				'SQL Text' 
			 , t1.[cpu]
			 , t1.[physical_io]
			 , DatabaseName = DB_NAME(t1.[dbid])
			 , t1.[program_name]
			 , t1.[hostname]
			 , t1.[status]
			 , t1.[cmd]
			 , t1.[ecid]
			 , t1.lastWaittype
			 , t1.Waitresource
			 , getdate() AS Createdate
		  FROM sys.sysprocesses t1, sys.sysprocesses t2 
		  WHERE t1.spid = t2.blocked
			AND t1.ecid = t2.ecid
			AND t1.blocked = 0
		  ORDER BY t1.spid, t1.ecid
			PRINT ' GOT BLOCKING SPID'

		  -- Identify the spids being blocked.
		  SELECT t2.spid AS 'Blocked spid'
			 , t2.[blocked] AS 'Blocked By'
			 , t2.[loginame] AS [Owner]
			 , dbo.dba_GetSQLForSpid(t2.spid) AS 
				'SQL Text' 
			 , t2.[cpu]
			 , t2.[physical_io]
			 , DatabaseName = DB_NAME(t2.[dbid])
			 , t2.[program_name]
			 , t2.[hostname]
			 , t2.[status]
			 , t2.[cmd]
			 , t2.[ecid]
			 , t2.lastWaittype
			 , t2.WaitResource
			 , getdate() AS Createdate 
		  FROM sys.sysprocesses t1, sys.sysprocesses t2 
		  WHERE t1.spid = t2.blocked
			AND t1.ecid = t2.ecid
		  ORDER BY t2.blocked, t2.spid, t2.ecid

		PRINT ' GOT BLOCKED SPIDs'
		If @saveTrans = 0
		 BEGIN
			PRINT 'No processes blocked.' 
	  		BREAK
		 END
	END -- End @Blocking = 1
   END
  END	
ELSE -- No blocked processes.
	BEGIN
		If @saveTrans = 0
		 BEGIN
			PRINT 'No processes blocked.' 
	  		BREAK
		 END
				
		WAITFOR DELAY '00:00:10'	-- Wait for 10 seconds
	END
END
END
