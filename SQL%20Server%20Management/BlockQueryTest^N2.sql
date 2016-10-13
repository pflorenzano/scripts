
-- Query 2
-- Simulate a block to test the sp_who1 stored procedure

BEGIN TRANSACTION

INSERT INTO Pubs..Employee
 VALUES ('ABC12345M','Peter','','Florenzano',10,100,1389,'2005-03-16')

UPDATE pubs..Authors
 SET phone = '212 575-3368'
  WHERE au_fname = 'Sheryl'
    AND au_lname = 'Hunter'