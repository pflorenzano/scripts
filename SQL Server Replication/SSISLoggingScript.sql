
USE msdb
SELECT	event,
		source,
		starttime,
		endtime,
		message
 FROM sysssislog
  WHERE CONVERT(CHAR(10),starttime,121) = '2014-03-18'
   AND event LIKE '%Error%'
ORDER BY endtime DESC

 

