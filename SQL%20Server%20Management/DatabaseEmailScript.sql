
DECLARE @mailid int

EXECUTE [msdb].[dbo].[sp_send_dbmail]
     @profile_name		= 'Gmail Notification Account',
     @recipients		= 'pflorenzano@buybooktech.com;mknox@buybooktech.com;smccord@buybooktech.com',
     @body			= 'This is just a test, please disregard',
     --@subject		= 'WEEKLY - KBB Report Generation',
	 @subject		= 'This is just a test, please disregard',
     @mailitem_id = @mailid OUTPUT

SELECT @mailid