
--  Query to determine what type of authentication was performed on each connection. 

SELECT  
    s.session_id 
  , c.connect_time 
  , s.login_time 
  , s.login_name 
  , c.protocol_type 
  , c.auth_scheme 
  , s.HOST_NAME 
  , s.program_name 
FROM sys.dm_exec_sessions s 
  JOIN sys.dm_exec_connections c 
    ON s.session_id = c.session_id