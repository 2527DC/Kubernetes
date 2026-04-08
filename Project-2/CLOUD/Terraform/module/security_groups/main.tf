# Security Groups Module - Main Configuration

# Security Group 1: EKS Control Plane
resource "aws_security_group" "eks_control_plane" {
  name_prefix = "${var.project_name}-eks-cp-"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-control-plane-sg"
    }
  )
}

# Allow inbound HTTPS from allowed CIDRs
resource "aws_vpc_security_group_ingress_rule" "eks_cp_https_external" {
  security_group_id = aws_security_group.eks_control_plane.id

  description = "Allow HTTPS from external sources"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  cidr_ipv4 = var.allowed_inbound_cidrs[0]

  tags = {
    Name = "${var.project_name}-eks-cp-https-ingress"
  }
}

# Allow inbound from worker nodes
resource "aws_vpc_security_group_ingress_rule" "eks_cp_from_workers" {
  security_group_id = aws_security_group.eks_control_plane.id

  description              = "Allow incoming traffic from worker nodes"
  from_port                = 1025
  to_port                  = 65535
  ip_protocol              = "tcp"
  referenced_security_group_id = aws_security_group.eks_nodes.id

  tags = {
    Name = "${var.project_name}-eks-cp-from-workers"
  }
}

# Allow outbound all traffic
resource "aws_vpc_security_group_egress_rule" "eks_cp_egress" {
  security_group_id = aws_security_group.eks_control_plane.id

  description = "Allow all outbound traffic"
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-eks-cp-egress"
  }
}

# Security Group 2: EKS Worker Nodes
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-eks-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-nodes-sg"
    }
  )
}

# Allow pods to communicate with the cluster API
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_cp_communication" {
  security_group_id = aws_security_group.eks_nodes.id

  description              = "Allow communication from EKS control plane"
  from_port                = 1025
  to_port                  = 65535
  ip_protocol              = "tcp"
  referenced_security_group_id = aws_security_group.eks_control_plane.id

  tags = {
    Name = "${var.project_name}-eks-nodes-cp-ingress"
  }
}

# Allow nodes to communicate with each other
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_self" {
  security_group_id = aws_security_group.eks_nodes.id

  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  ip_protocol              = "tcp"
  referenced_security_group_id = aws_security_group.eks_nodes.id

  tags = {
    Name = "${var.project_name}-eks-nodes-self"
  }
}

# Allow inbound from VPC CIDR for internal communication
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_vpc_cidr" {
  security_group_id = aws_security_group.eks_nodes.id

  description = "Allow incoming traffic from within VPC"
  from_port   = 0
  to_port     = 65535
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-eks-nodes-vpc-ingress"
  }
}

# Allow outbound all traffic
resource "aws_vpc_security_group_egress_rule" "eks_nodes_egress" {
  security_group_id = aws_security_group.eks_nodes.id

  description = "Allow all outbound traffic"
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-eks-nodes-egress"
  }
}
