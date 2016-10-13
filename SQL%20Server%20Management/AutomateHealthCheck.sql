
-- MKD31\PRODUCTION Health Check Report -- Runs weekly @ 3:00AM
exec [MKD31\PRODUCTION].MSDB.[dbo].uspEmailSQLServerHealth '172.20.10.126', 'MKD31\PRODUCTION Health Check', 'PFlorenzano@pcconnection.com', 'SVC-MKA100', 'Data Warehouse'

-- MKD38 Health Check Report -- Runs weekly @ 3:15AM
exec "MKD38"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.8.218', 'MKD38 Health Check', 'pflorenzano@pcconnection.com', 'MKD38 Database Mail', 'Web Team'

-- MKA05 Health Check Report -- Runs weekly @ 3:30AM
exec "MKA05"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.9.7', 'MKA05 Health Check', 'DBAdmin@pcconnection.com', 'MKA05 Public Profile', 'Business Objects XIR2'

-- MKA102 Health Check Report -- Runs weekly @ 3:45AM
exec MKA102.MSDB.[dbo].uspEmailSQLServerHealth '172.20.11.232', 'MKA102 Health Check', 'DBAdmin@pcconnection.com', 'MKA102 Public Profile', 'Data Warehouse'

-- MKA116 Health Check Report -- Runs weekly @ 4:00AM
exec MKA116.MSDB.[dbo].uspEmailSQLServerHealth '172.20.10.136', 'MKA116 Health Check', 'DBAdmin@pcconnection.com', 'MKA116 Database Mail', 'Cybersource Secondary Server'

-- MKA117 Health Check Report -- Runs weekly @ 4:15AM
exec MKA117.MSDB.[dbo].uspEmailSQLServerHealth '172.20.10.137', 'MKA117 Health Check', 'DBAdmin@pcconnection.com', 'MKA117 Database Mail', 'Cybersource Primary Server'

-- MKA143 Health Check Report -- Runs weekly @ 4:30AM
exec MKA143.MSDB.[dbo].uspEmailSQLServerHealth '172.20.9.55', 'MKA143 Health Check', 'DBAdmin@pcconnection.com', 'MKA143 Database Mail', 'Comshare Server'

-- MKA154 Health Check Report -- Runs weekly @ 4:45AM
exec MKA154.MSDB.[dbo].uspEmailSQLServerHealth '172.20.10.101', 'MKA154 Health Check', 'pflorenzano@pcconnection.com', 'MKA154 Database Mail', 'SMS Server'

-- MKA163 Health Check Report -- Runs weekly @ 5:00AM
exec "MKA163"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.8.195', 'MKA163 Health Check', 'pflorenzano@pcconnection.com', 'MKA163 Database Mail', 'SMS Server'

-- MKD30 Health Check Report -- Need to set server to Mixed user which requires a reboot!
exec "MKD30"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.11.126', 'MKD30 Health Check', 'pflorenzano@pcconnection.com', 'MKD30 Database Mail', 'TFS Server'

-- MKD33 Health Check Report -- Runs weekly @ 5:15AM
exec "MKD33"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.11.239', 'MKD33 Health Check', 'pflorenzano@pcconnection.com', 'MKD33 Public Profile', 'SDE Server'

-- MKD34\PRODUCTION Health Check Report
exec "MKD34\PRODUCTION"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.11.75', 'MKD34\PRODUCTION Health Check', 'pflorenzano@pcconnection.com', 'MKD34 Public Profile', 'Riversand Server'

-- MKD37 Health Check Report -- Runs weekly @ 5:30AM
exec "MKD37"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.9.54', 'MKD37 Health Check', 'pflorenzano@pcconnection.com', 'MKD37 Database Mail', 'Lawson Server'

-- MKD41 Health Check Report -- Runs weekly @ 5:45AM
exec "MKD41"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.10.112', 'MKD41 Health Check', 'pflorenzano@pcconnection.com', 'MKD41 Database Mail', 'Kronos Server'

-- MKD44 Health Check Report -- Runs weekly @ 5:55AM
exec "MKD44"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.44.48', 'MKD41 Health Check', 'pflorenzano@pcconnection.com', 'MKD44 Database Mail', 'Kronos Server'

-- MKD47 Health Check Report -- Runs weekly @ 6:00AM
exec "MKD47"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.8.126', 'MKD47 Health Check', 'pflorenzano@pcconnection.com', 'MKD47_Database_Mail', 'Robust SQL 2008 Database Server'

-- MKD48 Health Check Report
exec "MKD48"."MSDB".[dbo].uspEmailSQLServerHealth '172.20.9.119', 'MKD48 Health Check', 'pflorenzano@pcconnection.com', 'MKD48_Database_Mail', 'SSIS Database Server'