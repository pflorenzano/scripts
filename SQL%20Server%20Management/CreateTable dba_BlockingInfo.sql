USE [SYSAdmin]
GO
/****** Object:  Table [dbo].[dba_BlockingInfo]    Script Date: 02/17/2009 12:11:06 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dba_BlockingInfo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RootSpid || BlockedSpid] [int] NOT NULL,
	[blocked By] [int] NOT NULL,
	[loginName] [sysname] NOT NULL,
	[sqlCmd] [nvarchar](4000) NULL,
	[cpu] [int] NULL,
	[physical_io] [int] NULL,
	[dataBaseName] [sysname] NOT NULL,
	[program_name] [sysname] NOT NULL,
	[hostName] [sysname] NOT NULL,
	[status] [sysname] NOT NULL,
	[cmd] [sysname] NOT NULL,
	[ecid] [int] NULL,
	[lastWaitType] [sysname] NOT NULL,
	[lastWaitresource] [sysname] NOT NULL,
	[createdate] [datetime] NULL,
 CONSTRAINT [PK__dba_BlockingInfo__ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
ON [PRIMARY]
) ON [PRIMARY]
