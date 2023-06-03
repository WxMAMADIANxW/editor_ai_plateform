import os
import urllib
from typing import Tuple, List
import logging
import boto3
import split
import config as conf

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.INFO)

s3 = boto3.client("s3")


def lambda_handler(event, context) -> None:  # pylint: disable=unused-argument
    """
    Lambda function that is triggered by S3 events.
    :param event:
    :param context:
    :return:
    """
    LOGGER.info("started preprocessing")
    preprocess(event)
    # process(user_id)
    LOGGER.info("finished processing")


def parse_event(event) -> Tuple[str, str]:#, str]:
    """
    Parse the event.
    :param event:
    :return:
    """
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )
    # user_id = key.split("_")[-1].split(".")[0]
    return bucket, key#, user_id


def preprocess(event):
    """
    Preprocess the video.
    :param event:
    :return:
    """
    (bucket, key) = parse_event(event)
    LOGGER.info(f"found new video from {bucket}/{key}")
    tmp_file = conf.get_temp_file(key)
    LOGGER.info(f"tmp_file: {tmp_file}")
    os.makedirs("./tmp/raw", exist_ok=True)
    os.makedirs("./tmp/splitted", exist_ok=True)
    s3.download_file(bucket, key, tmp_file)
    LOGGER.info(f"video successfully downloaded: {tmp_file}")
    LOGGER.info(f"listdir tmp 1: {os.path.listdir('./tmp/raw/')}")
    split.split_by_seconds(filename=tmp_file,
                           split_length=conf.SPLIT_LENGTH,
                           output_dir=conf.OUTPUT_DIR)
    LOGGER.info(f"listdir tmp 2: {os.path.listdir('./tmp/splitted/')}")
    output_files = conf.OUTPUT_DIR + key
    s3.upload_file(output_files, bucket)
    LOGGER.info(f"upload done")

