FROM public.ecr.aws/lambda/python:3.8
WORKDIR ${LAMBDA_TASK_ROOT}

RUN yum update -y

COPY main.py main.py

RUN pip3 install --upgrade pip && \
    pip3 install moviepy

CMD ["main.lambda_handler"]