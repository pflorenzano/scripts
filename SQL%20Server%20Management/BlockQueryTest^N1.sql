
-- Query 1
-- Simulate a block to test the sp_who1 stored procedure

BEGIN TRANSACTION
UPDATE Pubs..Authors
 SET Phone = '212 575-3378'
  WHERE au_fname = 'SheryL' 
    AND au_lname = 'Hunter'