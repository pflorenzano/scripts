
-- Development elastic pool names
--
--	'DCA0-OneDemo-ElasticPool-2';
-- 'dca0-ElasticPool-1'

-- Production elastic pool names
--
--	

SELECT d.name, 
	   slo.*  
	FROM sys.databases d 
		JOIN sys.database_service_objectives slo  
			ON d.database_id = slo.database_id
WHERE elastic_pool_name = 'dca0-ElasticPool-1'; 