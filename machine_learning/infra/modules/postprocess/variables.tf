locals {
  final_bucket_name               = "${var.app_name}-final-bucket"
  lambda_role_name                = "${var.app_name}_postprocess_lambda_iam_role"
  lambda_iam_policy_name_pipeline = "${var.app_name}_postprocess_lambda_iam_policy"
  postprocess_ecr_repository_name = "${var.app_name}-postprocess-ecr-repository"
  function_name_pipeline          = "${var.app_name}-postprocess"
}

variable "app_name" {
  default = ""
}

variable "region" {
  default = ""
}

variable "s3_bucket_id" {
  default = ""
}

variable "policy_s3" {
  default = ""
}

variable "redis_host" {
  default = ""
}

variable "redis_username" {
  default = ""
}

variable "redis_port" {
  default = ""
}

variable "redis_password" {
  default = ""
}

variable "input_bucket_name" {
  default = ""
}

variable "subnet_ids" {
  default = ""
}

variable "security_group_id" {
  default = ""
}