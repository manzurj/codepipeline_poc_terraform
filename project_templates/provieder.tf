# AWS provider version definition
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "tfbootstrap-6082022"
    key            = "global/terraform.tfstate"
    dynamodb_table = "tfbootstrap-6082022"
    region         = "us-east-1"
    profile        = "default"
    encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = local.deploy_role
    session_name = "codebuild_deploy"
  }

  default_tags {
    tags = var.project-tags
  }
}