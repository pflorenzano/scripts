
 SELECT		v.name									AS table_name,
				SCHEMA_NAME(schema_id)	AS schema_name,
				c.name									AS column_name
	FROM sys.tables AS v
	  INNER JOIN sys.columns c ON v.OBJECT_ID = c.OBJECT_ID
		WHERE c.name LIKE '%site%'
	ORDER BY table_name;



