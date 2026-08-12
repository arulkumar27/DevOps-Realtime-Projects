output "dr_vpc_id" {
  value = module.networking.vpc_id
}

output "dr_alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "dr_alb_zone_id" {
  value = module.alb.alb_zone_id
}

output "dr_target_group_arn" {
  value = module.alb.target_group_arn
}

output "dr_autoscaling_group_name" {
  value = module.autoscaling.autoscaling_group_name
}

output "dr_ubuntu_ami_id" {
  value = module.autoscaling.ubuntu_ami_id
}