
DROP TABLE DatabaseSizeTable

CREATE TABLE [dbo].[DatabaseSizeTable] (
	[SERVERNAME] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TODAYS_DATE] [datetime] NOT NULL ,
	[DATABASENAME] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[DATABASE_SIZE] [int] NULL 
) ON [PRIMARY]
GO

DROP PROCEDURE sp_databasesize

GO

/*  Procedure for 8.0 server */  
create proc sp_databasesize
as
    set nocount on
    declare @name sysname
    declare @SQL  nvarchar(600)

    /* Use temporary table to sum up database size w/o using group by */
    create table #databasesize (
	      SERVER_NAME 		varchar(25)	 DEFAULT @@SERVERNAME,
	      TODAYS_DATE 		DATETIME	 DEFAULT GETDATE(),
                  DATABASE_ID 		int NOT NULL,
                  size 			int NOT NULL)

    declare c1 cursor for 
        select name from master.dbo.sysdatabases
            where has_dbaccess(name) = 1 -- Only look at databases to which we have access

    open c1
    fetch c1 into @name

    while @@fetch_status >= 0
    begin
        select @SQL = 'insert into #databasesize
                select @@SERVERNAME,  GETDATE(), '+ convert(sysname, db_id(@name)) + ', sum(size) from '
                + QuoteName(@name) + '.dbo.sysfiles'
        /* Insert row for each database */
        execute (@SQL)
        fetch c1 into @name
    end
    deallocate c1

INSERT INTO DatabaseSizeTable 
    select
        SERVER_NAME = @@SERVERNAME,  
        TODAYS_DATE = GETDATE(),    /*Current system date */
        DATABASE_NAME = db_name(DATABASE_ID),
        DATABASE_SIZE = size*8/* Convert from 8192 byte pages to K */
    from #databasesize
    order by 1
GO

