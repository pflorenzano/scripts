
/*You can move tempdb files with ALTER DATABASE ... MODIFY FILE, specifying
  the desired file locations. Delete the old files after restarting SQL
  Server. For example:
*/

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdev', FILENAME='U:\MSSQL\DATA\tempdb.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='templog', FILENAME='U:\MSSQL\LOG\templog.ldf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdev2', FILENAME='L:\MSSQL\LOG\tempdb2.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb3', FILENAME='L:\MSSQL\LOG\tempdb3.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb4', FILENAME='L:\MSSQL\LOG\tempdb4.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb5', FILENAME='L:\MSSQL\LOG\tempdb5.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb6', FILENAME='L:\MSSQL\LOG\tempdb6.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb7', FILENAME='L:\MSSQL\LOG\tempdb7.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb8', FILENAME='L:\MSSQL\LOG\tempdb8.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb9', FILENAME='L:\MSSQL\LOG\tempdb9.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb12', FILENAME='L:\MSSQL\LOG\tempdb12.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb13', FILENAME='L:\MSSQL\LOG\tempdb13.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb14', FILENAME='L:\MSSQL\LOG\tempdb14.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb15', FILENAME='L:\MSSQL\LOG\tempdb15.mdf')

ALTER DATABASE tempdb
MODIFY FILE(NAME='tempdb16', FILENAME='L:\MSSQL\LOG\tempdb16.mdf')