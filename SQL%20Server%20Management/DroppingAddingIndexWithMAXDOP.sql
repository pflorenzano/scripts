
-- Example of Dropping and index WITH the MAXDOP option

ALTER TABLE Production.TransactionHistoryArchive
 DROP CONSTRAINT PK_TransactionHistoryArchive_TransactionID
  WITH (MAXDOP = 2, ONLINE = ON);
GO

-- Example of Adding and index WITH the MAXDOP option

ALTER TABLE Production.TransactionHistoryArchive WITH NOCHECK 
ADD CONSTRAINT PK_TransactionHistoryArchive_TransactionID PRIMARY KEY CLUSTERED (TransactionID)
WITH (FILLFACTOR = 75, ONLINE = ON, PAD_INDEX = ON, MAXDOP = 2 )



