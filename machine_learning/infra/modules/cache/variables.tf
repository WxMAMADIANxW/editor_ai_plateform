locals {
  elasticache_subnet_group_name = "${var.app_name}-elasticache-subnet-group"
  elasticache_cluster_name      = "${var.app_name}-elasticache-cluster"
}

variable "app_name" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_ids" {
    type    = list(string)
    default = []
}

#variable "key_name" {
#  type    = string
#  default = ""
#}