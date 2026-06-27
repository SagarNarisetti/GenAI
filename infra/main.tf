provider "aws" {
    region = var.aws_region
}

terraform {
    required_version = ">= 1.10.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

module "iam" {
    source = "./modules/iam"

    iam_user_name   = var.iam_user_name
    iam_role_name   = var.iam_role_name
    iam_policy_name = var.iam_policy_name

    eks_admin_role_name = var.eks_admin_role_name
    eks_cluster_role_name = var.eks_cluster_role_name
    eks_node_role_name = var.eks_node_role_name
    eks_ecr_push_policy = var.eks_ecr_push_policy

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

module "ecr" {
    source = "./modules/ecr"

    repository_name         = var.ecr_repository_name
    image_tag_mutability    = var.ecr_image_tag_mutability
    scan_on_push            = var.ecr_scan_on_push
    encryption_type         = var.ecr_encryption_type
    enable_repository_policy = var.ecr_enable_repository_policy
    enable_pull_through_cache = var.ecr_enable_pull_through_cache
    pull_through_cache_prefix = var.ecr_pull_through_cache_prefix
    upstream_registry_url   = var.ecr_upstream_registry_url

    tags = {
        Environment = var.environment
        Service = "ECR"
    }

    depends_on = [module.iam]
}

module "eks" {
    source = "./modules/eks"
    # Values coming from your config files (variables)
    cluster_version     = var.eks_cluster_version
    node_group_name     = var.eks_node_group_name
    desired_size        = var.eks_desired_size
    min_size            = var.eks_min_size
    max_size            = var.eks_max_size
    instance_types      = var.eks_instance_types
    disk_size           = var.eks_disk_size
    enable_cluster_logging = var.eks_enable_cluster_logging
    log_types           = var.eks_log_types
    
    # Values coming from your networking module
    vpc_id             = module.networking.vpc_id
    private_subnet_ids = module.networking.private_subnet_ids
    public_subnet_ids  = concat([module.networking.public_subnet_id], [])

    mleng_user_arn     = module.iam.mleng_user_arn
    cluster_role_arn   = module.iam.eks_cluster_role_arn
    node_role_arn      = module.iam.eks_node_role_arn
    eks_admin_role_arn = module.iam.eks_admin_role_arn

    tags = {
        Environment = var.environment
        Service = "EKS"
    }

    depends_on = [
        module.networking,
        module.iam,
        module.ecr
    ]
}


module "bedrock" {
    source = "./modules/bedrock"
    
    project_name        = "mleng"
    environment         = var.environment
    aws_region          = var.aws_region
    vpc_cidr            = var.vpc_cidr
    
    # OIDC provider information from EKS
    oidc_provider_arn   = module.eks.oidc_provider_arn
    oidc_provider_url   = module.eks.oidc_provider_url
    
    # VPC and networking information
    vpc_id              = module.networking.vpc_id
    private_subnet_ids  = module.networking.private_subnet_ids
    
    # Bedrock access configuration
    bedrock_namespace          = var.bedrock_namespace
    bedrock_service_account_name = var.bedrock_service_account_name
    
    tags = {
        Environment = var.environment
        Service = "Bedrock"
    }

    depends_on = [
        module.networking,
        module.eks
    ]
}