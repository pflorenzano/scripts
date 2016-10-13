

INSERT INTO "KOCSQL02"."ProductionDatabaseFiles"."dbo".tblFileInformation
SELECT 'KOCSQL02\OVOPS',
       'reporter',
       [name],
       [filename]
 FROM sysfiles