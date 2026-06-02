provider "aws" {
    region = var.aws_region
}

terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

module "iam" {
    source = "./modules/iam"

    iam_user_name = var.iam_user_name
    iam_role_name = var.iam_role_name
    iam_policy_name = var.iam_policy_name
    environment = var.environment
}

module "networking" {
    source = "./modules/networking"

    vpc_cidr            = var.vpc_cidr
    public_subnet_cidr  = var.public_subnet_cidr
    private_data_subnet = var.private_data_subnet
    private_app_subnet  = var.private_app_subnet
    private_ml_subnet   = var.private_ml_subnet

    environment = var.environment

    public_subnet_az = var.public_subnet_az
    private_data_subnet_az = var.private_data_subnet_az
    private_app_subnet_az = var.private_app_subnet_az
    private_ml_subnet_az = var.private_ml_subnet_az

    ## explicit dependency 
    depends_on = [module.iam]
}