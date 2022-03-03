const cdk = require('aws-cdk-lib');
const iam = require('aws-cdk-lib/aws-iam');
const lambda = require('aws-cdk-lib/aws-lambda');
const sns = require('aws-cdk-lib/aws-sns');
const sns_subscriptions = require('aws-cdk-lib/aws-sns-subscriptions');

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

      return (() => {

        const NAME = `${id}-ECHO-LAMBDA`;
        return new lambda.Function(this, NAME, {
          runtime: lambda.Runtime.NODEJS_14_X,
          functionName: NAME,
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



  }
}

module.exports = { AwsCdkSnsStack }
