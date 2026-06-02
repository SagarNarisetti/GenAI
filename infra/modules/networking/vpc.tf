### VPC
resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags={
        Name = "mlengProjectVPC"
        Environment = var.environment
    }
}

### Interned gateway
resource "aws_internet_gateway" "vpc_internet_gateway" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "mlengProject-InternetGateway"
        Environment = var.environment
    }
}