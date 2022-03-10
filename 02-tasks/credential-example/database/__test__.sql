execute immediate $$
begin
    USE DATABASE MLG_SNOWFLAKE;
    USE SCHEMA UTILITY;
    USE ROLE SYSADMIN;

    return 'Initiated the context';
end;
$$;

SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();

CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.CREDENTIAL_EXAMPLE_PROCEDURE(
  SCHEMA_NAME VARCHAR,
  TABLE_NAME VARCHAR
)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const rs = st({sqlText: `SELECT TABLE_NAME, LAST_LOAD_TIME, STATUS, ROW_COUNT, ROW_PARSED, ERROR_COUNT FROM INFORMATION_SCHEMA.LOAD_HISTORY
      WHERE SCHEMA_NAME = '${SCHEMA_NAME}' AND TABLE_NAME = '${TABLE_NAME}'
      ORDER BY LAST_LOAD_TIME DESC LIMIT 1;`}).execute();
    rs.next();

    const getv = i => rs.getColumnValue(i);

    const status = {
      TABLE_NAME: getv(1),
      LAST_LOAD_TIME: getv(2),
      STATUS: getv(3),
      ROW_COUNT: getv(4),
      ROW_PARSED: getv(5),
      ERROR_COUNT: getv(6)
    };

    return status;
$$;

CALL MLG_SNOWFLAKE.UTILITY.CREDENTIAL_EXAMPLE_PROCEDURE('DATA_INTEGRATIONS', 'LEAD');


CREATE OR REPLACE TASK MLG_SNOWFLAKE.UTILITY.CREDENTIAL_EXAMPLE_TASK
      WAREHOUSE = COMPUTE_WH
      SCHEDULE = 'USING CRON * * * * * UTC'
      AS CALL MLG_SNOWFLAKE.UTILITY.CREDENTIAL_EXAMPLE_PROCEDURE('DATA_INTEGRATIONS', 'LEAD');

ALTER TASK IF EXISTS MLG_SNOWFLAKE.UTILITY.CREDENTIAL_EXAMPLE_TASK SUSPEND;

