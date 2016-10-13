
SELECT name AS Disabled_LoginName

FROM sys.server_principals

WHERE is_disabled = 1
