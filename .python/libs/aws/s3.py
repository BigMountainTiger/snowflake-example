import boto3
from env import env

REGION_NAME = 'us-east-1'
s3 = boto3.client(
    's3',
    aws_access_key_id=env.aws_access_key_id,
    aws_secret_access_key=env.aws_secret_access_key,
    region_name=REGION_NAME
)

def get_file_headers(file_name):
    resp = s3.select_object_content(
        Bucket='mlg-snowpipe',
        Key=file_name,
        ExpressionType='SQL',
        Expression='SELECT * FROM s3object LIMIT 1',
        InputSerialization={
            'CSV': {'FileHeaderInfo': 'NONE'}, 'CompressionType': 'NONE'},
        OutputSerialization={'CSV': {}},
    )

    header_line = None
    for event in resp['Payload']:
        if 'Records' in event:
            header_line = event['Records']['Payload'].decode('utf-8')

    return header_line
