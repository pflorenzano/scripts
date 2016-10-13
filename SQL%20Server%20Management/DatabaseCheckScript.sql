
-- I. Stirk. ian_stirk@yahoo.com LightweightPageChecker utility...
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
-- Ensure buffer pool is empty.
DBCC DROPCLEANBUFFERS

-- Get details of all heaps, clustered indexes and non-clustered indexes to check.
SELECT 
 ss.name AS SchemaName
 , st.name AS TableName
 , s.name AS IndexName 
 , s.rowcnt AS 'Row Count' 
 , s.indid
INTO #IndexDetails
FROM sys.sysindexes s 
INNER JOIN sys.tables st ON st.[object_id] = s.[id]
INNER JOIN sys.schemas ss ON ss.[schema_id] = st.[schema_id]
WHERE s.id > 100 -- Only user tables
AND s.rowcnt >= 1 -- Ignore stats rows 
ORDER BY s.indid, [Row Count] DESC -- Do heaps and clustered first

DECLARE @CheckIndexesSQL NVARCHAR(MAX)
SET @CheckIndexesSQL = ''
-- Build SQL to read each page in each index (including clustered index).
SELECT @CheckIndexesSQL = @CheckIndexesSQL + CHAR(10) 
 + 'SELECT COUNT_BIG(*) AS [TableName: ' + SchemaName + '.' 
 + TableName + '. IndexName: ' + ISNULL(IndexName, 'HEAP') 
 + '. IndexId: ' + CAST(indid AS VARCHAR(3)) + '] FROM ' 
 + QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) 
 + ' WITH (INDEX(' + CAST(indid AS VARCHAR(3)) + '));'
FROM #IndexDetails
-- Debug.
DECLARE @StartOffset INT
DECLARE @Length INT
SET @StartOffset = 0
SET @Length = 4000
WHILE (@StartOffset < LEN(@CheckIndexesSQL))
BEGIN
 PRINT SUBSTRING(@CheckIndexesSQL, @StartOffset, @Length)
 SET @StartOffset = @StartOffset + @Length
END
PRINT SUBSTRING(@CheckIndexesSQL, @StartOffset, @Length)

-- Do work.
EXECUTE sp_executesql @CheckIndexesSQL
-- Tidy up.
DROP TABLE #IndexDetails