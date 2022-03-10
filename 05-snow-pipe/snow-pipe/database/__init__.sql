SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();


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

CREATE OR REPLACE TABLE AAAA (
	Col_1 VARCHAR,
	Col_2 VARCHAR
);

CREATE pipe AAAA_PIPE AS
	COPY INTO AAAA
	FROM @S3_HUGE_HEAD_LI_2022_AAA/AAAA/
	FILE_FORMAT = (TYPE = csv FIELD_DELIMITER = '|' SKIP_HEADER = 1 VALIDATE_UTF8 = FALSE)
	ON_ERROR = CONTINUE;
