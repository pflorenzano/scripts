
-- #1 Creating the Event Notification Components

-- Using msdb prevents the need for certificate signing the 
-- activation procedure to execute sp_send_dbmail across
-- databases
USE [msdb];
GO

-- Drop the notification if it exists
IF EXISTS ( SELECT  *
            FROM    sys.server_event_notifications
            WHERE   name = N'CaptureAutogrowEvents' ) 
    BEGIN
        DROP EVENT NOTIFICATION CaptureAutogrowEvents ON SERVER;
    END

-- Drop the route if it exists
IF EXISTS ( SELECT  *
            FROM    sys.routes
            WHERE   name = N'AutogrowEventRoute' ) 
    BEGIN
        DROP ROUTE AutogrowEventRoute;
    END

-- Drop the service if it exists
IF EXISTS ( SELECT  *
            FROM    sys.services
            WHERE   name = N'AutogrowEventService' ) 
    BEGIN
        DROP SERVICE AutogrowEventService;
    END

-- Drop the queue if it exists
IF EXISTS ( SELECT  *
            FROM    sys.service_queues
            WHERE   name = N'AutogrowEventQueue' ) 
    BEGIN
        DROP QUEUE AutogrowEventQueue;
    END

--  Create a service broker queue to hold the events
CREATE QUEUE [AutogrowEventQueue]
WITH STATUS=ON;
GO

