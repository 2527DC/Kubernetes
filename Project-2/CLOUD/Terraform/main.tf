# Root Module - Main Configuration
# Orchestrates all submodules to create a production-grade EKS infrastructure

# VPC and Networking
module "vpc" {
  source = "./module/vpc"

  vpc_cidr               = var.vpc_cidr
  project_name           = var.project_name
  environment            = var.environment
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# Security Groups
module "security_groups" {
  source = "./module/security_groups"

  vpc_id                 = module.vpc.vpc_id
  vpc_cidr               = var.vpc_cidr
  project_name           = var.project_name
  environment            = var.environment
  allowed_inbound_cidrs  = var.allowed_inbound_cidrs

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# EKS Cluster
module "eks_cluster" {
  source = "./module/eks_cluster"

  cluster_name              = var.eks_cluster_name
  cluster_version           = var.eks_cluster_version
  cluster_role_arn          = aws_iam_role.eks_cluster_role.arn
  security_group_ids        = [module.security_groups.eks_control_plane_sg_id]
  subnet_ids                = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  environment               = var.environment
  project_name              = var.project_name
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# Node Groups
module "node_groups" {
  source = "./module/node_groups"

  cluster_name           = module.eks_cluster.cluster_name
  cluster_version        = var.eks_cluster_version
  node_group_name        = "primary"
  node_role_arn          = aws_iam_role.node_role.arn
  node_role_name          = aws_iam_role.node_role.name
  subnet_ids             = module.vpc.public_subnet_ids
  security_group_ids     = [module.security_groups.eks_nodes_sg_id]
  desired_size           = var.node_desired_size
  min_size               = var.node_min_size
  max_size               = var.node_max_size
  instance_families      = var.node_instance_families
  disk_size              = var.node_disk_size
  capacity_type          = "ON_DEMAND"
  environment            = var.environment
  project_name           = var.project_name

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )

  depends_on = [
    module.eks_cluster
  ]
}

# IAM Role for EKS Cluster (defined at root level for reusability)
resource "aws_iam_role" "eks_cluster_role" {
  name_prefix = "${var.project_name}-eks-cluster-"

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

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# IAM Role for Nodes (defined at root level for reusability)
resource "aws_iam_role" "node_role" {
  name_prefix = "${var.project_name}-eks-node-"

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

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-node-role"
    }
  )
}
