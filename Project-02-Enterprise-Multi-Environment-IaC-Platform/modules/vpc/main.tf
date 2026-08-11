# Creates an isolated network for the environment.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-vpc"
    }
  )
}

# Provides internet connectivity to resources using public routes.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-igw"
    }
  )
}

# Creates one public subnet in each supplied Availability Zone.
resource "aws_subnet" "public" {
  for_each = {
    for index, zone in var.availability_zones :
    zone => {
      cidr  = var.public_subnet_cidrs[index]
      index = index
    }
  }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-public-${each.value.index + 1}"
      Tier = "Public"
    }
  )
}

# Creates one private application subnet in each Availability Zone.
resource "aws_subnet" "private" {
  for_each = {
    for index, zone in var.availability_zones :
    zone => {
      cidr  = var.private_subnet_cidrs[index]
      index = index
    }
  }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-private-${each.value.index + 1}"
      Tier = "Private"
    }
  )
}

# Public routing table used by the Application Load Balancer.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-public-rt"
    }
  )
}

# Sends public-subnet internet traffic through the Internet Gateway.
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associates every public subnet with the public routing table.
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private routing table intentionally has no direct internet route.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-private-rt"
    }
  )
}

# Associates every private subnet with the isolated route table.
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Removes all rules from the VPC default security group.
# Workloads must use explicitly managed security groups.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-default-sg-restricted"
    }
  )
}