
  
  -- Monitor Log Shipping status

exec sp_executesql @stmt=N'exec sp_help_log_shipping_monitor',@params=N''