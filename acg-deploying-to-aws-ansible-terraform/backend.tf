terraform {
  required_version = ">= 1.2.5"
  cloud {
    organization = "rlucernas"

    workspaces {
      name = "acg-deploying-to-aws-ansible-terraform"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.24.0"
    }
  }
}