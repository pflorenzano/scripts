
-- Scripts to Analyze databases

EXEC sp_who

SELECT *
 FROM sysdatabases

-- Table & Index information in TowerDB 

SELECT so.name AS 'Table Name',
       si.name AS 'Index Name',
       su.name AS 'User Name'
 FROM sysobjects so
  INNER JOIN sysindexes si ON si.id = so.id
   LEFT JOIN sysusers su ON su.uid = so.uid
    WHERE XType = 'U'
      --AND si.indid = 1 -- If indid = 1, then there is clustered indexes.  If indid > 1, then it's a non-clustered index
ORDER BY 1

-- Database table counts, copy and paste result set for total counts of tables

SELECT 'SELECT COUNT(*)' + SPACE(1) + 'AS' + SPACE(1) + '''' + name + ''''  + SPACE(1) + 'FROM' + SPACE(1) + 'dbo.' + name AS 'Table Counts' 
 FROM sysobjects
  WHERE XType = 'U'

-- Search for indexes

SELECT name
 FROM sysindexes
  WHERE indid = 1

-- View information 

SELECT *
 FROM sysobjects
  WHERE XType = 'V'

-- Stored Procedure information 

SELECT *
 FROM sysobjects
  WHERE XType = 'P'

-- Foreign key constraints

SELECT *
 FROM sysforeignkeys

SELECT so.name,
       sf.*
 FROM sysforeignkeys sf
  INNER JOIN sysobjects so ON so.id = sf.constid

-- Database & filename information

SELECT name, filename
 FROM sysdatabases

-- User information

SELECT *
 FROM sysusers

-- 