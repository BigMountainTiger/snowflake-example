const cdk = require('aws-cdk-lib');
const iam = require('aws-cdk-lib/aws-iam');
const lambda = require('aws-cdk-lib/aws-lambda');
const sns = require('aws-cdk-lib/aws-sns');
const sns_subscriptions = require('aws-cdk-lib/aws-sns-subscriptions');
require('dotenv').config();

class AwsCdkSnsStack extends cdk.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    const func = (() => {
      const role = (() => {

        const NAME = `${id}-LAMBDA-ROLE`;
        const props = { roleName: NAME, assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com') };
        const role = new iam.Role(this, NAME, props);

        const actions = ['logs:CreateLogGroup', 'logs:CreateLogStream', 'logs:PutLogEvents'];
        role.addToPolicy(new iam.PolicyStatement({ effect: iam.Effect.ALLOW, resources: ['*'], actions: actions }));

        return role;
      })();

      const layer = (() => {

        const NAME = `${id}-LAMBDA-DEPENDENCY`;
        return new lambda.LayerVersion(this, NAME, {
          layerVersionName: NAME,
          description: NAME,
          compatibleRuntimes: [lambda.Runtime.NODEJS_14_X],
          code: lambda.Code.fromAsset('./lambdas/dependencies')
        });
      })();

      return (() => {

        const NAME = `${id}-ECHO-LAMBDA`;
        return new lambda.Function(this, NAME, {
          runtime: lambda.Runtime.NODEJS_14_X,
          functionName: NAME,
          layers: [layer],
          role: role,
          code: lambda.Code.fromAsset('./lambdas/echo-lambda'),
          handler: 'index.handler'
        });

      })();

    })();

    const topic = (() => {
      const NAME = `${id}-TOPIC`;
      const topic = new sns.Topic(this, NAME, {
        displayName: NAME
      });

      topic.addSubscription(new sns_subscriptions.LambdaSubscription(func));
      return topic;
    })();

    (() => {
      const NAME = `${id}-SNS-INTEGRATION-ROLE`;

      const props = {
        roleName: NAME,
        description: NAME,
        assumedBy: new iam.ArnPrincipal(process.env.INTEGRATION_ARN),
      };

      const role = new iam.Role(this, NAME, props);
      role.addToPolicy(new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        resources: [`${topic.topicArn}`],
        actions: ['sns:Publish']
      }));

    })();

  }
}

module.exports = { AwsCdkSnsStack }
