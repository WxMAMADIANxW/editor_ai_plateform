import json
import logging
import os
import logging
import boto3
from botocore.exceptions import ClientError

REGION = os.getenv("AWS_REGION", "us-east-1")
BUCKET_NAME = os.getenv("BUCKET_NAME")


def create_presigned_post(bucket_name, object_name,
                          fields=None, conditions=None, expiration=3600):
    """Generate a presigned URL S3 POST request to upload a file

    :param bucket_name: string
    :param object_name: string
    :param fields: Dictionary of prefilled form fields
    :param conditions: List of conditions to include in the policy
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Dictionary with the following keys:
        url: URL to post to
        fields: Dictionary of form fields and values to submit with the POST
    :return: None if error.
    """

    # Generate a presigned S3 POST URL
    s3_client = boto3.client('s3')
    try:
        response = s3_client.generate_presigned_post(bucket_name,
                                                     object_name,
                                                     Fields=fields,
                                                     Conditions=conditions,
                                                     ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL and required fields
    return response


def lambda_handler(event, context):
    # Create a lambda handler function that will be called by the API Gateway and return a presigned URL to put an object in the S3 bucket.
    # The object name will be passed in the pathParameters of the event parameter.
    s3_client = boto3.client('s3', region_name=REGION, config=boto3.session.Config(signature_version='s3v4', ))
    object_name = event['pathParameters']['object_name']
    try:
        response = s3_client.generate_presigned_url('put_object',
                                                    Params={'Bucket': BUCKET_NAME,
                                                            'Key': object_name})
    except Exception as e:
        print(e)
        logging.error(e)
        return "Error"
    # The response contains the presigned URL
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }