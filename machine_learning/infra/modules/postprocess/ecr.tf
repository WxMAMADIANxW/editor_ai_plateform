################ Elastic Container Registry ################

locals {
  ecr_image_tag = "latest"
  account_id    = data.aws_caller_identity.current.account_id
}

data aws_caller_identity current {}

data aws_ecr_authorization_token token {}

resource aws_ecr_repository postprocess_repo {
  name         = local.postprocess_ecr_repository_name
  force_delete = true
}

resource null_resource postprocess_ecr_image {
  depends_on = [aws_ecr_repository.postprocess_repo]
  triggers   = {
    python_file = md5(file("../post-processing/main.py"))
    docker_file = md5(file("../post-processing/Dockerfile"))
  }
  provisioner "local-exec" {
    command = <<EOF
           docker logout ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com
           docker login --username ${data.aws_ecr_authorization_token.token.user_name} --password ${data.aws_ecr_authorization_token.token.password} ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
           cd ../post-processing
           docker buildx build --platform linux/amd64 --provenance=false -t ${aws_ecr_repository.postprocess_repo.repository_url}:${local.ecr_image_tag} . --push
       EOF
  }
}

data aws_ecr_image postprocess_lambda_image {
  depends_on = [
    null_resource.postprocess_ecr_image
  ]
  repository_name = local.postprocess_ecr_repository_name
  image_tag       = local.ecr_image_tag
}