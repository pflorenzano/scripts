
-- Remove log shipping for the KOFCSQL02.OO database

-- #1 - Removes a log shipping pair from a log shipping monitor. (Execute on KOFCSQL02 (192.168.12.10))

EXEC sp_delete_log_shipping_monitor_info 
     @primary_server_name =  'KOFCSQL01' , 
     @primary_database_name =  'OO' , 
     @secondary_server_name =  'KOFCSQL02' , 
     @secondary_database_name =  'OO'  

-- #2 - Deletes a log shipping plan.

EXEC sp_delete_log_shipping_plan 
     @plan_name = N'KOFCSQL01.OO_logshipping',
     @del_plan_db = '18' 

-- #3 - Removes a database from a log shipping plan.

EXEC sp_delete_log_shipping_plan_database  
     @plan_name =   'Log Shipping - OO' , 
     @destination_database =  'OO'

-- #4 - Deletes the primary server from the log_shipping_primaries table.

EXEC sp_delete_log_shipping_primary 
     @primary_server_name = '192.168.12.9' , 
     @primary_database_name = 'OO' , 
     @delete_secondaries = '1'

-- #5 - Removes a secondary server from log_shipping_secondaries table

EXEC sp_delete_log_shipping_secondary 
     @secondary_server_name = '192.168.12.10' , 
     @secondary_database_name =  'OO' 

-- #6 - Drop the KOFCSQL02.OO database

USE Master
DROP DATABASE OO