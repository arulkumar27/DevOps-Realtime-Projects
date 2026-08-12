data "aws_caller_identity" "current" {}

locals {
  state_bucket_name = "${var.project_name}-${data.aws_caller_identity.current.account_id}-tfstate"
}

data "terraform_remote_state" "primary" {
  backend = "s3"

  config = {
    bucket = local.state_bucket_name
    key    = "primary/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "dr" {
  backend = "s3"

  config = {
    bucket = local.state_bucket_name
    key    = "dr/terraform.tfstate"
    region = var.aws_region
  }
}

module "route53" {
  source = "../modules/route53"

  hosted_zone_name     = var.hosted_zone_name
  record_name          = var.record_name
  primary_alb_dns_name = data.terraform_remote_state.primary.outputs.primary_alb_dns_name
  primary_alb_zone_id  = data.terraform_remote_state.primary.outputs.primary_alb_zone_id
  dr_alb_dns_name      = data.terraform_remote_state.dr.outputs.dr_alb_dns_name
  dr_alb_zone_id       = data.terraform_remote_state.dr.outputs.dr_alb_zone_id
}