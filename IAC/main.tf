terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  shared_config_files      = ["%UserProfile%/.aws/conf"]
  shared_credentials_files = ["%UserProfile%/.aws/creds"]
  #  access_key = var.aws_access_key
  #  secret_key = var.aws_secret_key
  #  region     = var.aws_region
  default_tags {
    ags = {
      "Owner"   = "Aleksandr_Shcherbakov1@epam.com"
      "Project" = "DevOps Diploma"
    }
  }
}