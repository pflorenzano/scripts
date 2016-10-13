
--EXEC sp_who2

SELECT TOP 10 *
	 FROM [dbo].[get_aggregated_pool_metrics]('09/07/2016 00:00:00', '09/08/2016 23:00:00') 
		ORDER BY avg_edtu_percent DESC


SELECT *
 FROM dbo.db_resource_stats