locals {
  inference_ecr_repository_name = "${var.app_name}_inference_ecr_repository"
  cloudwatch_group = "${var.app_name}_cloudwatch_group"
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

variable "public_subnets" {
  default = ""
}

variable "private_subnets" {
  default = ""
}

variable "availability_zones" {
  default = ""
}