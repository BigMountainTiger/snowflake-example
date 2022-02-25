SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA();

CREATE OR REPLACE PROCEDURE TSLEEP()
RETURNS VARIANT
LANGUAGE JAVASCRIPT
AS $$

  const st = snowflake.createStatement;
	// st({sqlText: `DROP TASK IF EXISTS TSLEEP_Task;`}).execute();
  st({sqlText: `ALTER TASK IF EXISTS TSLEEP_Task SUSPEND`}).execute();

	const t = 5;
	stmt = `call system$wait(${t}, 'MINUTES')`;
  st({sqlText: stmt}).execute();

	return t;
$$;

-- Task execution can overlap if re-created / replaced
CREATE OR REPLACE TASK TSLEEP_Task
      WAREHOUSE = COMPUTE_WH
      SCHEDULE = 'USING CRON * * * * * UTC'
      AS CALL TSLEEP();

-- Use alter to avoid-overlap

ALTER TASK IF EXISTS TSLEEP_Task RESUME;