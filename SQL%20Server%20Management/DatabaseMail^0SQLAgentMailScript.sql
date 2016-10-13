
use master

DECLARE @SMTPServer VARCHAR(100)
DECLARE @AdminEmail VARCHAR(100)
DECLARE @DomainName VARCHAR(100)
DECLARE @replyToEmail VARCHAR(100)
/*
######################################################################
					PLEASE FILL OUT THIS
######################################################################
*/

SET @SMTPServer = 'smtp.mydomain.com'
SET @AdminEmail = 'klee@mydomain.com'
SET @DomainName = '@mydomain.com'
SET @replyToEmail = 'sqlserver@mydomain.com'
/*
######################################################################
*/

exec sp_configure 'show advanced options', 1
exec sp_configure 'Database Mail XPs', 1
exec sp_configure 'Agent XPs',1

RECONFIGURE WITH OVERRIDE

/*
######################################################################
					Setting Up Database Mail
######################################################################
*/

declare @servername varchar(100)
declare @email_address varchar(100)
declare @display_name varchar(100)
declare @testmsg varchar(100)

set @servername = replace(@@servername,'\','_')
set @email_address = @servername + @DomainName
set @display_name = 'MSSQL - ' + @servername
set @testmsg = 'Test from ' + @servername

IF EXISTS(SELECT * from msdb.dbo.sysmail_profile)
	PRINT 'DB mail already configured'
ELSE
BEGIN

	--Create database mail account.
	exec msdb.dbo.sysmail_add_account_sp
			@Account_name = 'SQLMail Account'
			, @description = 'Mail account for use by all database users.'
			, @email_address = @email_address
			, @replyto_address = @replyToEmail
			, @display_name = @display_name
			, @mailserver_name = @SMTPServer

	--Create global mail profile.
	exec msdb.dbo.sysmail_add_profile_sp
			@profile_name = 'SQLMail Profile'
			, @description = 'Mail profile setup for email from this SQL Server'

	--Add the account to the profile.
	exec msdb.dbo.sysmail_add_profileaccount_sp
			@profile_name = 'SQLMail Profile'
			, @Account_name = 'SQLMail Account'
			, @sequence_number=1

	--grant access to the profile to all users in the msdb database
	use msdb
	exec msdb.dbo.sysmail_add_principalprofile_sp
			 @profile_name = 'SQLMail Profile'
			, @principal_name = 'public'
			, @is_default = 1
END

--send a test message.
exec msdb..sp_send_dbmail
	@profile_name = 'SQLMail Profile', 
	@recipients = @AdminEmail,
	@subject = @testmsg,
	@body = @testmsg


EXEC msdb.dbo.sysmail_help_profile_sp

/*
######################################################################
					Setting Up SQL Agent Mail
######################################################################
*/

PRINT '##################################################################'
PRINT 'Enabling SQL Agent notification - THIS REQUIRES RESTART SQL AGENT'
PRINT '##################################################################'
-- Enabling SQL Agent notification
USE [msdb]
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail', N'REG_DWORD', 1
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', N'SQLMail Profile'

/*
-- Sample output

Configuration option 'show advanced options' changed from 0 to 1. Run the RECONFIGURE statement to install.
Configuration option 'Database Mail XPs' changed from 0 to 1. Run the RECONFIGURE statement to install.
Configuration option 'Agent XPs' changed from 1 to 1. Run the RECONFIGURE statement to install.
Mail queued.
##################################################################
Enabling SQL Agent notification - THIS REQUIRES RESTART SQL AGENT
##################################################################

(0 row(s) affected)

(0 row(s) affected)

*/
