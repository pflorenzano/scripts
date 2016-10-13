

ALTER DATABASE distribution SET OFFLINE

GO

ALTER DATABASE distribution 
	MODIFY FILE ( NAME = distribution , FILENAME = 'V:\MSSQL\DATA\distribution.MDF')

GO

ALTER DATABASE distribution 
	MODIFY FILE ( NAME = distribution_log , FILENAME = 'V:\MSSQL\LOG\distribution.ldf')

GO

ALTER DATABASE distribution SET ONLINE
