
SELECT     name,
       CASE         
         WHEN is_percent_growth = 0  THEN LTRIM(STR(growth * 8.0 / 1024,10,1)) + ' MB, '         
           ELSE            'By ' + CAST(growth AS VARCHAR) + ' percent, '    
              END +     CASE         
          WHEN max_size = -1 THEN 'unrestricted growth'        
            ELSE 'restricted growth to ' +   LTRIM(STR(max_size * 8.0 / 1024,10,1)) + ' MB'     
               END AS Autogrow
       FROM sys.database_files