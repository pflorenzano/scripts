
CREATE USER onereadonly FROM LOGIN onereadonly;
GO
EXEC sp_addrolemember 'db_datareader', 'onereadonly';