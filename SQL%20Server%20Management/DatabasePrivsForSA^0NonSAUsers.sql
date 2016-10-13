

-- This query will return results where the Name/Loginname = SA

SELECT Name,
           loginname,
           dbname,
           sysadmin,
           securityadmin,
           serveradmin,
           setupadmin, 
           processadmin,
           diskadmin,
           dbcreator,
           bulkadmin
 FROM dbo.syslogins
WHERE sysadmin = 1

EXEC sp_helprole

 
EXEC sp_helprolemember 'public'
EXEC sp_helprolemember 'db_owner'
EXEC sp_helprolemember 'db_accessadmin'
EXEC sp_helprolemember 'db_securityadmin'
EXEC sp_helprolemember 'db_ddladmin'
EXEC sp_helprolemember 'db_backupoperator'
EXEC sp_helprolemember 'db_datareader'
EXEC sp_helprolemember 'db_datawriter'
EXEC sp_helprolemember 'db_denydatareader'
EXEC sp_helprolemember 'db_denydatawriter'
 

EXEC sp_helprolemember 'db_ddladmin'


-- This query will return results where the Name/Loginname <> SA 

SELECT Name,
           loginname,
           dbname,
           sysadmin,
           securityadmin,
           serveradmin,
           setupadmin, 
           processadmin,
           diskadmin,
           dbcreator,
           bulkadmin
 FROM dbo.syslogins
WHERE sysadmin <> 1

