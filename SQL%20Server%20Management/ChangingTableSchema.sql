-- Changing Table Schema – what goes behind the scenes – Part I

-- all illustrations done in temp database 
 USE tempdb 
GO
 CREATE TABLE tbTestChange 
 (
PK_id INT NOT NULL PRIMARY KEY,
Col1 SMALLINT NOT NULL,
Col2 VARCHAR(10)NOT NULL,
COl3 CHAR(5)NOT NULL
 )

-- Run the following query. This will show the meta-data for above table. It uses sys.columns system catalog view
-- (http://msdn.microsoft.com/en-us/library/ms176106(SQL.90).aspx )which returns a row for every column in a table or view. 
-- This contains information like column data type, maximum length, nullability etc. An inner join with sys.types is used to get 
-- actual type name rather than unfriendly type identifier (like 'int' instead of returning '56').

SELECT c.name AS column_name,c.column_id,t.name AS column_type_name,c.max_length,c.is_nullable 
 FROM sys.columns c 
 INNER JOIN sys.types t 
 ON c.system_type_id = t.system_type_id 
 WHERE c.object_id= object_id('tbTestChange')
 ORDER BY c.column_id 

-- Now insert some data in to the table

 INSERT INTO tbTestChange 
 SELECT 1,100,'AAAAAA','aaaa'
 UNION
 SELECT 2,101,'BBBBBBB','bbbbb'

-- So to get the page and file number we can use another command DBCC IND. This will produce two rows. Select the 
-- PageFID and PagePID values for the row where IndexLevel is 0 (this means its leaf level). On my setup it was like this

DBCC IND('tempdb','tbTestChange',-1) 

--

DBCC TRACEON(3604) --this is needed to send DBCC PAGE results to client 
DBCC PAGE('tempdb',1/* file num*/,1152/*page num*/,1)