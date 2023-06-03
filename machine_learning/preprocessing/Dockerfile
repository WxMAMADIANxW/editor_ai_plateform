FROM public.ecr.aws/lambda/python:3.8.2023.05.29.18
WORKDIR ${LAMBDA_TASK_ROOT}

RUN yum update -y && yum install mesa-libGL -y

COPY main.py main.py
COPY config.py config.py
COPY split.py split.py

RUN pip3 install --upgrade pip

CMD ["main.lambda_handler"]