resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc-name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw-name
  }
}

resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-cidr1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet1
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-cidr2
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet2
  }
}

resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private-cidr1
  availability_zone = "ap-south-1a"

  tags = {
    Name = var.private-subnet1
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private-cidr2
  availability_zone = "ap-south-1b"

  tags = {
    Name = var.private-subnet2
  }
}
