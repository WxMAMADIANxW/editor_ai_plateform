FROM python:3.8-slim-buster

COPY requirements.txt requirements.txt

RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY main.py main.py

ENV SQS_QUEUE_NAME="s3-event-queue"
ENV AWS_REGION="us-east-1"

CMD ["python3", "main.py"]