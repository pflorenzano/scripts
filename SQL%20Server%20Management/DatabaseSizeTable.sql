CREATE TABLE [dbo].[DatabaseSizeTable] (
	[SERVERNAME] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TODAYS_DATE] [datetime] NOT NULL ,
	[DATABASENAME] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DATABASE_SIZE] [int] NULL 
) ON [PRIMARY]
GO

