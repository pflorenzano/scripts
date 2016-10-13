
use msdb
go

SELECT *
FROM sysdtspackagelog
WHERE (logdate > CONVERT(DATETIME, '2008-05-19 00:00:00', 102)) AND (errorcode <> 0)
