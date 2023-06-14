locals {
  raw_bucket_name                 = "${var.app_name}-raw-bucket"
  splitted_bucket_name            = "${var.app_name}-splitted-bucket"
  lambda_role_name                = "${var.app_name}_lambda_iam_role"
  lambda_iam_policy_name_pipeline = "${var.app_name}_lambda_iam_policy"
  preprocess_ecr_repository_name  = "${var.app_name}-preprocess-ecr-repository"
  function_name_pipeline          = "${var.app_name}-preprocess"
}

variable "app_name" {
  default = ""
}

variable "region" {
  default = ""
}

#variable "preprocess_ecr_repository_name" {
#  default = ""
#}
#
#variable "function_name_pipeline" {
#  default = ""
#}

#variable "lambda_role_name" {
#  default = ""
#}

variable "s3_bucket_id" {
  default = ""
}

#variable "lambda_iam_policy_name_pipeline" {
#  default = ""
#}

variable "policy_s3" {
  default = ""
}