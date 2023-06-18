resource "aws_ecs_cluster" "inference_ecs_cluster" {
  name = "${var.app_name}-cluster"
  tags = {
    Name = "${var.app_name}-ecs"
  }
}

resource "aws_ecs_task_definition" "inference_task_definition" {
  family                   = "${var.app_name}-cluster"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = templatefile("./modules/inference/task_definition.json.tpl", {
    REPOSITORY_URL   = aws_ecrpublic_repository.inference_repo.repository_uri,
    CLOUDWATCH_GROUP = aws_cloudwatch_log_group.log-group.id, REGION = var.region
  })

  network_mode     = "awsvpc"
  cpu              = 1024
  memory           = 4096

  tags = {
    Name = "${var.app_name}-ecs-td"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.inference_task_definition.family
}

resource "aws_ecs_service" "inference_worker" {
  name                 = "${var.app_name}-cluster"
  cluster              = aws_ecs_cluster.inference_ecs_cluster.id
  task_definition      = "${aws_ecs_task_definition.inference_task_definition.family}:${max(aws_ecs_task_definition.inference_task_definition.revision, data.aws_ecs_task_definition.main.revision)}"
  desired_count        = 1
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
    security_groups  = [
      aws_security_group.service_security_group.id, aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-container"
    container_port   = 8080
  }

  platform_version = "1.3.0"
  depends_on = [aws_lb_listener.listener]
}