
-- Change All Object Owners to a given account (usually dbo) if not already owned by the SA 
-- (change the @NewOwner variable to another username string if you don't want DBO to own everything):

DECLARE @ObjectName varchar(256)
 SET @ObjectName = (
  SELECT TOP 1 [name] from sysobjects
   WHERE UID <> SUSER_SID('sa')
    AND [type] in ('FN','IF','P','TF','U','V')
   )
DECLARE @ObjectOwner varchar(256)
DECLARE @ObjectFullName varchar(512)
DECLARE @NewOwner varchar(256)
  SET @NewOwner = 'dbo'

  -- default to 'dbo' if null
  SET @NewOwner = isnull(@NewOwner, 'dbo')
   WHILE @ObjectName is not null
    BEGIN
     SELECT @ObjectOwner = USER_NAME(UID) 
      FROM sysobjects WHERE [name] = @ObjectName
      SET @ObjectFullName = @ObjectOwner + '.' + @Objectname
      PRINT 'Changing ownership of ''' + @Objectname + 
      ''' from ''' + @ObjectOwner + ''' to ''' + 
      @NewOwner + ''''
      EXECUTE sp_changeobjectowner @ObjectFullName, @NewOwner
      SET @ObjectName = (SELECT TOP 1 [name] FROM sysobjects
      WHERE UID <> SUSER_SID('sa') 
     AND [type] in ('FN','IF','P','TF','U','V'))
END

