### public route table
# public route
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc_internet_gateway.id
    }

    tags = {
        Name = "mleng_public_route_table"
        Environment = var.environment
    }
}

# associate public subnet with public route table
resource "aws_route_table_association" "public_route_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}


### private route tables for private nat_gateway

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gateway.id
    }

    tags = {
        Name = "mleng_private_route_table"
        Environment = var.environment
    }
}

# associate private subnet with private route table
resource "aws_route_table_association" "private_data_assoc" {
  subnet_id      = aws_subnet.private_data_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_ml_assoc" {
  subnet_id      = aws_subnet.private_ml_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_app_assoc" {
  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}