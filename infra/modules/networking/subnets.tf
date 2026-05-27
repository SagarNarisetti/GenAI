### public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true

    tags = {
        Name = "Mleng Public Subnet"
        Environment = var.environment
        Type = "Public"
    }
}


### private subnets

# private data subnet
resource "aws_subnet" "private_data_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_data_subnet
    availability_zone = var.private_data_subnet_az
    map_public_ip_on_launch = true

    tags = {
        Name = "mleng private data subnet"
        Environment = var.aws_region
        Type = "Private"    
    }
}

# private ml subnet
resource "aws_subnet" "private_ml_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_ml_subnet
    availability_zone = var.private_ml_subnet_az
    map_public_ip_on_launch = true

    tags = {
        Name = "mleng private ML subnet"
        Environment = var.aws_region
        Type = "Private"    
    }
}

# private app subnet
resource "aws_subnet" "private_app_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_app_subnet
    availability_zone = var.private_app_subnet_az
    map_public_ip_on_launch = true

    tags = {
        Name = "mleng private app subnet"
        Environment = var.aws_region
        Type = "private"
    }
}