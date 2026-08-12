# VPC
variable "VPC-NAME" {}
variable "VPC-CIDR" {}
variable "IGW-NAME" {}
variable "PUBLIC-CIDR1" {}
variable "PUBLIC-SUBNET1" {}
variable "PUBLIC-CIDR2" {}
variable "PUBLIC-SUBNET2" {}
variable "PRIVATE-CIDR1" {}
variable "PRIVATE-SUBNET1" {}
variable "PRIVATE-CIDR2" {}
variable "PRIVATE-SUBNET2" {}
variable "EIP-NAME1" {}
variable "EIP-NAME2" {}
variable "NGW-NAME1" {}
variable "NGW-NAME2" {}
variable "PUBLIC-RT-NAME1" {}
variable "PUBLIC-RT-NAME2" {}
variable "PRIVATE-RT-NAME1" {}
variable "PRIVATE-RT-NAME2" {}

# Security groups
variable "ALB-SG-NAME" {}
variable "WEB-SG-NAME" {}
variable "DB-SG-NAME" {}

# RDS
variable "SG-NAME" {}
variable "RDS-USERNAME" {}
variable "RDS-PWD" {
  sensitive = true
}
variable "DB-NAME" {}
variable "RDS-NAME" {}

# Load balancer
variable "TG-NAME" {}
variable "ALB-NAME" {}

# IAM
variable "IAM-ROLE" {}
variable "IAM-POLICY" {}
variable "INSTANCE-PROFILE-NAME" {}

# Auto Scaling
variable "AMI-NAME" {}
variable "LAUNCH-TEMPLATE-NAME" {}
variable "ASG-NAME" {}

# CloudFront and Route 53
variable "DOMAIN-NAME" {}
variable "CDN-NAME" {}

# WAF
variable "WEB-ACL-NAME" {}
