-- Recreate pipe so load the test file multiple times
CREATE OR REPLACE pipe AAAA_PIPE
	ERROR_INTEGRATION = SNS_HUGE_HEAD_LI_2022
	AS
	COPY INTO AAAA
	FROM @S3_HUGE_HEAD_LI_2022_AAA/AAAA/
	FILE_FORMAT = (TYPE = csv FIELD_DELIMITER = '|' SKIP_HEADER = 1 VALIDATE_UTF8 = FALSE)
	ON_ERROR = CONTINUE;

ALTER pipe AAAA_PIPE refresh;

SELECT *
FROM TABLE(information_schema.copy_history(table_name=>'AAAA',
	start_time=> dateadd(hours, -10, current_timestamp())))
ORDER BY PIPE_RECEIVED_TIME DESC;
