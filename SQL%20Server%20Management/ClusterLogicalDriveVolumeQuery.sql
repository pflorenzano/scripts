
-- Listing of all logical drive volume names for every shared drive of the current server instance

SELECT DriveName  
FROM sys.dm_io_cluster_shared_drives  
ORDER BY DriveName 

--MKD34 Results (Drive Name) - Node1
F
H
J 
L
S
U

-- MKD35 Results (Drive Name) - Node2
G
K
T
V

