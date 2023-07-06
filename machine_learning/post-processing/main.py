import json
import os
import urllib
from collections import defaultdict

from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip
import redis
from rediscluster import RedisCluster
import boto3
import logging

# Configure the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

AWS_REGION = os.getenv("REGION", "us-east-1")
REDIS_HOST = os.environ["REDIS_HOST"]
REDIS_PORT = os.getenv("REDIS_PORT", 6379)
REDIS_USERNAME = os.environ["REDIS_USERNAME"]
REDIS_PASSWORD = os.environ["REDIS_PASSWORD"]
OUTPUT_BUCKET = os.environ["OUTPUT_BUCKET"]
INPUT_BUCKET = os.environ["INPUT_BUCKET"]


def filter_by_project_id(redis_keys) -> dict:
    same_project_id = {}
    for key in redis_keys:
        project_id = key.split(':')[0]
        if project_id in same_project_id:
            same_project_id[project_id].append(key)
        else:
            same_project_id[project_id] = [key]
    return same_project_id


def filter_by_video_id(project_ids_dict) -> dict:
    same_video_id = {}
    for project_id, keys in project_ids_dict.items():
        for key in keys:
            video_id = key.split(':')[1]
            if video_id in same_video_id:
                same_video_id[video_id].append(key)
            else:
                same_video_id[video_id] = [key]
    return same_video_id


def get_segments_with_best_accuracy(redis_data, video_ids_dict) -> dict:
    segments_with_best_accuracy = defaultdict(list)
    for video_id, keys in video_ids_dict.items():
        for key in keys:
            key_value = json.loads(redis_data.get(key).replace("'", "\""))
            segments_with_accuracy = key_value['pred_moments']
            for segment in segments_with_accuracy:
                accuracy = segment[2]
                if accuracy > 0.7:
                    segments_with_best_accuracy[key].append(segment)
    return segments_with_best_accuracy


def fix_segments_overlap(segments_with_best_accuracies) -> dict:
    fixed_segments = {}
    for key, segments in segments_with_best_accuracies.items():
        fixed_segments[key] = []
        for segment in segments:
            segment = segment[:-1]
            if not fixed_segments[key]:
                fixed_segments[key].append(segment)
            else:
                last_segment = fixed_segments[key][-1]
                if last_segment[1] < segment[0]:
                    fixed_segments[key].append(segment)
                elif last_segment[1] < segment[1]:
                    last_segment[1] = segment[1]
    return fixed_segments


def aggregate_segments(fixed_segments) -> dict:
    from moviepy.editor import VideoFileClip
    for key, segments in fixed_segments.items():
        input_video_file = "/".join(key.split(':')[:-1])
        print("Input video file:", input_video_file)
        query = key.split(':')[-1]
        local_video_file = f"/tmp/{input_video_file}"
        print("Local video file:", local_video_file)
        clip1 = VideoFileClip(local_video_file)
        # clips = []
        counter = 0
        for segment in segments:
            counter += 1
            start = segment[0]
            end = segment[1]
            clip = clip1.subclip(start, end)
            output_video_file = f"/tmp/{''.join(input_video_file.split('.')[:-1])}_{query}_{counter}.mp4"
            print(output_video_file)
            clip.write_videofile(output_video_file, temp_audiofile="/tmp/temp-audio.m4a", remove_temp=True, codec="libx264", audio_codec="aac")
            print("Wrote video file to:", output_video_file)
        os.remove(f"{local_video_file}")  # TODO: Remove file locally after processing it and maybe upload it to S3 juste after the write_videofile
        #     clips.append(clip)
        # final_clip = concatenate_videoclips(clips)
        # final_clip.write_videofile(f"/tmp/{input_video_file}.mp4")


def upload_to_final_s3_bucket(project_ids) -> None:
    s3_client = boto3.client('s3')
    for project_id in project_ids:
        for file in os.listdir(f"/tmp/{project_id}"):
            file_path = os.path.join(f"/tmp/{project_id}", file)
            output_file_path = os.path.join(f"{project_id}", file)
            print(f"File in /tmp/{project_id}: {file_path}")
            if file.endswith(".mp4"):
                s3_client.upload_file(file_path, OUTPUT_BUCKET, output_file_path)
                print(f"Uploaded {file} to {OUTPUT_BUCKET}")


# def download_video_from_s3(redis_data) -> None:
    # s3_client = boto3.client('s3')
    # for key, segments in redis_data.items():
    #     input_video_file = "/".join(key.split(':')[:-1])
    #     local_video_file = f"/tmp/{input_video_file}"
    #     print(local_video_file)
        # os.makedirs(local_video_file, exist_ok=True)
        # s3_client.download_file(INPUT_BUCKET, input_video_file, local_video_file)


def lambda_handler(event, context):
    # Connect to MemoryDB with the Redis client
    print("Connecting to MemoryDB with the Redis client")
    print(f"Host: {REDIS_HOST}")
    print(f"Port: {REDIS_PORT}")
    print(f"Username: {REDIS_USERNAME}")
    print(f"Password: {REDIS_PASSWORD}")
    try:
        redis_cluster = RedisCluster(host=REDIS_HOST, port=REDIS_PORT, username=REDIS_USERNAME, password=REDIS_PASSWORD,
                                     decode_responses=True, skip_full_coverage_check=True, ssl=True)
        if redis_cluster.ping():
            print("Connected to Redis cluster")
        else:
            print("Could not connect to Redis cluster")
    except Exception as e:
        print(e)
        raise e

    # Get all the keys from the Redis cluster
    keys = redis_cluster.keys()
    print(f"Checking keys in Redis: {keys}")

    available_keys = []
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
            s3_client = boto3.client('s3', region_name=AWS_REGION)

            print(f"Downloading {object_key} from the S3 Bucket: {INPUT_BUCKET} to /tmp/{object_key}")
            # Download the input video file from S3
            input_file = f'/tmp/{object_key}'
            s3_client.download_file(INPUT_BUCKET, object_key, input_file)
            print(f"Downloaded {object_key} from S3")

            available_keys.append(key)
            # print(f"Redis key: {key} / values: {redis_cluster.get(key)}")
        print("Finished processing all the keys")

    print("Starting to process the videos")
    project_ids_dict = filter_by_project_id(available_keys)
    # print("Project_ids_dict:", project_ids_dict)
    video_ids_dict = filter_by_video_id(project_ids_dict)
    # print("Video_ids_dict:", video_ids_dict)
    segments_with_best_accuracies = get_segments_with_best_accuracy(redis_cluster, video_ids_dict)
    # print("Segments_with_best_accuracies:", segments_with_best_accuracies)
    fixed_segments = fix_segments_overlap(segments_with_best_accuracies)
    # print("Fixed_segments:", fixed_segments)
    aggregate_segments(fixed_segments)
    print("Done aggregating segments")
    upload_to_final_s3_bucket(project_ids_dict.keys())
    print("Deleting all the keys used for processing")
    for key in available_keys:
        redis_cluster.delete(key)

    print("Done!")

