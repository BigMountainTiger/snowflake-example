#!/usr/bin/env node

const cdk = require('aws-cdk-lib');
const { AwsCdkApigwStack } = require('./stacks/aws-cdk-apigw-stack');

const app = new cdk.App();
new AwsCdkApigwStack(app, 'SNOWFLAKE-APIGW-Stack', {});
