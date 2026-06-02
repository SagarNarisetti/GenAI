### Elastic IP for NAT gateway

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "mleng-nat-eip"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.vpc_internet_gateway]
}

# NAT Gateway (in public subnet for private subnet egress)
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "mleng-natgateway"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.vpc_internet_gateway]
}