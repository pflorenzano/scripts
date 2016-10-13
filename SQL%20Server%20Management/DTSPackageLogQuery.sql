
USE MSDB
SELECT *
 FROM dbo.sysdtspackagelog
ORDER BY endtime DESC

SELECT errordescription
 FROM dbo.sysdtssteplog
ORDER BY endtime DESC

SELECT * FROM sysdtssteplog

SELECT sdl.Name					AS 'DTS Package Name',
           sds.stepname			AS 'DTS Step Name',
           sds.starttime			AS 'Start Time',
           sds.endtime				AS 'End Time',
           sds.errorcode			AS 'Error Code',
           sds.errordescription	AS 'Error Description'
 FROM sysdtspackagelog sdl
  INNER JOIN sysdtssteplog sds ON sds.lineagefull = sdl.lineagefull
WHERE sds.errorcode <> 0
  
SELECT *
 FROM sysdtspackageLog

SELECT *
 FROM  sysdtssteplog