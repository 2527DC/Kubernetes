# Node Groups Module - Main Configuration

# IAM Role for EC2 nodes
resource "aws_iam_role" "node_group_role" {
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
      Name = "${var.cluster_name}-node-role"
    }
  )
}

# Attach required policies
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEK_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_group_role.name
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${var.node_group_name}-ng"
  node_role_arn   = aws_iam_role.node_group_role.arn
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

  # Instance types configuration with mixed instances
  instance_types = [
    for family in var.instance_families : "${family}.medium"
  ]

  # Node group capacity type (ON_DEMAND or SPOT)
  capacity_type = var.capacity_type

  # Disk configuration
  disk_size = var.disk_size

  # Launch template for advanced configuration
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version_number
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

  UserData = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name       = var.cluster_name
    cluster_endpoint   = "" # Will be populated by root module
    cluster_ca         = "" # Will be populated by root module
  }))

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-lt"
    }
  )
}

# Auto Scaling Group tags for discovery
resource "aws_autoscaling_group_tag" "cluster_autoscaler_discovery" {
  for_each = data.aws_eks_node_group.node_group.asg_tags

  autoscaling_group_name = each.value.autoscaling_group_name
  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = false
  }
}

# Data source to get the Auto Scaling Group from the Node Group
data "aws_eks_node_group" "node_group" {
  cluster_name       = var.cluster_name
  node_group_name    = aws_eks_node_group.main.node_group_name
}
