
USE bbt_marketplace_ac_main
select * 
from sys.indexes si
join sys.objects so on si.object_id = so.object_id
where 
    so.type = 'U'
and si.type <> 0
AND so.name = 'OfferAssignedDealer'
