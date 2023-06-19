# TODO: Get messages from AWS SQS queue
import boto3
import json
import os
import time
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

from redis import Redis
# TODO: Voir si on en a besoin
#  from rediscluster import RedisCluster

print('Starting...')
logger.info('Starting...')

# SQS Environment Variables
# SQS_ENDPOINT = os.environ.get('SQS_ENDPOINT')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')
SQS_QUEUE_NAME = os.environ.get('SQS_QUEUE_NAME')

# Redis Environment Variables
REDIS_HOST = os.environ.get('REDIS_HOST')
REDIS_PORT = os.environ.get('REDIS_PORT', 6379)
REDIS_USERNAME = os.environ.get('REDIS_USERNAME')
REDIS_PASSWORD = os.environ.get('REDIS_PASSWORD')

# Get the service resource
sqs = boto3.resource('sqs', region_name=AWS_REGION)

# Get the queue
queue = sqs.get_queue_by_name(QueueName=SQS_QUEUE_NAME)
print(f'Queue URL: {queue.url}')
logger.info(f'Queue URL: {queue.url}')

# Process messages by printing out body and optional author name
timeout = time.time() + 60*3

while True:
    if time.time() > timeout:
        break
    try:
        messages = queue.receive_messages(MessageAttributeNames=['All'], MaxNumberOfMessages=1, WaitTimeSeconds=5)
        for message in messages:
            # Print out the body and author (if set)
            print('Hello, {0}!'.format(message.body))
            logger.info('Hello, {0}!'.format(message.body))
            # Let the queue know that the message is processed
            message.delete()

            # TODO #1: Download videos from S3 bucket to local storage
            # TODO #2: Run inference
            # TODO #3: Push data to AWS ElastiCache (Redis) instance
            redis = Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True, ssl=True, username=REDIS_USERNAME,
                          password=REDIS_PASSWORD) # ERROR during connection: Error 110 connecting to editor-ai-platform-elasticache-cluster.tprabp.0001.use1.cache.amazonaws.com:6379. Connection timed out.
            # TODO: Test avec RedisCluster bg
            if redis.ping():
                print('Connected to Redis')
                logger.info('Connected to Redis')
            else:
                print('Could not connect to Redis')
                logger.info('Could not connect to Redis')
            # TODO #4: Push data to AWS ElastiCache (Redis) cluster
            redis.set('foo', 'bar')
            print("foo: ", redis.get('foo'))
            logger.info(f"foo: {redis.get('foo')}")
            # redis = RedisCluster(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True, ssl=True, username=REDIS_USERNAME,
            #                      password=REDIS_PASSWORD)
    except Exception as e:
        logger.error(e)
        print(e)
        continue

print('Done getting messages from SQS queue')
logger.info('Done getting messages from SQS queue')