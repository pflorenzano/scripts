
SELECT CAST(COUNT(*) * 1.0 / COUNT(DISTINCT DATEDIFF(DAY,'19000101',DateInserted)) AS DECIMAL(10, 2)) 
	FROM [dbo].[InProcInvocationDetails]