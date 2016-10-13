
CREATE CERTIFICATE [TDE_DB_EncryptionCert] 
	FROM FILE = 'F:\DATA\TDECert15Abak' 
		WITH PRIVATE KEY ( FILE = 'F:\DATA\TDECert15PrivateKeyFileAbak', 
			DECRYPTION BY PASSWORD = '<strong password>')


SELECT *
 FROM sys.certificates