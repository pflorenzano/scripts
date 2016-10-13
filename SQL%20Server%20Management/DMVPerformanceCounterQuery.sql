
-- Displays all the performance counters
SELECT DISTINCT [object_name]  
FROM sys.[dm_os_performance_counters]  
ORDER BY[object_name]; 

SELECT [object_name], [counter_name],  
   [instance_name], [cntr_value] 
FROM sys.[dm_os_performance_counters] 
WHERE [object_name] = 'SQLServer:Databases'; 