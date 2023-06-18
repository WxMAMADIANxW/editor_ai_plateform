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
  triggers = {
        python_file = md5(file("../inference/main.py"))
    docker_file = md5(file("../inference/Dockerfile"))
  }
  provisioner "local-exec" {
    # aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/your-aws-account-id
    # docker logout ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com
    # docker login --username ${data.aws_ecr_authorization_token.token.user_name} --password ${data.aws_ecr_authorization_token.token.password} ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
    command = <<EOF
           aws ecr-public get-login-password --region ${var.region} | docker login --username ${data.aws_ecr_authorization_token.token.user_name} --password-stdin public.ecr.aws/${local.account_id}
           cd ../inference
           docker buildx build --platform linux/amd64 --provenance=false -t ${aws_ecrpublic_repository.inference_repo.repository_uri}:${local.ecr_image_tag} . --push
       EOF
  }
}

#data aws_ecr_image ec2_image {
#  depends_on = [
#    null_resource.inference_ecr_image
#  ]
#  repository_name = local.inference_ecr_repository_name
#  image_tag       = local.ecr_image_tag
#}