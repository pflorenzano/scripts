
Use Master
go
CREATE DATABASE MyDB1
ON 
( NAME = MyDB1_dat,
    FILENAME = 'D:\SQL_DATA\FileMyDB1.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = MyDB1_log,
    FILENAME = 'D:\SQL_DATA\FileMyDB1.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB )
GO

use master
go
sp_detach_db 'MyDB1'
go

sp_attach_db 'MyDb1',
'D:\SQL_DATA\FileMyDB1.mdf',
'D:\SQL_DATA\FileMyDB1.ldf'
GO

use master
go
sp_configure 'show advanced options',1
go
reconfigure with override
go
sp_configure 'xp_cmdshell',1
go
reconfigure with override
go


use master
go
sp_detach_db 'MyDB1'
go
exec master..xp_cmdshell 'del "D:\SQL_DATA\FileMyDB1.ldf"'
go

CREATE DATABASE MyDB1
ON 
(
FILENAME = 'D:\SQL_DATA\FileMyDB1.mdf'
) for ATTACH_REBUILD_LOG
Result:




