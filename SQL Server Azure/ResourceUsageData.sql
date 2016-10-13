
SELECT * 
	FROM sys.elastic_pool_resource_stats 
		WHERE elastic_pool_name = 'dca0-ElasticPool-1'
ORDER BY end_time DESC;

-- Average cpu percent of all records

SELECT AVG(avg_cpu_percent)
 FROM sys.elastic_pool_resource_stats 
  WHERE elastic_pool_name = 'dca0-ElasticPool-1'