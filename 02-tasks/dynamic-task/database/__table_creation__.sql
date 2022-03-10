CREATE storage integration IF NOT EXISTS S3_HUGE_HEAD_LI_2022
	type = external_stage
	storage_provider = s3
	storage_aws_role_arn = 'arn:aws:iam::275118158658:role/SNOWFLAKE-INTEGRATION-ROLE'
	enabled = true
	storage_allowed_locations = ('s3://snowflake-experiment-bucket.huge.head.li/');

CREATE STAGE IF NOT EXISTS S3_HUGE_HEAD_LI_2022_AAA
  url = 's3://snowflake-experiment-bucket.huge.head.li/'
  storage_integration = S3_HUGE_HEAD_LI_2022;

CREATE FILE FORMAT IF NOT EXISTS CSV_FILE_HEADER TYPE = 'csv';

CREATE OR REPLACE PROCEDURE CREATE_TABLE(FILE VARCHAR)
RETURNS VARIANT
LANGUAGE JAVASCRIPT
AS $$

	const st = snowflake.createStatement;

	const header_text = (() => {
		const format = 'CSV_FILE_HEADER'
		const stage = '@S3_HUGE_HEAD_LI_2022_AAA';
		const rs = st({sqlText: `SELECT T.$1 FROM ${stage}/${FILE} (FILE_FORMAT => ${format}) T LIMIT 1;`}).execute();
		if (rs.getRowCount() === 0) {
			throw `Unable to query ${FILE}, is the file path correct?`;
		}
		rs.next();

		return rs.getColumnValue(1); 
	})();

	const table_name = (() => {
		const parts = FILE.split('.');
		return parts[0].toUpperCase();
	})();
	
	const query = (() => {
		const headers = header_text.split('|');
		let result = '', len = headers.length;

		for (let i = 0; i < len; i++) {
			const item = headers[i]
				.replace(/ /g, '_')
				.replace(/-/g, '_');
			const line_end = (i == len - 1)? '\n' : ', \n'
			result = `${result}\t${item} VARCHAR${line_end}`;
		}

		return `CREATE OR REPLACE TABLE ${table_name} (
			${result}
		);`;

	})();

	const result = (() => {
		const rs = st({sqlText: query}).execute();
		rs.next();

		return rs.getColumnValue(1); 
	})();

	return result;
$$;

CALL CREATE_TABLE('AAAA.txt');