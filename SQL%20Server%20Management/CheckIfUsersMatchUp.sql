
USE master ;
GO

ALTER DATABASE apendleton_corgi_vehicleinfo SET DISABLE_BROKER ;
GO

EXEC sp_MSForEachDB 
'SELECT ''?'' AS ''DBName'', sp.name AS ''dbo_login'', o.name AS ''sysdb_login''
FROM ?.sys.database_principals dp
  LEFT JOIN master.sys.server_principals sp
    ON dp.sid = sp.sid
  LEFT JOIN master.sys.databases d 
    ON DB_ID(''?'') = d.database_id
  LEFT JOIN master.sys.server_principals o 
    ON d.owner_sid = o.sid
WHERE dp.name = ''dbo'';';

ALTER AUTHORIZATION ON DATABASE::bbt_app_log TO sa;


ALTER AUTHORIZATION ON DATABASE::yourcarcash_vehicleinfo TO sa;


ALTER DATABASE bbt_app_log SET TRUSTWORTHY ON