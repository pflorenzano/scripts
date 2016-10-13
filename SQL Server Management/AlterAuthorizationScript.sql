
Alter Authorization on Database::bbt_marketplace_main to [BBTPROD\PFlorenzano]

SELECT  SD.[SID]
       ,SL.Name as [LoginName]
  FROM  master..sysdatabases SD inner join master..syslogins SL
    on  SD.SID = SL.SID
 Where  SD.Name = 'bbt_marketplace_main'

  Select [SID]
  From bbt_marketplace_main.sys.database_principals
 Where Name = 'DBO'