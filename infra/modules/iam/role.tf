### mleng_role
resource "aws_iam_role" "mleng_role" {
    name = var.iam_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "AllowUserAssumption"
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    AWS = [
                        aws_iam_user.mleng_user.arn
                        ]
                        }
            },
            {
                Sid    = "AllowServiceAssumption"
                Effect = "Allow"
                Principal = {
                Service = [
                    "eks.amazonaws.com",
                    "ecr.amazonaws.com",
                    "ec2.amazonaws.com",
                    "bedrock.amazonaws.com",
                    "sagemaker.amazonaws.com",
                    "lambda.amazonaws.com",
                    "iam.amazonaws.com"
                ]
                }
                Action = "sts:AssumeRole"
            }
            ]
    })
    tags = {
        Environment = var.environment
        Purpose = "Execution Role"
    }
}


# EKS Cluster Service Role
resource "aws_iam_role" "eks_cluster_role" {
  name = var.eks_cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "EKS Cluster Service Role"
  }
}

# Attach required policy for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach VPC CNI policy for networking
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# EKS Node Group Role
resource "aws_iam_role" "eks_node_role" {
  name = var.eks_node_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "EKS Node Group Role"
  }
}

# Attach required policy for EKS nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach CNI policy for networking
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach ECR read-only policy for pulling images
resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach CloudWatch Logs policy for logging
resource "aws_iam_role_policy_attachment" "eks_cloudwatch_logs" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom policy for ECR push access (for development)
resource "aws_iam_policy" "eks_ecr_push_policy" {
  name        = var.eks_ecr_push_policy
  description = "Policy to allow EKS nodes to push images to ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRPushAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Attach ECR push policy to node role
resource "aws_iam_role_policy_attachment" "eks_ecr_push_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.eks_ecr_push_policy.arn
}

### EKS Admin Role (for cluster access)
resource "aws_iam_role" "eks_admin_role" {
  name = var.eks_admin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.mleng_user.arn
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "eks.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "EKS Admin Role"
  }
}
