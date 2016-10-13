
CREATE DATABASE Modify_Title
ON 
( NAME = 'ModifyTitle_mdf',
   FILENAME = 'E:\Program Files\Microsoft SQL Server\MSSQL$TOWERDEV01\data\ModifyTitle_mdf',
   SIZE = 10,
   MAXSIZE = 50,
   FILEGROWTH = 5 )
LOG ON
( NAME = 'ModifyTitle_log',
   FILENAME = 'E:\Program Files\Microsoft SQL Server\MSSQL$TOWERDEV01\data\ModifyTitle_log',
   SIZE = 5MB,
   MAXSIZE = 25MB,
   FILEGROWTH = 5MB )
GO


