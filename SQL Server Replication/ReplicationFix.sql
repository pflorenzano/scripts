
-- #1 Delete the subscription and publication that is inoperative

-- #2 Run the following scripts to identify the rows for the publication, to see if they are still available

USE Distribution
select * from msdb..MSdistpublishers
select * from distribution..MSpublisher_databases
select * from distribution..MSpublications
select * from distribution..MSarticles
select * from distribution..MSsubscriptions
select * from distribution..MSsnapshot_agents

-- #3 Delete the records from the following tables that still show the publisher_db as the deleted publisher database

delete from distribution..MSarticles where publisher_db = 'usedcarinvoice_dealers_shaft'
delete from distribution..MSsubscriptions where publisher_db = 'usedcarinvoice_dealers_shaft'
delete from distribution..MSpublications where publisher_db = 'bbt_base_vehicleinfo'
delete from distribution..MSpublisher_databases where publisher_db = 'usedcarinvoice_dealers_shaft'
delete from distribution..MSsnapshot_agents where publisher_db = 'usedcarinvoice_dealers_shaft'

-- #4 Re-create the publication and the subscriber as normal.