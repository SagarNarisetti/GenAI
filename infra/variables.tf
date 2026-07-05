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
    default = "10.0.1.0/24"
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

## ECR Configuration
variable "ecr_repository_name" {
    description = "Name of the ECR repository"
    type = string
    default = "rag-app"
}

variable "ecr_image_tag_mutability" {
    description = "Image tag mutability for ECR"
    type = string
    default = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
    description = "Enable ECR image scanning on push"
    type = bool
    default = true
}

variable "ecr_encryption_type" {
    description = "ECR repository encryption type"
    type = string
    default = "AES256"
}

variable "ecr_enable_repository_policy" {
    description = "Enable ECR repository policy"
    type = bool
    default = false
}

variable "ecr_enable_pull_through_cache" {
    description = "Enable ECR pull-through cache"
    type = bool
    default = false
}

variable "ecr_pull_through_cache_prefix" {
    description = "ECR pull-through cache prefix"
    type = string
    default = "docker-hub"
}

variable "ecr_upstream_registry_url" {
    description = "Upstream registry URL for pull-through cache"
    type = string
    default = "registry-1.docker.io"
}

## EKS Configuration
variable "eks_cluster_name" {
    description = "Name of the EKS cluster"
    type = string
    default = "mleng-eks-cluster"
}

variable "eks_cluster_version" {
    description = "Kubernetes version for EKS cluster"
    type = string
    default = "1.30"
}

variable "eks_node_group_name" {
    description = "Name of the EKS node group"
    type = string
    default = "mleng-node-group"
}

variable "eks_desired_size" {
    description = "Desired number of EKS nodes"
    type = number
    default = 2
}

variable "eks_min_size" {
    description = "Minimum number of EKS nodes"
    type = number
    default = 1
}

variable "eks_max_size" {
    description = "Maximum number of EKS nodes"
    type = number
    default = 4
}

variable "eks_instance_types" {
    description = "Instance types for EKS nodes"
    type = list(string)
    default = ["t3.medium"]
}

variable "eks_disk_size" {
    description = "EBS volume size for EKS nodes in GiB"
    type = number
    default = 50
}

variable "eks_enable_cluster_logging" {
    description = "Enable EKS cluster logging"
    type = bool
    default = true
}

variable "eks_log_types" {
    description = "EKS cluster log types to enable"
    type = list(string)
    default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_cluster_role_name" {
    description = "Name of the IAM role for the EKS cluster"
    type = string
}

variable "eks_node_role_name" {
    description = "Name of the IAM role for EKS nodes"
    type = string
}

variable "eks_admin_role_name" {
    description = "Name of the admin IAM role for EKS cluster access"
    type = string
}

variable "eks_ecr_push_policy" {
    description = "Name of the IAM policy for EKS nodes to push images to ECR"
    type = string 
    }



## Bedrock Configuration
variable "bedrock_namespace" {
    description = "Kubernetes namespace where Bedrock pods will run"
    type = string
    default = "inference"
}

variable "bedrock_service_account_name" {
    description = "Kubernetes service account name for Bedrock IRSA"
    type = string
    default = "bedrock-sa"
}