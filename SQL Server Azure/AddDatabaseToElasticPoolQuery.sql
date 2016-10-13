
-- Add database to Elastic Pool

CREATE DATABASE PMFTest ( SERVICE_OBJECTIVE = ELASTIC_POOL (name = [dca0-ElasticPool-1] ));
-- Create a database named db1 in a pool named S3M100.