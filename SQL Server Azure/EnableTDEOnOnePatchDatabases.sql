
-- Enable encryption on onepatch databases (th-dca0-psql05)

-- dca0-onepatch-adaptive

ALTER DATABASE [dca0-onepatch-adaptive] SET ENCRYPTION ON;  
GO 

-- dca0-onepatch-clientservices

ALTER DATABASE [dca0-onepatch-clientservices] SET ENCRYPTION ON;  
GO

-- dca0-onepatch-cms

ALTER DATABASE [dca0-onepatch-cms] SET ENCRYPTION ON;  
GO

-- dca0-onepatch-idm

ALTER DATABASE [dca0-onepatch-idm] SET ENCRYPTION ON;  
GO

-- dca0-onepatch-management

ALTER DATABASE [dca0-onepatch-management] SET ENCRYPTION ON;  
GO

-- dca0-onepatch-metering

ALTER DATABASE [dca0-onepatch-metering] SET ENCRYPTION ON;  
GO

-- dca0-onepatch-reporting

ALTER DATABASE [dca0-onepatch-reporting] SET ENCRYPTION ON;  
GO

-- dca0-onepatch-services

ALTER DATABASE [dca0-onepatch-services] SET ENCRYPTION ON;  
GO

-- dca0-onepatch-usermanagement

ALTER DATABASE [dca0-onepatch-usermanagement] SET ENCRYPTION ON;  
GO  

-- Execute the following query (per database) to view encryption keys:

SELECT *
 FROM sys.dm_database_encryption_keys;

