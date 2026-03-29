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