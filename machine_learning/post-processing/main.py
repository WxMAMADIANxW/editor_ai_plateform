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

"""
TODO: Key values available in the Redis cluster:
{'1djnskd:0dsjnd_lol_20230626_150_214.23.mp4:pit':
    {'pred_moments': 
        [[38.8132, 47.8754, 0.7675], [55.0561, 61.8768, 0.6529], [44.6212, 52.3721, 0.5473], [4.9406, 12.5682, 0.4052], [37.8556, 46.3884, 0.3635], [44.8069, 53.7975, 0.3304], [56.3658, 63.2791, 0.2747], [13.5623, 22.6456, 0.2582], [6.7044, 15.1909, 0.2143], [47.4132, 54.7271, 0.1684]],
     'pred_saliency_scores': 
        [-0.4407, -0.3005, -0.366, -0.584, -0.2285, -0.6226, -0.939, -0.4734, -0.5752, -0.5332, -0.4824, -0.3579, -0.4939, -0.2302, -0.1541, -0.3232, -0.54, -0.248, -0.2878, -0.4907, -0.0771, -0.4675, -0.2445, -0.4651, -0.4495, -0.4119, -0.3633, -0.1539, -0.079, -0.5957, -0.4382, -0.2981]
    },
    '1djnskd:0dsjnd_lol_20230626_150_214.23.mp4:teamfight': 
        {'pred_moments': 
            [[51.3198, 59.8288, 0.7767], [18.3335, 28.4263, 0.465], [35.7231, 45.5293, 0.4191], [51.9574, 59.6382, 0.3542], [4.7571, 13.5769, 0.3368], [49.8027, 58.2242, 0.2541], [47.1072, 54.4616, 0.1803], [5.8072, 14.6422, 0.1626], [45.5281, 55.0522, 0.0522], [47.2813, 56.5966, 0.0291]],
         'pred_saliency_scores': 
            [-0.7046, -0.3511, -0.6099, -0.6938, -0.3884, -0.4404, -0.1648, -0.3684, -0.3594, -0.7686, -0.666, -0.3018, -0.5581, -0.4275, -0.4666, -0.708, -0.3306, -0.7373, -0.6504, -0.4495, -0.4111, -0.2131, -0.4653, -0.6265, -0.3489, -0.3208, -0.4136, -0.5073, -0.4656, -0.2717, -0.6118, -0.4685]
        },
    '1djnskd:0dsjnd_lol_20230626_150_214.23.mp4:duel':
        {'pred_moments': 
            [[30.8186, 34.7294, 0.7885], [52.3994, 55.7899, 0.7634], [11.9555, 16.42, 0.5767], [56.1749, 59.8301, 0.5019], [19.6897, 22.86, 0.4902], [49.1761, 53.121, 0.4677], [34.1902, 37.4807, 0.4464], [38.9747, 42.0116, 0.4102], [50.4928, 54.3186, 0.3463], [38.0634, 41.8729, 0.3277]],
         'pred_saliency_scores': 
            [-0.3157, -0.5923, -0.4526, -0.3962, -0.2576, -0.2935, -0.5771, -0.2698, -0.3184, -0.5068, -0.1891, -0.3762, -0.2603, -0.281, -0.5767, -0.3196, 0.1427, -0.3789, -0.3196, -0.4185, -0.3125, -0.4839, -0.6963, -0.1661, -0.0292, 0.0201, -0.7236, -0.2886, -0.3687, -0.262, -0.4797, -0.1826]
        }
}
"""


def lambda_handler(event, context):
    # Connect to MemoryDB with the Redis client
    redis_cluster = RedisCluster(host=REDIS_HOST, port=REDIS_PORT, username=REDIS_USERNAME, password=REDIS_PASSWORD,
                                 decode_responses=True, skip_full_coverage_check=True, ssl=True)

    # Get all the keys from the Redis cluster
    keys = redis_cluster.keys()

    # Check if they have a TTL inferior to 3000 seconds
    for key in keys:
        ttl = redis_cluster.ttl(key)
        if ttl < 3000:
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

            #
