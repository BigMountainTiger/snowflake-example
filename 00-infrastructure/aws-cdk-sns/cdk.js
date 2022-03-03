#!/usr/bin/env node

const cdk = require('aws-cdk-lib');
const { AwsCdkSnsStack } = require('./stacks/aws-cdk-sns-stack');

const app = new cdk.App();
new AwsCdkSnsStack(app, 'SNOWFLAKE-SNS-Stack', {});
