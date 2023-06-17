[
  {
    "essential": true,
    "networkMode": "awsvpc",
    "name": "editor-ai-platform-container",
    "image": "${REPOSITORY_URL}:latest",
    "cpu": 1024,
    "memory": 2048,
    "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
    "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${CLOUDWATCH_GROUP}",
            "awslogs-region": "${REGION}",
            "awslogs-stream-prefix": "editor-ai-platform-logs"
          }
        }
  }
]