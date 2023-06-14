locals {
  inference_ecr_repository_name = "${var.app_name}_inference_ecr_repository"
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
#  default     = ""
}

variable "app_name" {
  description = "The name of the application"
  type        = string
#  default     = ""
}