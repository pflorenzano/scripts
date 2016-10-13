
-- 
USE bbt_marketplace_main
SELECT COUNT(*)
			Message,
            Source,
			CONVERT(CHAR(10),DateCreated,101) AS DateCreated,
			DATEPART(HH,DateCreated) AS HourCreated,
			Exception
 FROM TIM_TrapError
   WHERE CONVERT(CHAR(10),DateCreated,101) = '08/16/2013'
GROUP BY Message,
            Source,
			CONVERT(CHAR(10),DateCreated,101),
			DATEPART(HH,DateCreated) ,
			Exception





