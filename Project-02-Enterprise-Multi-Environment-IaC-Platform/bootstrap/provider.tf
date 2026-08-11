# Configure AWS using the region supplied during deployment.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Automatically retrieve the current AWS account information.
data "aws_caller_identity" "current" {}

# Generate a unique S3 state-bucket name without hardcoding account details.
locals {
  normalized_project_name = replace(
    lower(trimspace(var.project_name)),
    " ",
    "-"
  )

  state_bucket_name = format(
    "%s-%s-%s-tfstate",
    substr(
      local.normalized_project_name,
      0,
      min(20, length(local.normalized_project_name))
    ),
    data.aws_caller_identity.current.account_id,
    var.aws_region
  )
}