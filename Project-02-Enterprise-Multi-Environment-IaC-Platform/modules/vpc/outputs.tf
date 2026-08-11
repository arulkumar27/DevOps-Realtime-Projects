output "vpc_id" {
  description = "ID of the environment VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block assigned to the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs ordered by Availability Zone input"
  value = [
    for zone in var.availability_zones :
    aws_subnet.public[zone].id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs ordered by Availability Zone input"
  value = [
    for zone in var.availability_zones :
    aws_subnet.private[zone].id
  ]
}

output "public_route_table_id" {
  description = "ID of the public routing table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private routing table"
  value       = aws_route_table.private.id
}