
-- Service Broker Schema dropping procedure

-- #1 Find all referenced objects

SELECT * 
	FROM sys.objects 
		WHERE name='value'

-- #2 Remove the referenced ojects

-- Drop Queue
DROP QUEUE [SERVICES_SB].[value]
GO

-- Drop Services
DROP SERVICE [value]
GO

-- Drop Stored Procedure
DROP PROCEDURE [SERVICES_SB].[SqlQueryNotificationStoredProcedure-value]
GO

-- Drop Schema
DROP SCHEMA [SERVICES_SB]







