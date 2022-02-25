const cdk = require('aws-cdk-lib');
const iam = require('aws-cdk-lib/aws-iam');
const lambda = require('aws-cdk-lib/aws-lambda');
const apigateway = require('aws-cdk-lib/aws-apigateway');
require('dotenv').config();

class AwsCdkApigwStack extends cdk.Stack {

  constructor(scope, id, props) {
    super(scope, id, props);

    (() => {
      const NAME = 'SNOWFLAKE-API-INTEGRATION-ROLE';

      // externalIds can be added for better security
      const props = {
        roleName: NAME,
        description: NAME,
        assumedBy: new iam.ArnPrincipal(process.env.INTEGRATION_ARN),
        // externalIds: ['ABCDEFGHIJKLMNOPQRST=']
      };

      const role = new iam.Role(this, `${id}-${NAME}`, props);
      role.addToPolicy(new iam.PolicyStatement({ effect: iam.Effect.DENY, resources: ['*'], actions: ['*'] }));

    })();

    (() => {

      const role = (() => {
        const NAME = 'SNOWFLAKE-API-INTEGRATION-LAMBDA-ROLE';

        const props = { roleName: NAME, assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com') };
        const role = new iam.Role(this, `${id}-${NAME}`, props);

        const actions = ['logs:CreateLogGroup', 'logs:CreateLogStream', 'logs:PutLogEvents'];
        role.addToPolicy(new iam.PolicyStatement({ effect: iam.Effect.ALLOW, resources: ['*'], actions: actions }));

        return role;
      })();

      const func = (() => {

        const NAME = 'SNOWFLAKE-ECHO-LAMBDA'
        const func = new lambda.Function(this, `${id}-${NAME}`, {
          runtime: lambda.Runtime.NODEJS_14_X,
          functionName: NAME,
          role: role,
          code: lambda.Code.fromAsset('./lambdas/echo-lambda'),
          handler: 'index.handler'
        });

        func.addPermission('ApiAccessPermission', {
          principal: new iam.ServicePrincipal('apigateway.amazonaws.com')
        })

        return func;
      })();

      (() => {
        const NAME = `SNOWFLAKE-API-INTEGRATION-IGW`;
        const api = new apigateway.RestApi(this, `${id}-${NAME}`, {
          restApiName: NAME,
          description: NAME,
          endpointTypes: [apigateway.EndpointType.REGIONAL]
        });

        api.root.addResource('echo')
          .addMethod('POST', new apigateway.LambdaIntegration(func, { proxy: true }));

      })();

    })();

  }
}

module.exports = { AwsCdkApigwStack }
