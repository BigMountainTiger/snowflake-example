execute immediate $$
begin
    USE DATABASE MLG_SNOWFLAKE;
    USE SCHEMA UTILITY;
    USE ROLE SYSADMIN;

    return 'Initiated the context';
end;
$$;

DROP PROCEDURE IF EXISTS MLG_SNOWFLAKE.UTILITY.CREDENTIAL_EXAMPLE_PROCEDURE(VARCHAR, VARCHAR);
DROP TASK IF EXISTS MLG_SNOWFLAKE.UTILITY.CREDENTIAL_EXAMPLE_TASK;