USE ROLE SYSADMIN;
SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_WAREHOUSE();

DROP PROCEDURE IF EXISTS MLG_SNOWFLAKE.UTILITY.LOAD_UTIL_LIST_FILES_FROM_S3(VARCHAR);
DROP PROCEDURE IF EXISTS MLG_SNOWFLAKE.UTILITY.LOAD_SIMPLE_COPY_INTO_FROM_S3(VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS MLG_SNOWFLAKE.UTILITY.LOAD_FULL_REPLACE_FROM_S3(VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS MLG_SNOWFLAKE.UTILITY.LOAD_INCREMENTAL_FROM_S3(VARCHAR, VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS MLG_SNOWFLAKE.UTILITY.LOAD_APPEND_FROM_S3(VARCHAR, VARCHAR);