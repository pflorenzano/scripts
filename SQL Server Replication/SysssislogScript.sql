
USE msdb
SELECT *
 FROM sysssislog
  WHERE CONVERT(CHAR(10),starttime,101) = '03/28/2014'
   AND event LIKE '%error%'
ORDER BY starttime DESC

 
