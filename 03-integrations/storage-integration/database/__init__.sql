-- https://docs.snowflake.com/en/sql-reference/sql/create-storage-integration.html
-- https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration.html
-- https://docs.snowflake.com/en/user-guide/data-load-s3-config-aws-iam-user.html

SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA();

CREATE storage integration IF NOT EXISTS S3_HUGE_HEAD_LI_2022
	type = external_stage
	storage_provider = s3
	storage_aws_role_arn = 'arn:aws:iam::275118158658:role/SNOWFLAKE-INTEGRATION-ROLE'
	enabled = true
	storage_allowed_locations = ('s3://snowflake-experiment-bucket.huge.head.li/');

DESC storage integration S3_HUGE_HEAD_LI_2022;

CREATE OR REPLACE STAGE S3_HUGE_HEAD_LI_2022_AAA
  url = 's3://snowflake-experiment-bucket.huge.head.li/'
  storage_integration = S3_HUGE_HEAD_LI_2022;

DESC STAGE S3_HUGE_HEAD_LI_2022_AAA;

CREATE OR REPLACE FILE FORMAT AAA TYPE = 'csv' field_delimiter = '|';
CREATE OR REPLACE FILE FORMAT AAA_HEADER TYPE = 'csv';

SHOW FILE FORMATS;

-- https://docs.snowflake.com/en/user-guide/querying-stage.html

SELECT T.$1, T.$2 FROM @S3_HUGE_HEAD_LI_2022_AAA/AAAA.txt
  (FILE_FORMAT => AAA) T;

-- Header only
SELECT T.$1, T.$2 FROM @S3_HUGE_HEAD_LI_2022_AAA/AAAA.txt
  (FILE_FORMAT => AAA) T LIMIT 1;

-- Whole header
SELECT T.$1 FROM @S3_HUGE_HEAD_LI_2022_AAA/AAAA.txt
  (FILE_FORMAT => AAA_HEADER) T LIMIT 1;

-- Clean up

DROP storage integration IF EXISTS S3_HUGE_HEAD_LI_2022;
DROP STAGE IF EXISTS S3_HUGE_HEAD_LI_2022_AAA;
DROP FILE FORMAT IF EXISTS AAA;
DROP FILE FORMAT IF EXISTS AAA_HEADER;




