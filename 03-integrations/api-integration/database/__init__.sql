-- Create the API integration
CREATE OR REPLACE api integration EXPERIMENT_API_INTEGRATION_123450
    api_provider=aws_api_gateway
    api_aws_role_arn='arn:aws:iam::275118158658:role/SNOWFLAKE-API-INTEGRATION-ROLE'
    api_allowed_prefixes=('https://kstge78ggc.execute-api.us-east-1.amazonaws.com/prod/')
    ENABLED=true;

DESC api integration EXPERIMENT_API_INTEGRATION_123450;

-- Create the external function
CREATE OR REPLACE EXTERNAL FUNCTION EXPERIMENT_EXT_FUNTION_123450(A VARCHAR)
    RETURNS VARIANT
    api_integration = EXPERIMENT_API_INTEGRATION_123450
    AS 'https://kstge78ggc.execute-api.us-east-1.amazonaws.com/prod/echo';

DESC FUNCTION EXPERIMENT_EXT_FUNTION_123450(VARCHAR);

-- Call the external function
SELECT EXPERIMENT_EXT_FUNTION_123450('ABCD is echoed');

-- Clean up
DROP FUNCTION IF EXISTS EXPERIMENT_EXT_FUNTION_123450(VARCHAR);
DROP api integration IF EXISTS EXPERIMENT_API_INTEGRATION_123450;



