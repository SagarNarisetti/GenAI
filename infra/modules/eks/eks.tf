# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Enable control plane logging
  enabled_cluster_log_types = var.enable_cluster_logging ? var.log_types : []

  tags = merge(
    var.tags,
    {
      Name = var.eks_cluster_name
    }
  )

  depends_on = [
    aws_security_group_rule.eks_cluster_ingress,
    aws_security_group_rule.eks_cluster_egress
  ]
}

# Security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "eks-cluster-"
  vpc_id      = var.vpc_id
  description = "Security group for EKS cluster"

  tags = merge(
    var.tags,
    {
      Name = "${var.eks_cluster_name}-sg"
    }
  )
}

# Ingress rule for cluster communication
resource "aws_security_group_rule" "eks_cluster_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_sg.id
}

# Egress rule for cluster communication
resource "aws_security_group_rule" "eks_cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_sg.id
}

# EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = var.instance_types
  disk_size      = var.disk_size

  # Enable capacity type for cost optimization
  capacity_type = "ON_DEMAND"

  # Labels for node identification
  labels = {
    Environment = "production"
    NodeGroup   = var.node_group_name
  }

  tags = merge(
    var.tags,
    {
      Name = var.node_group_name
    }
  )

  # Ensure proper ordering of resource creation
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

# EKS access entry for admin role
resource "aws_eks_access_entry" "eks_admin_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.eks_admin_role_arn
  type          = "STANDARD"

  tags = var.tags
}

# Grant admin access to the cluster
resource "aws_eks_access_policy_association" "eks_admin_policy_assoc" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.eks_admin_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# OIDC Provider for IRSA (IAM Roles for Service Accounts)
data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  tags = var.tags
}