#!/usr/bin/env node

const cdk = require('aws-cdk-lib');
const { snowflakeExampleS3Stack } = require('./stacks/snowflake-example-s3-stack');

const app = new cdk.App();
new snowflakeExampleS3Stack(app, 'SNOWFLAKE-S3-Stack', {});
