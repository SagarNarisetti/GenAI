variable "environment" {
    description = "env region"
    type = string
    default = "prod"
}
## VPC 
variable "vpc_cidr" {
    description = "CIDR Ip address"
    type = string
    default = "10.0.0.0/16"
}
### subnets
variable "public_subnet_cidr" {
    description = "public subnet IP"
    type = string
    default = "10.0.1.0/24"
}

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


### availability zones 
variable "public_subnet_az" {
    description = "public subnet AZ"
    type = string
    default = "eu-west-1a"
}

variable "private_data_subnet_az" {
    description = "private data subnet AZ"
    type = string
    default = "eu-west-1a"
}
 variable "private_app_subnet_az" {
    description = "private app subnet AZ"
    type = string
    default = "eu-west-1b"
 }

 variable "private_ml_subnet_az" {
    description = "private ml subnet AZ"
    type = string
    default = "eu-west-1c"
 }