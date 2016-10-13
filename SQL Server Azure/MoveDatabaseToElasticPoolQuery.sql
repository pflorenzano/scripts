
-- Move database to Elastic Pool

ALTER DATABASE PMFTest MODIFY ( SERVICE_OBJECTIVE = ELASTIC_POOL (name = [dca0-ElasticPool-1] ));
-- Move the database named db1 to a pool named S3100.