--  Create a service broker service receive the events
CREATE SERVICE [AutogrowEventService]
ON QUEUE [AutogrowEventQueue] ([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
GO

-- Create a service broker route to the service
CREATE ROUTE [AutogrowEventRoute]
WITH SERVICE_NAME = 'AutogrowEventService',
ADDRESS = 'LOCAL';
GO

-- Create the event notification to capture the events
CREATE EVENT NOTIFICATION [CaptureAutogrowEvents]
ON SERVER
WITH FAN_IN
FOR DATA_FILE_AUTO_GROW, LOG_FILE_AUTO_GROW
TO SERVICE 'AutogrowEventService', 'current database';
GO

--- #2 Testing Event Notification

USE [master];
GO
IF DB_ID('Test') IS NOT NULL 
    BEGIN
        ALTER DATABASE [Test] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE [Test];
    END
CREATE DATABASE [Test]
GO
BACKUP DATABASE [Test] 
TO DISK = N'J:\Backups\Test.bak'
WITH INIT;
GO

USE bbt_base_vehicleinfo
GO
CREATE TABLE [Test]
    (
      RowID INT IDENTITY
                PRIMARY KEY ,
      datacol CHAR(4000) NOT NULL
                         DEFAULT ( '' )
    )
GO
INSERT  INTO [Test]
        DEFAULT VALUES;
GO 1000

-- #3 Selecting events from the queue

USE [msdb];
GO
SELECT 
  EventType = message_body.value('(/EVENT_INSTANCE/EventType)[1]',
                                       'varchar(128)') ,
  Duration = message_body.value('(/EVENT_INSTANCE/Duration)[1]',
                                'varchar(128)') ,
  ServerName = message_body.value('(/EVENT_INSTANCE/ServerName)[1]',
                                  'varchar(128)') ,
  PostTime = CAST(message_body.value('(/EVENT_INSTANCE/PostTime)[1]',
                                     'datetime') AS VARCHAR) ,
  DatabaseName = message_body.value('(/EVENT_INSTANCE/DatabaseName)[1]',
                                    'varchar(128)') ,
  GrowthPages = message_body.value('(/EVENT_INSTANCE/IntegerData)[1]',
                                   'int')
FROM    ( SELECT    CAST(message_body AS XML) AS message_body
                 FROM      [AutogrowEventQueue]
				       ) AS Tab
	  WHERE message_body.value('(/EVENT_INSTANCE/DatabaseName)[1]',
                                    'varchar(128)') <> 'bbt_marketplace_ac_main'

--  #4 Create the Activation Stored Procedure to Process the Queue

IF EXISTS ( SELECT  *
            FROM    dbo.sysobjects
            WHERE   id = OBJECT_ID(N'[dbo].[SQLskills_ProcessAutogrowEvents]')
                    AND OBJECTPROPERTY(id, N'IsProcedure') = 1 ) 
    DROP PROCEDURE [dbo].[SQLskills_ProcessAutogrowEvents];
GO

CREATE PROCEDURE [dbo].[SQLskills_ProcessAutogrowEvents]
    WITH EXECUTE AS OWNER
AS 
    DECLARE @message_body XML;
    DECLARE @message_sequence_number INT;
    DECLARE @dialog UNIQUEIDENTIFIER;
    DECLARE @email_message NVARCHAR(MAX);
	DECLARE @MailSubject VARCHAR(200);

	WHILE ( 1 = 1 ) 
        BEGIN
            BEGIN TRANSACTION;

-- Receive the next available message FROM the queue

WAITFOR
   (
      RECEIVE TOP(1) -- just handle one message at a time
         @message_body=CAST(message_body AS XML)
         FROM dbo.AutogrowEventQueue
   ), TIMEOUT 1000; -- if queue empty for 1 sec, give UPDATE AND GO away

-- If we didn't get anything, bail out
            IF ( @@ROWCOUNT = 0 ) 
                BEGIN
                    ROLLBACK TRANSACTION;
                    BREAK;
                END 

            DECLARE @EventType VARCHAR(128);
            DECLARE @ServerName VARCHAR(128);
            DECLARE @PostTime VARCHAR(128);
            DECLARE @DatabaseName VARCHAR(128);
            DECLARE @Duration VARCHAR(128);
            DECLARE @GrowthPages INT;

			SELECT              @EventType =                 @message_body.value('(/EVENT_INSTANCE/EventType)[1]',
                                     'varchar(128)') ,
              @Duration =                 @message_body.value('(/EVENT_INSTANCE/Duration)[1]',
                                     'varchar(128)') ,
              @ServerName =                 @message_body.value('(/EVENT_INSTANCE/ServerName)[1]',
                                     'varchar(128)') ,
              @PostTime =                CAST(@message_body.value('(/EVENT_INSTANCE/PostTime)[1]',
                                                         'datetime')                                                         AS VARCHAR) ,
              @DatabaseName =                 @message_body.value('(/EVENT_INSTANCE/DatabaseName)[1]',
                                     'varchar(128)') ,
              @GrowthPages =                 @message_body.value('(/EVENT_INSTANCE/IntegerData)[1]',
                                     'int');
-- Generate formatted email message
            SELECT  @email_message = 'The following autogrow event                                      occurred:'
                    + CHAR(10) + CAST('ServerName: ' AS CHAR(25))
                    + @ServerName + CHAR(10) + CAST('PostTime: '                                                     AS CHAR(25))
                    + @PostTime + CHAR(10)
                    + CAST('DatabaseName: ' AS CHAR(25)) + @DatabaseName
                    + CHAR(10) + CAST('Duration: ' AS CHAR(25))                    + @Duration
                    + CHAR(10) + CAST('GrowthSize_KB: ' AS CHAR(25))
                    + CAST(( @GrowthPages * 8 ) AS VARCHAR(20));

			SET @MailSubject = 'FileGrow event notification on database ' +@ServerName+ '.' +@DatabaseName+ ''

-- Send email using Database Mail
            EXEC msdb.dbo.sp_send_dbmail                
				@profile_name = 'BBT Database Mail', -- your defined email profile 
				--@recipients = 'pflorenzano@buybooktech.com', -- your email
				@recipients = 'pflorenzano@buybooktech.com;smccord@buybooktech.com',
                @subject = @MailSubject, 
                @body = @email_message;

--  Commit the transaction.  At any point before this, we could roll 
--  back. The received message would be back on the queue AND the 
--  response wouldn't be sent.
            COMMIT TRANSACTION;
        END
GO

-- #5 Setting the queue to use the activation stored procedure

ALTER QUEUE [AutogrowEventQueue]
   WITH STATUS=ON, 
      ACTIVATION 
         (STATUS=ON,
          PROCEDURE_NAME = [SQLskills_ProcessAutogrowEvents],
          MAX_QUEUE_READERS = 1,
          EXECUTE AS OWNER);
GO