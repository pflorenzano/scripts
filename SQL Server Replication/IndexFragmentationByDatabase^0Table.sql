
-- Old fashion way

DBCC SHOWCONTIG (TIM_PurchaseOffer_VehicleArea)

-- New Way

DECLARE @DATABASE   VARCHAR(255)
DECLARE @TableName  VARCHAR(255)
DECLARE @IndexName  VARCHAR(255) 

SET @DATABASE   = 'bbt_marketplace_main'
SET @TableName  = 'TIM_PurchaseOffer'
SET @IndexName  = NULL

SELECT 
     avg_fragmentation_in_percent
     ,page_count
FROM sys.dm_db_index_physical_stats
(
     DB_ID(@DATABASE)
     ,OBJECT_ID(@TableName)
     ,OBJECT_ID(@IndexName)
     ,NULL
     ,NULL
)