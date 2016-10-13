
-- Run this query against the 'Master' database to see if any databases ARE NOT 'ONLINE'
-- If you do see database(s) in either the following states, please contact the DBA immediately
--
-- 'RESTORING'
-- 'RECOVERING'
-- 'RECOVERY_PENDING'
-- 'SUSPECT'
-- 'EMERGENCY'
-- 'OFFLINE'
-- 'COPYING'
--
-- The expected result set should be 0 records retrieved back.

SELECT	name			AS 'Database Name',
			state_desc		AS 'State Description'
 FROM sys.databases
   WHERE state_desc <> 'ONLINE'




 