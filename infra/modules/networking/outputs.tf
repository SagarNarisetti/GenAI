### VPC Outputs
output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the main VPC"
  value       = aws_vpc.main_vpc.cidr_block
}

### Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.vpc_internet_gateway.id
}

### Public Subnet Outputs
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "public_subnet_cidr_block" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.public_subnet.cidr_block
}

output "public_subnet_az" {
  description = "Availability Zone of the public subnet"
  value       = aws_subnet.public_subnet.availability_zone
}

### Private Data Subnet Outputs
output "private_data_subnet_id" {
  description = "ID of the private data subnet"
  value       = aws_subnet.private_data_subnet.id
}

output "private_data_subnet_cidr_block" {
  description = "CIDR block of the private data subnet"
  value       = aws_subnet.private_data_subnet.cidr_block
}

output "private_data_subnet_az" {
  description = "Availability Zone of the private data subnet"
  value       = aws_subnet.private_data_subnet.availability_zone
}

### Private ML Subnet Outputs
output "private_ml_subnet_id" {
  description = "ID of the private ML subnet"
  value       = aws_subnet.private_ml_subnet.id
}

output "private_ml_subnet_cidr_block" {
  description = "CIDR block of the private ML subnet"
  value       = aws_subnet.private_ml_subnet.cidr_block
}

output "private_ml_subnet_az" {
  description = "Availability Zone of the private ML subnet"
  value       = aws_subnet.private_ml_subnet.availability_zone
}

### Private App Subnet Outputs
output "private_app_subnet_id" {
  description = "ID of the private app subnet"
  value       = aws_subnet.private_app_subnet.id
}

output "private_app_subnet_cidr_block" {
  description = "CIDR block of the private app subnet"
  value       = aws_subnet.private_app_subnet.cidr_block
}

output "private_app_subnet_az" {
  description = "Availability Zone of the private app subnet"
  value       = aws_subnet.private_app_subnet.availability_zone
}

### Subnet Collection Outputs (for multi-use)
output "private_subnet_ids" {
  description = "List of all private subnet IDs"
  value       = [
    aws_subnet.private_data_subnet.id,
    aws_subnet.private_ml_subnet.id,
    aws_subnet.private_app_subnet.id
  ]
}

output "all_subnet_ids" {
  description = "List of all subnet IDs (public and private)"
  value       = [
    aws_subnet.public_subnet.id,
    aws_subnet.private_data_subnet.id,
    aws_subnet.private_ml_subnet.id,
    aws_subnet.private_app_subnet.id
  ]
}

### NAT Gateway Outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id
}

output "nat_gateway_ip" {
  description = "Elastic IP associated with NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway (same as above)"
  value       = aws_eip.nat.public_ip
}

### Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private_route_table.id
}

### Route Table Association Outputs
output "public_route_table_association_id" {
  description = "ID of the public route table association"
  value       = aws_route_table_association.public_route_association.id
}

output "private_data_route_table_association_id" {
  description = "ID of the private data route table association"
  value       = aws_route_table_association.private_data_assoc.id
}

output "private_ml_route_table_association_id" {
  description = "ID of the private ML route table association"
  value       = aws_route_table_association.private_ml_assoc.id
}

output "private_app_route_table_association_id" {
  description = "ID of the private app route table association"
  value       = aws_route_table_association.private_app_assoc.id
}

### Summary Outputs
output "networking_summary" {
  description = "Summary of all networking resources"
  value = {
    vpc_id                   = aws_vpc.main_vpc.id
    vpc_cidr                 = aws_vpc.main_vpc.cidr_block
    internet_gateway_id      = aws_internet_gateway.vpc_internet_gateway.id
    nat_gateway_id           = aws_nat_gateway.nat_gateway.id
    nat_gateway_public_ip    = aws_eip.nat.public_ip
    public_subnet_id         = aws_subnet.public_subnet.id
    private_data_subnet_id   = aws_subnet.private_data_subnet.id
    private_ml_subnet_id     = aws_subnet.private_ml_subnet.id
    private_app_subnet_id    = aws_subnet.private_app_subnet.id
    public_route_table_id    = aws_route_table.public_route_table.id
    private_route_table_id   = aws_route_table.private_route_table.id
  }
}
