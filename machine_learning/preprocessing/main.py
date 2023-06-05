import os
import urllib
from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip
import boto3
import logging

# Configure the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

CLIP_DURATION = 150


def lambda_handler(event, context):
    # Retrieve input parameters from the event
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )

    # Set up the S3 client
    s3 = boto3.client('s3')

    # Get the file name without extension
    file_name = os.path.splitext(os.path.basename(key))[0]

    # Download the input video file from S3
    input_file = f'/tmp/{key}'
    s3.download_file(bucket, key, input_file)

    # Calculate the total duration of the video
    from moviepy.editor import VideoFileClip
    video = VideoFileClip(input_file)
    video_duration = video.duration

    # Split the video into clips
    start_time = 0
    clip_number = 1

    while start_time < video_duration:
        end_time = min(start_time + CLIP_DURATION, video_duration)

        clip_output_file = f'{file_name}_{start_time}_{end_time}.mp4'
        clip_output_key = os.path.join("output", file_name, clip_output_file)
        clip_output_path = f'/tmp/{clip_output_file}'

        ffmpeg_extract_subclip(input_file, start_time, end_time, targetname=clip_output_path)

        # Upload the clip to the output S3 bucket
        s3.upload_file(clip_output_path, bucket, clip_output_key)
        logger.info(f'Successfully split and uploaded clip {clip_number}')

        start_time += CLIP_DURATION
        clip_number += 1

    logger.info('Video splitting complete!')
