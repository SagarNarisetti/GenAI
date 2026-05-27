### VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags={
        Name = "MlengProject"
        Environment = var.environment
    }
}

### Interned gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vps.main.id

    tags = {
        Name = "MlengProject-igw"
        Environment = var.environment
    }
}