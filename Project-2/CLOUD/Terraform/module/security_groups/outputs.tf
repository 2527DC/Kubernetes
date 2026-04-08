# Security Groups Module - Outputs

output "eks_control_plane_sg_id" {
  description = "Security group ID for EKS control plane"
  value       = aws_security_group.eks_control_plane.id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "eks_control_plane_sg_name" {
  description = "Security group name for EKS control plane"
  value       = aws_security_group.eks_control_plane.name
}

output "eks_nodes_sg_name" {
  description = "Security group name for EKS worker nodes"
  value       = aws_security_group.eks_nodes.name
}
