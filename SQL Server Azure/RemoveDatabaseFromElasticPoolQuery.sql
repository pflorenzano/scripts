
-- Remove database out of Elastic Pool

ALTER DATABASE PMFTest MODIFY ( SERVICE_OBJECTIVE = 'S1');
-- Changes the database into a stand-alone database with the service objective S1.