# Node Groups Module - Outputs

output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "EKS node group status"
  value       = aws_eks_node_group.main.status
}

output "node_role_arn" {
  description = "IAM role ARN for nodes"
  value       = aws_iam_role.node_group_role.arn
}

output "node_role_name" {
  description = "IAM role name for nodes"
  value       = aws_iam_role.node_group_role.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.eks_nodes.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = data.aws_eks_node_group.node_group.asg_tags[0].autoscaling_group_name
}
