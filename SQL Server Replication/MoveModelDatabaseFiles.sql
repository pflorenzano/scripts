
USE master; 
GO 
ALTER DATABASE model
MODIFY FILE (NAME = modeldev,FILENAME = 'X:\MSSQL\DATA\model.mdf'); 
GO 
ALTER DATABASE model
MODIFY FILE (NAME = Modellog,FILENAME = 'Y:\MSSQL\LOG\modelLog.ldf'); 
GO 