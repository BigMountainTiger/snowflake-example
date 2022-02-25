ALTER pipe AAAA_PIPE refresh;

SELECT *
FROM TABLE(information_schema.copy_history(table_name=>'AAAA',
	start_time=> dateadd(hours, -10, current_timestamp())))
ORDER BY PIPE_RECEIVED_TIME DESC;


-- Experiment confirms that

-- 1. If CREATE OR REPLACE is issued on the pipe
-- 2. and if ALTER pipe AAAA_PIPE refresh is used to triger the run
-- Duplicates can be introduced and the same file will be reloaded