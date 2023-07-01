FROM public.ecr.aws/lambda/python:3.8
WORKDIR ${LAMBDA_TASK_ROOT}

RUN yum update -y

COPY requirements.txt requirements.txt
RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt

COPY main.py main.py

CMD ["main.lambda_handler"]