# TODO: Get messages from AWS SQS queue
import boto3
import json
import os
import time
import logging

from redis import Redis
# TODO: Voir si on en a besoin
#  from rediscluster import RedisCluster

# SQS Environment Variables
# SQS_ENDPOINT = os.environ.get('SQS_ENDPOINT')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')
SQS_QUEUE_NAME = os.environ.get('SQS_QUEUE_NAME')

# Redis Environment Variables
# REDIS_HOST = os.environ.get('REDIS_HOST')
# REDIS_PORT = os.environ.get('REDIS_PORT', 6379)
# REDIS_USERNAME = os.environ.get('REDIS_USERNAME')
# REDIS_PASSWORD = os.environ.get('REDIS_PASSWORD')

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Get the service resource
sqs = boto3.resource('sqs', region_name=AWS_REGION)#, endpoint_url=SQS_ENDPOINT)

# Get the queue
queue = sqs.get_queue_by_name(QueueName=SQS_QUEUE_NAME)
print(f'Queue URL: {queue.url}')

# Process messages by printing out body and optional author name
while True:
    try:
        messages = queue.receive_messages(MessageAttributeNames=['All'], MaxNumberOfMessages=1, WaitTimeSeconds=5)
        for message in messages:
            # Print out the body and author (if set)
            print('Hello, {0}!'.format(message.body))
            # Let the queue know that the message is processed
            message.delete()
            # TODO #1: Run inference
            # TODO #2: Push data to AWS ElastiCache (Redis) instance
            # redis = Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True, ssl=True, username=REDIS_USERNAME,
            #               password=REDIS_PASSWORD)
            # if redis.ping():
            #     print('Connected to Redis')
            # else:
            #     print('Could not connect to Redis')
            # TODO #3: Push data to AWS ElastiCache (Redis) cluster
            # redis.set('foo', 'bar')
            # redis = RedisCluster(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True, ssl=True, username=REDIS_USERNAME,
            #                      password=REDIS_PASSWORD)
    except Exception as e:
        logger.error(e)
        continue



