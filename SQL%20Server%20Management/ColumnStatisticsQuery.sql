
-- This query will see if there are column statistics on the database

SELECT name
FROM sysindexes
WHERE (name LIKE '%_WA_Sys%')