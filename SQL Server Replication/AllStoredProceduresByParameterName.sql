
SELECT parm.name AS Parameter,        
			typ.name AS [Type],
			sp.name
FROM sys.procedures sp
JOIN sys.parameters parm ON sp.object_id = parm.object_id
JOIN sys.types typ ON parm.system_type_id = typ.system_type_id
WHERE parm.name LIKE '%Date%'