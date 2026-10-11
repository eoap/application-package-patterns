"""Wait for CI's disposable S3 service and create the results bucket."""
import os,time
import boto3
client=boto3.client('s3',endpoint_url=os.environ['PATTERNS_S3_ENDPOINT'],region_name='us-east-1',aws_access_key_id='test',aws_secret_access_key='test')
for attempt in range(60):
    try:
        client.list_buckets();client.create_bucket(Bucket='results');break
    except Exception:
        if attempt==59: raise
        time.sleep(2)
