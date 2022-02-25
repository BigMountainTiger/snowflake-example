const cdk = require('aws-cdk-lib');
const iam = require('aws-cdk-lib/aws-iam');
const s3 = require('aws-cdk-lib/aws-s3');
require('dotenv').config();

class snowflakeExampleS3Stack extends cdk.Stack {

  constructor(scope, id, props) {
    super(scope, id, props);

    const bucket = (() => {
      const NAME = 'SNOWFLAKE-Experiment-BUCKET';

      return new s3.Bucket(this, `${id}-${NAME}`, {
        bucketName: `${NAME.toLowerCase()}.huge.head.li`,
        blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
        removalPolicy: cdk.RemovalPolicy.DESTROY,
        lifecycleRules: [{ expiration: cdk.Duration.days(1) }]
      });

    })();

    (() => {
      const NAME = 'SNOWFLAKE-INTEGRATION-ROLE';

      // externalIds can be added to provide better security to limit the
      // role only assumed by the integration only
      const role = new iam.Role(this, `${id}-${NAME}`, {
        roleName: NAME,
        description: NAME,
        assumedBy: new iam.ArnPrincipal(process.env.INTEGRATION_ARN),
        // externalIds: ['abcdefghijklmnopqrstuvwxyz==']
      });

      role.addToPolicy(new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        resources: [`${bucket.bucketArn}`],
        actions: [
          's3:ListBucket',
          's3:GetBucketLocation'
        ]
      }))

      role.addToPolicy(new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        resources: [`${bucket.bucketArn}/*`],
        actions: [
          's3:PutObject',
          's3:GetObject',
          's3:GetObjectVersion',
          's3:DeleteObject',
          's3:DeleteObjectVersion'
        ]
      }))

    })();

  }
}

module.exports = { snowflakeExampleS3Stack }
