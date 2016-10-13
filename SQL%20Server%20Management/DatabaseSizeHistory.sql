
SELECT DatabaseSizeRepository.SERVERNAME, 
	(CONVERT(CHAR(10),DatabaseSizeRepository.TODAYS_DATE,101) - 7)
              DatabaseSizeRepository.DATABASENAME,
              DatabaseSizeRepository.DATABASE_SIZE
FROM master.dbo.DatabaseSizeRepository DatabaseSizeRepository

WHERE DatabaseSizeRepository.TODAYS_DATE BETWEEN TODAYS_DATE AND (TODAYS_DATE -7)

ORDER BY DatabaseSizeRepository.TODAYS_DATE DESC

USE Master
SELECT *
 FROM master.dbo.DatabaseSizeRepository 
  WHERE TODAYS_DATE BETWEEN GETDATE() AND (TODAYS_DATE - 7)
ORDER BY TODAYS_DATE DESC

WHERE TODAYS_DATE BETWEEN TODAYS_DATE AND TODAYS_DATE 

ORDER BY TODAYS_DATE DESC

WHERE DATEDIFF(Month, [Last Start], GetDate()) >=48