ALTER TASK IF EXISTS TSLEEP_Task RESUME;

SELECT  *
  FROM TABLE(INFORMATION_SCHEMA.task_history())
  WHERE NAME = 'TSLEEP_TASK';