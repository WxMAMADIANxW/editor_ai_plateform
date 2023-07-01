import os
import urllib
from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip
import redis
from rediscluster import RedisCluster
import boto3
import logging

# Configure the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
REDIS_HOST = os.environ["REDIS_HOST"]
REDIS_PORT = os.getenv("REDIS_PORT", 6379)
REDIS_USERNAME = os.environ["REDIS_USERNAME"]
REDIS_PASSWORD = os.environ["REDIS_PASSWORD"]
OUTPUT_BUCKET = os.environ["OUTPUT_BUCKET"]


def lambda_handler(event, context):
    # Connect to MemoryDB with the Redis client
    try:
        redis_cluster = RedisCluster(host=REDIS_HOST, port=REDIS_PORT, username=REDIS_USERNAME, password=REDIS_PASSWORD,
                                     decode_responses=True, skip_full_coverage_check=True, ssl=True)
        assert redis_cluster.ping() is True, "Unable to connect to MemoryDB"
    except Exception as e:
        print(e)
        raise e

    # Get all the keys from the Redis cluster
    keys = redis_cluster.keys()

    # Check if they have a TTL inferior to 3000 seconds
    for key in keys:
        ttl = redis_cluster.ttl(key)
        print(f"TTL for the key {key} is {ttl} seconds")
        if ttl < 3600:
            # Retrieve the project ID from the key
            project_id, video_name, query = key.split(":")
            print(f"Project ID: {project_id}")
            os.makedirs(f"/tmp/{project_id}", exist_ok=True)

            # Bind the project ID and the video name to get the object key
            object_key = f"{project_id}/{video_name}"

            # Set up the S3 client
            s3 = boto3.client('s3', region_name=AWS_REGION)

            # Download the input video file from S3
            input_file = f'/tmp/{object_key}'
            s3.download_file(OUTPUT_BUCKET, object_key, input_file)
            print(f"Downloaded {object_key} from S3")

            print(f"Redis key: {key} / values: {redis_cluster.get(key)}")
        print("Finished processing all the keys")
    print("Done!")