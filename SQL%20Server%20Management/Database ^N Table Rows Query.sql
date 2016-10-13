
-- Database size of the MKD17.MSW_Tracking database on 04/19 was 6.9GB (After truncation)

--EXEC sp_who1

SELECT sysusers.name + N'.' + sysobjects.name as ObjectName,  
       sysindexes.name as IndexName, 
       sysindexes.rows, 
       case indid 
         when 1 then 1 else 0
       end as IsClusteredIndex,  
       sysindexes.indid, 
       sysobjects.name, 
       sysusers.name  
 FROM sysusers, sysobjects, sysindexes 
  WHERE sysusers.uid = sysobjects.uid 
   AND  sysindexes.id = sysobjects.id 
   AND  sysobjects.name not like '#%' 
   AND  OBJECTPROPERTY(sysobjects.id, N'IsMSShipped') <> 1 
   AND  OBJECTPROPERTY(sysobjects.id, N'IsSystemTable') = 0  
   AND  LEN(rows) >= 6
ORDER BY rows DESC


--TRUNCATE TABLE hct_RecipientURIMap
 