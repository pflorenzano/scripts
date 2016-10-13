
-- Checking for Available Free Space on SQL Server

CREATE TABLE #appd4db_drive_check

	(
		drive			VARCHAR(100), 
		mb_free	INT 
	);

INSERT INTO #appd4db_drive_check 
	EXEC master.dbo.xp_fixeddrives;

SELECT *
 FROM #appd4db_drive_check --where mb_free < 100;

DROP TABLE #appd4db_drive_check;

