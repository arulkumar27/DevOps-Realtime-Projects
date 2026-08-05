resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = var.eip-name1
  }
}

resource "aws_eip" "eip2" {
  domain = "vpc"

  tags = {
    Name = var.eip-name2
  }
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public-subnet1.id

  tags = {
    Name = var.ngw-name1
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public-subnet2.id

  tags = {
    Name = var.ngw-name2
  }

  depends_on = [aws_internet_gateway.igw]
}
