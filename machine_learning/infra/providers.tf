terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
    null = {
      source  = "hashicorp/null"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile_name
}