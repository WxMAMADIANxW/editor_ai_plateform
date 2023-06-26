import boto3
import json
import os
import time
import logging
import redis
from rediscluster import RedisCluster

print('Starting...')

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

logger.info('Starting...')

# SQS Environment Variables
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')
# print(f'AWS region: {AWS_REGION}')
SQS_QUEUE_NAME = os.environ.get('SQS_QUEUE_NAME')
# print(f'SQS queue name: {SQS_QUEUE_NAME}')

# Redis Environment Variables
REDIS_HOST = os.environ.get('REDIS_HOST')
# print(f'Redis host: {REDIS_HOST}')
REDIS_PORT = os.environ.get('REDIS_PORT', 6379)
# print(f'Redis port: {REDIS_PORT}')
REDIS_USERNAME = os.environ.get('REDIS_USERNAME', "")
# print(f'Redis username: {REDIS_USERNAME}')
REDIS_PASSWORD = os.environ.get('REDIS_PASSWORD', "")
# print(f'Redis password: {REDIS_PASSWORD}')

# Get the service resource
sqs = boto3.resource('sqs', region_name=AWS_REGION)

# Get the queue
queue = sqs.get_queue_by_name(QueueName=SQS_QUEUE_NAME)

# Process messages by printing out body and optional author name
timeout = time.time() + 60 * 3

while True:
    if time.time() > timeout:
        break
    try:
        messages = queue.receive_messages(MessageAttributeNames=['All'], MaxNumberOfMessages=1, WaitTimeSeconds=5)
        counter = 0
        for message in messages:
            print('Consuming a message...')
            logger.info('Consuming a message...')
            # print("--------------------")
            # logger.info("--------------------")
            payload = json.loads(message.body)
            message.delete()

            if payload.get('Event', None) is not None:
                print('Test event message received')
                logger.info('Test event message received')
                continue

            print(f'Payload: {payload}')
            logger.info(f'Payload: {payload}')
            bucket_name = payload.get('Records')[0].get('s3').get('bucket').get('name')
            print(f'Bucket name: {bucket_name}')
            logger.info(f'Bucket name: {bucket_name}')
            object_key = payload.get('Records')[0].get('s3').get('object').get('key')
            print(f'Object key: {object_key}')
            logger.info(f'Object key: {object_key}')

            # TODO #1: Download videos from S3 bucket to local storage
            s3_client = boto3.client('s3', region_name=AWS_REGION)
            file_name = object_key.split('/')[-1]

            try:
                s3_client.download_file(bucket_name, object_key, file_name)
            except Exception as e:
                print("Error during download")
                logger.error("Error during download")
                print(e)
                logger.error(e)

            print(f'Downloaded {object_key} from {bucket_name} to {file_name}')
            logger.info(f'Downloaded {object_key} from {bucket_name} to {file_name}')
            # print(f"Local files: {os.listdir()}")
            # logger.info(f'Local files: {os.listdir()}')

            # TODO #2: Run inference

            # TODO #5: Delete videos from S3 bucket and local storage
            try:
                os.remove(file_name)
            except Exception as e:
                print("Error during local deletion")
                logger.error("Error during local deletion")
                print(e)
                logger.error(e)

            try:
                s3_client.delete_object(Bucket=bucket_name, Key=object_key)
            except Exception as e:
                print("Error during S3 deletion")
                logger.error("Error during S3 deletion")
                print(e)
                logger.error(e)
            print(f'Deleted {object_key} from {bucket_name} and {file_name}')
            logger.info(f'Deleted {object_key} from {bucket_name} and {file_name}')

            # TODO #3: Push data to AWS ElastiCache (Redis) instance
            # logger.info("REDIS_HOST: " + REDIS_HOST)
            # print("REDIS_HOST: ", REDIS_HOST)
            # logger.info("REDIS_PORT: " + REDIS_PORT)
            # print("REDIS_PORT: ", REDIS_PORT)
            # logger.info("REDIS_USERNAME: " + REDIS_USERNAME)
            # print("REDIS_USERNAME: ", REDIS_USERNAME)
            # logger.info("REDIS_PASSWORD: " + REDIS_PASSWORD)
            # print("REDIS_PASSWORD: ", REDIS_PASSWORD)

            redis_cluster = RedisCluster(host=REDIS_HOST, port=REDIS_PORT, username=REDIS_USERNAME,
                                         password=REDIS_PASSWORD, decode_responses=True, skip_full_coverage_check=True,
                                         ssl=True)
            # TODO: Test avec RedisCluster bg
            if redis_cluster.ping():
                print('Connected to Redis')
                logger.info('Connected to Redis')
            else:
                print('Could not connect to Redis')
                logger.info('Could not connect to Redis')

            # TODO #4: Push data to AWS ElastiCache (Redis) cluster
            # Push list of elements in the key 'foo'
            key = f'project_id:{counter}'
            redis_cluster.delete(key)

            d = {"query": "test", "result": "test"}
            for k, v in d.items():
                redis_cluster.hset(key, k, v)
            # redis_cluster.hset('foo', mapping={"query": "test", "result": "test"})
            print("Pushed data to Redis")
            logger.info("Pushed data to Redis")
            # Get the list of elements in the key 'foo'

            values_from_my_key = redis_cluster.hgetall(key)
            for k, v in values_from_my_key.items():
                print(k, v)
                logger.info(k, v)

            redis_cluster.delete(key)  # TODO: Temporary delete for testing purposes
            counter += 1
            print("Message consumed")
            logger.info("Message consumed")

    except Exception as e:
        logger.error(f"Error in message consuming: {e}")
        print(f"Error in message consuming: {e}")
        continue

print('Done getting messages from SQS queue')
logger.info('Done getting messages from SQS queue')
