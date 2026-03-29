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