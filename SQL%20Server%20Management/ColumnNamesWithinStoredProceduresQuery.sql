
USE bbt_marketplace_main
SELECT obj.Name		AS 'Stored Procedure Name',
			sc.TEXT			AS 'Stored Procedure Text'
	FROM sys.syscomments sc
		INNER JOIN sys.objects obj ON sc.Id = obj.OBJECT_ID
			WHERE sc.TEXT LIKE '%Dealer_DealershipSMS5%'
				AND TYPE = 'P'


-- Stored procedures that use the Dealer_DealershipEmail1 column

-- TIM_Utils_GetSingleUserListByUserID
 
 

 
