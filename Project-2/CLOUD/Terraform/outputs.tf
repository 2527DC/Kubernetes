# Root Module - Outputs

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

# Security Groups Outputs
output "eks_control_plane_sg_id" {
  description = "Security group ID for EKS control plane"
  value       = module.security_groups.eks_control_plane_sg_id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS nodes"
  value       = module.security_groups.eks_nodes_sg_id
}

# EKS Cluster Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks_cluster.cluster_version
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "ARN of OIDC provider for IRSA"
  value       = module.eks_cluster.oidc_provider_arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA"
  value       = module.eks_cluster.oidc_issuer_url
}

# Node Group Outputs
output "node_group_id" {
  description = "Node group ID"
  value       = module.node_groups.node_group_id
}

output "node_group_arn" {
  description = "Node group ARN"
  value       = module.node_groups.node_group_arn
}

output "node_group_status" {
  description = "Node group status"
  value       = module.node_groups.node_group_status
}

# Configure kubectl
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
}

# Summary
output "summary" {
  description = "Summary of created resources"
  value = {
    cluster_name           = module.eks_cluster.cluster_name
    cluster_endpoint       = module.eks_cluster.cluster_endpoint
    node_group_name        = module.node_groups.node_group_id
    vpc_id                 = module.vpc.vpc_id
    control_plane_sg_id    = module.security_groups.eks_control_plane_sg_id
    nodes_sg_id            = module.security_groups.eks_nodes_sg_id
  }
}
