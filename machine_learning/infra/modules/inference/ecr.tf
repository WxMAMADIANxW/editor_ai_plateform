################ Elastic Container Registry ################

locals {
  ecr_image_tag = "latest"
  account_id    = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}

resource "aws_ecrpublic_repository" "inference_repo" {
  repository_name = local.inference_ecr_repository_name
}

resource "null_resource" "inference_ecr_image" {
  depends_on = [aws_ecrpublic_repository.inference_repo]
  triggers   = {
    python_file = md5(file("../inference/main.py"))
    docker_file = md5(file("../inference/Dockerfile"))
  }
  provisioner "local-exec" {
    command = <<EOF
           docker logout public.ecr.aws
           aws ecr-public get-login-password --region ${var.region} | docker login --username ${data.aws_ecr_authorization_token.token.user_name} --password-stdin public.ecr.aws/${local.account_id}
           cd ../inference
           docker buildx build \
              --build-arg SQS_QUEUE_NAME=${var.sqs_queue_name} \
              --build-arg REDIS_HOST=${var.redis_host} \
              --build-arg REDIS_USERNAME=${var.redis_username} \
              --build-arg REDIS_PASSWORD=${var.redis_password} \
              --platform linux/amd64 \
              --provenance=false \
              -t ${aws_ecrpublic_repository.inference_repo.repository_uri}:${local.ecr_image_tag} . --push
       EOF
  }
}