
SP_CONFIGURE 'show advanced options', 1 ;
GO
RECONFIGURE ;
GO
--Now that the advanced options are on, the Blocked Process Report
--can be turned on, using this code:
SP_CONFIGURE 'blocked process threshold', 10 ;
GO
RECONFIGURE ;
GO