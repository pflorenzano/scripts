
USE bbt_marketplace_dealers_shaft;
GO
SELECT major_id, minor_id, t.name AS [Table Name], c.name AS [Column Name], value AS [Extended Property]
FROM sys.extended_properties AS ep
INNER JOIN sys.tables AS t ON ep.major_id = t.object_id 
INNER JOIN sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
WHERE t.name = 'TIM_UserInfoTable'
  --AND c.name = 'DateCreated'
AND class = 1;
GO