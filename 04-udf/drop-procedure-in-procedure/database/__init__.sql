execute immediate $$
begin
    USE DATABASE MLG_SNOWFLAKE;
    USE SCHEMA UTILITY;
    USE ROLE SYSADMIN;

    return 'Initiated the context';
end;
$$;

SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();

CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.DROP_PROCEDURE_IN_PROCEDURE(PARAM1 VARCHAR)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    query = `DROP PROCEDURE IF EXISTS MLG_SNOWFLAKE.UTILITY.DROP_PROCEDURE_IN_PROCEDURE(VARCHAR)`;
    const rs = st({sqlText: query}).execute();
    rs.next();

    return rs.getColumnValue(1);
$$;

-- This example shows that we can drop a procedure by itself
CALL MLG_SNOWFLAKE.UTILITY.DROP_PROCEDURE_IN_PROCEDURE('SUCCESS');