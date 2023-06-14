resource "aws_ecs_cluster" "inference_ecs_cluster" {
  name = "${var.app_name}-cluster"
  tags = {
    Name = "${var.app_name}-ecs"
  }
}

data "template_file" "task_definition_template" {
  template = file("./modules/inference/task_definition.json.tpl")

  vars = {
    REPOSITORY_URL = aws_ecr_repository.inference_repo.repository_url
  }
}

resource "aws_ecs_task_definition" "inference_task_definition" {
  family                = "${var.app_name}-cluster"
  container_definitions = data.template_file.task_definition_template.rendered

  tags = {
    Name = "${var.app_name}-ecs-td"
  }
}

resource "aws_ecs_service" "inference_worker" {
  name            = "${var.app_name}-cluster"
  cluster         = aws_ecs_cluster.inference_ecs_cluster.id
  task_definition = aws_ecs_task_definition.inference_task_definition.arn
  desired_count   = 2
}