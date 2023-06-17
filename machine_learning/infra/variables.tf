locals {
  bucket_name                     = "${var.app_name}-bucket"
  lambda_role_name                = "${var.app_name}_lambda_iam_role"
  lambda_iam_policy_name_pipeline = "${var.app_name}_lambda_iam_policy"

  preprocess_ecr_repository_name  = "${var.app_name}_preprocess_ecr_repository"
  inference_ecr_repository_name   = "${var.app_name}_inference_ecr_repository"
  postprocess_ecr_repository_name = "${var.app_name}_postprocess_ecr_repository"

  inference_ecs_cluster_name    = "${var.app_name}_inference_ecs_cluster"
}

variable "region" {
  default = ""
}

variable "profile_name" {
  default = ""
}

variable "function_name_pipeline" {
  default = ""
}

variable "s3_bucket_id" {
  default = ""
}

variable "policy_s3" {
  default = ""
}

variable "app_name" {
  default = ""
}

variable "public_subnets" {
  default = ""
}

variable "private_subnets" {
  default = ""
}

variable "availability_zones" {
  default = ""
}