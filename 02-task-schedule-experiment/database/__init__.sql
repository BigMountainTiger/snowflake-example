CREATE OR REPLACE PROCEDURE TSLEEP()
RETURNS VARIANT
LANGUAGE JAVASCRIPT
AS $$

	const t = 5;
	const st = snowflake.createStatement;

	stmt = `call system$wait(${t}, 'MINUTES')`;

	st({sqlText: stmt}).execute();
	st({sqlText: `ALTER TASK IF EXISTS TSLEEP_Task SUSPEND;`}).execute();

	return t;
$$;

CREATE OR REPLACE TASK TSLEEP_Task
      WAREHOUSE = COMPUTE_WH
      SCHEDULE = 'USING CRON * * * * * UTC'
      AS CALL TSLEEP();

ALTER TASK IF EXISTS TSLEEP_Task SUSPEND;

