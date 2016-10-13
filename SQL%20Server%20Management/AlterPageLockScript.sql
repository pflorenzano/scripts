
USE SysAdmin
Exec sp_execdbmaint 'OPT'

ALTER INDEX P1coStringH ON coStringH SET (ALLOW_PAGE_LOCKS = ON)