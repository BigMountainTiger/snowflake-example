SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();


CREATE storage integration IF NOT EXISTS S3_HUGE_HEAD_LI_2022
	type = external_stage
	storage_provider = s3
	storage_aws_role_arn = 'arn:aws:iam::275118158658:role/SNOWFLAKE-INTEGRATION-ROLE'
	enabled = true
	storage_allowed_locations = ('s3://snowflake-experiment-bucket.huge.head.li/');

DESC storage integration S3_HUGE_HEAD_LI_2022;

CREATE OR REPLACE NOTIFICATION INTEGRATION SNS_HUGE_HEAD_LI_2022
	TYPE = QUEUE
	ENABLED = TRUE
	NOTIFICATION_PROVIDER = AWS_SNS
  DIRECTION = OUTBOUND
	AWS_SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:275118158658:SNOWFLAKE-SNS-Stack-SNOWFLAKESNSStackTOPICC3902063-1MXBQMP8KUTB9'
	AWS_SNS_ROLE_ARN = 'arn:aws:iam::275118158658:role/SNOWFLAKE-SNS-Stack-SNS-INTEGRATION-ROLE';

DESC NOTIFICATION INTEGRATION SNS_HUGE_HEAD_LI_2022;

CREATE OR REPLACE STAGE S3_HUGE_HEAD_LI_2022_AAA
  url = 's3://snowflake-experiment-bucket.huge.head.li/'
  storage_integration = S3_HUGE_HEAD_LI_2022;

DESC STAGE S3_HUGE_HEAD_LI_2022_AAA;

CREATE OR REPLACE TABLE AAAA (
	Col_1 VARCHAR,
	Col_2 VARCHAR
);

CREATE OR REPLACE pipe AAAA_PIPE
	ERROR_INTEGRATION = SNS_HUGE_HEAD_LI_2022
	AS
	COPY INTO AAAA
	FROM @S3_HUGE_HEAD_LI_2022_AAA/AAAA/
	FILE_FORMAT = (TYPE = csv FIELD_DELIMITER = '|' SKIP_HEADER = 1 VALIDATE_UTF8 = FALSE)
	ON_ERROR = CONTINUE;
