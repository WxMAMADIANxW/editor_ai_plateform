import json
import logging
import os
import logging
import boto3
from botocore.exceptions import ClientError

REGION = os.getenv("AWS_REGION", "us-east-1")
BUCKET_NAME = os.getenv("BUCKET_NAME")


def create_presigned_get(bucket_name, object_name, expiration=3600):
    """Generate a presigned URL S3 GET request to upload a file
    """

    # Generate a presigned S3 POST URL
    s3_client = boto3.client('s3')
    try:
        response = s3_client.generate_presigned_url('get_object', Params={'Bucket': bucket_name, 'Key': object_name},
                                                    ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL and required fields
    return response


def lambda_handler(event, context):
    # Create a lambda handler function that will be called by the API Gateway and return a presigned URL to get an object in the S3 bucket.
    # The object name will be passed in the pathParameters of the event parameter.
    s3_client = boto3.client('s3', region_name=REGION, config=boto3.session.Config(signature_version='s3v4', ))
    object_name = event['pathParameters']['object_name']
    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': BUCKET_NAME,
                                                            'Key': object_name})
    except Exception as e:
        print(e)
        logging.error(e)
        return "Error"
    # The response contains the presigned URL
    return {'statusCode': 200, 'body': json.dumps(response)}
