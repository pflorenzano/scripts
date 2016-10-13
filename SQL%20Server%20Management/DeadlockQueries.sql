
/* To eliminate deadlocking or blocking problems, contact your system administrator. 
   The system administrator should check the following columns in the sysprocesses table:
 
            waittype
            waittime
            lastwaittype 
            waitresource 

*/

USE Master
EXEC sp_who1 @blocked=1

KILL 8

USE Master
SELECT spid,
       dbid,
       blocked,
       waittype,
       waittime,
       lastwaittype, 
       waitresource 
 FROM sysprocesses
  --WHERE dbid = '11'
  WHERE blocked > 0

EXEC sp_who1

SELECT *
 FROM syslockinfo

-- Specifies the number of milliseconds a statement waits for a lock to be released.

SET LOCK_TIMEOUT 1800

-- Returns the current lock time-out setting, in milliseconds, for the current session.

SELECT @@LOCK_TIMEOUT

-- Niku Query

USE Niku
SELECT * FROM niku.prlock

-- DBCC inputbuffer command will tell you what statements are causing the blocking

DBCC INPUTBUFFER(116)
DBCC OUTPUTBUFFER(116)

EXEC sp_who

KILL 105

71	0	0x0000	0	LCK_M_S	KEY: 11:1246627484:1 (01008d11181a)
88	119	0x0005	558687	LCK_M_X	KEY: 11:1246627484:1 (0100c25526e1)
89	88	0x0003	299719	LCK_M_S	KEY: 11:1246627484:1 (0100c25526e1)
94	0	0x0000	0	LCK_M_S	KEY: 11:1246627484:1 (01008d11181a)
99	0	0x0000	0	MISCELLANEOUS	                                                                                                                                                                                                                                                                
113	0	0x0000	0	NETWORKIO	                                                                                                                                                                                                                                                                
114	0	0x0000	0	WRITELOG	                                                                                                                                                                                                                                                                
119	0	0x0000	0	NETWORKIO	                                                                                                                                                                                                                                                                
137	0	0x0000	0	WRITELOG	     

USE Master

DECLARE @killcmd  varchar(50),
        @killspid int,
        @killblock int

SET @killspid  =  (SELECT MAX(spid) FROM sysprocesses WHERE dbid = '11' and blocked <> '0' )
SET @killblock =  (SELECT MAX(blocked) FROM sysprocesses WHERE dbid = '11' and blocked <> '0')
BEGIN
 IF @killspid = @killblock   
  SET @killcmd = 'KILL' + STR(@killspid)
  --PRINT  'KILL' + STR(@killspid)
 IF @killspid <> @killblock 
  SET @killcmd = 'KILL' + STR(@killspid) 
END
                                                                                                                                                                                                                                                            

