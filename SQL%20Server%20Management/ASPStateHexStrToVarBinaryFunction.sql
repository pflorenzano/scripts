
-- Convert Hex Strong to VarBinary

CREATE FUNCTION dbo.HexStrToVarBinary(@hexstr varchar(8000))
RETURNS varbinary(8000)
AS
BEGIN     
	DECLARE @hex char(1), @i int, @place bigint, @a bigint    
	SET @i = LEN(@hexstr)     
	
	SET @place = convert(bigint,1)    
	SET @a = convert(bigint, 0)    
	
	WHILE (@i > 0 AND (substring(@hexstr, @i, 1) like '[0-9A-Fa-f]'))      
		BEGIN         
			SET @hex = SUBSTRING(@hexstr, @i, 1)         
			SET @a = @a +     
		CONVERT(bigint, CASE WHEN @hex LIKE '[0-9]'          
			THEN CAST(@hex as int)          
			ELSE CAST(ASCII(UPPER(@hex))-55 as int) end * @place)    
		SET @place = @place * convert(bigint,16)        
			SET @i = @i - 1         
		END     
		
		RETURN convert(varbinary(8000),@a)
		
		END
		GO 