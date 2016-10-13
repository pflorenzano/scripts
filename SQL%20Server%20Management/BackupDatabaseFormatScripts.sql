
-- Error 3013

-- Run these scripts to re-format the backup job

RESTORE HEADERONLY FROM DISK='\\KOCPRTPLANT01\MicrosoftSQLServer\TowerDatabaseBackups\TowerDBRemoteDifferential.BAK'

BACKUP DATABASE TowerDB TO DISK='\\KOCPRTPLANT01\MicrosoftSQLServer\TowerDatabaseBackups\TowerDBRemoteDifferential.BAK' with FORMAT