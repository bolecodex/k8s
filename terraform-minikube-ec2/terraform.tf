terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.28.0"
    }
  }
}

provider "aws" {
  region = var.region
}
