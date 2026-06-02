### access
variable "aws_region" {
    description = "AWS region"
    type = string
    default = "eu-west-1"
}

variable "environment" {
    description = "Developing environment"
    type = string
    default = "prod"
}

variable "iam_user_name" {
    description = "IAM User Name"
    type = string
    default = "MLEngDevUser"
}

variable "iam_role_name" {
    description = "IAM Role Name"
    type = string
    default = "MLEngDevRole"
}

variable "iam_policy_name" {
    description = "IAM policy name"
    type = string
    default = "MLEngDevPolicy"
}

## Networking
variable "vpc_cidr" {
    description = "CIDR Ip address"
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "public subnet IP"
    type = string
    default = "10.0.1.0/16"
}

# private subnets
variable "private_data_subnet" {
    description = "private data subnet IP"
    type = string
    default = "10.0.2.0/24"
}

variable "private_app_subnet" {
    description = "private app subnet IP"
    type = string
    default = "10.0.3.0/24"
}

variable "private_ml_subnet" {
    description = "private ml subnet IP"
    type = string
    default = "10.0.4.0/24"
}

variable "public_subnet_az" {
    description = "public subnet AZ"
    type = string
    default = "eu-west-2a"
}

variable "private_data_subnet_az" {
    description = "private data subnet AZ"
    type = string
    default = "eu_west_2a"
}
 variable "private_app_subnet_az" {
    description = "private app subnet AZ"
    type = string
    default = "eu_west_2b"
 }

 variable "private_ml_subnet_az" {
    description = "private ml subnet AZ"
    type = string
    default = "eu_west_2c"
 }