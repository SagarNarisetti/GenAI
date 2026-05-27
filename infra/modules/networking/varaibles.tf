variable "environment" {
    description = "env region"
    type = string
}

variable "private_data_subnet" {
    description = "private data subnet IP"
    type = string
}

variable "private_app_subnet" {
    description = "private app subnet IP"
    type = string
}

variable "private_ml_subnet" {
    description = "private ml subnet IP"
    type = string
}

variable "vpc_cidr" {
    description = "CIDR Ip address"
    type = string
}

variable "public_subnet_cidr" {
    description = "public subnet IP"
    type = string
}

variables "private_data_subnet_az" {
    description = "private data subnet AZ"
    type = string
}
 variables "private_app_subnet" {
    description = "private app subnet AZ"
    type = string
 }

 variables "private_ml_subnet_az" {
    description = "private ml subnet AZ"
    type = string
 }