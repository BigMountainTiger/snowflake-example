
SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_WAREHOUSE();

CREATE storage integration IF NOT EXISTS S3_HUGE_HEAD_LI_2022
	type = external_stage
	storage_provider = s3
	storage_aws_role_arn = 'arn:aws:iam::275118158658:role/SNOWFLAKE-INTEGRATION-ROLE'
	enabled = true
	storage_allowed_locations = ('s3://snowflake-experiment-bucket.huge.head.li/');

DESC storage integration S3_HUGE_HEAD_LI_2022;

CREATE OR REPLACE STAGE S3_HUGE_HEAD_LI_2022_STAGE
  url = 's3://snowflake-experiment-bucket.huge.head.li/'
  storage_integration = S3_HUGE_HEAD_LI_2022;

DESC STAGE S3_HUGE_HEAD_LI_2022_STAGE;

CREATE OR REPLACE FILE FORMAT CSV_WHOLE_LINE TYPE = 'csv';

DESC FILE FORMAT CSV_WHOLE_LINE;


