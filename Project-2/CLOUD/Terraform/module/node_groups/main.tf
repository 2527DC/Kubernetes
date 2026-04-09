# Node Groups Module - Main Configuration

# Policy attachments for the passed role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = var.node_role_name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = var.node_role_name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = var.node_role_name
}

resource "aws_iam_role_policy_attachment" "eks_ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = var.node_role_name
}

# Attachments are handled above.

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${var.node_group_name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  # Scaling configuration
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # Update configuration
  update_config {
    max_unavailable_percentage = 25
  }

  # Instance types configuration
  instance_types = var.instance_families

  # Node group capacity type (ON_DEMAND or SPOT)
  capacity_type = var.capacity_type

  # Launch template for advanced configuration
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${var.node_group_name}-ng"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

# Launch Template for advanced node configuration
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.project_name}-eks-node-"
  description = "Launch template for EKS nodes"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = true
  }

  # Add custom tags to EBS volumes
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-node-volume"
      }
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-node"
      }
    )
  }

  # Removed custom user_data to allow EKS managed node group to handle bootstrapping

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-lt"
    }
  )
}
