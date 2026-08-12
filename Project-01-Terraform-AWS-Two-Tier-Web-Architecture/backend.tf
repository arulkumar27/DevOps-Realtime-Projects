terraform {
  backend "s3" {
    key            = "two-tier-aws/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "arulkumar-terraform-locks"
    encrypt        = true
  }

  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project   = "Two-Tier-AWS-Architecture"
      ManagedBy = "Terraform"
      Owner     = "Arul-Kumar"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "Two-Tier-AWS-Architecture"
      ManagedBy = "Terraform"
      Owner     = "Arul-Kumar"
    }
  }
}
