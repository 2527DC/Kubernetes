# Production-Grade EKS Infrastructure with Terraform

This is a modular, production-ready Terraform project for provisioning AWS EKS (Elastic Kubernetes Service) clusters with VPC, security groups, and node groups.

## 📋 Project Structure

```
CLOUD/
├── Terraform/
│   ├── main.tf                    # Root module - orchestrates all submodules
│   ├── variables.tf               # Root variables
│   ├── outputs.tf                 # Root outputs
│   ├── provider.tf                # AWS provider configuration
│   ├── terraform.tfvars           # Example variable values
│   └── module/
│       ├── vpc/
│       │   ├── main.tf            # VPC, subnets, IGW, route tables
│       │   ├── variables.tf       # VPC input variables
│       │   └── outputs.tf         # VPC outputs
│       ├── security_groups/
│       │   ├── main.tf            # 2 security groups (control plane & nodes)
│       │   ├── variables.tf       # Security group variables
│       │   └── outputs.tf         # Security group outputs
│       ├── eks_cluster/
│       │   ├── main.tf            # EKS cluster, OIDC, KMS encryption
│       │   ├── variables.tf       # Cluster variables
│       │   └── outputs.tf         # Cluster outputs
│       └── node_groups/
│           ├── main.tf            # Node groups, IAM, launch template
│           ├── variables.tf       # Node group variables
│           ├── user_data.sh       # Node initialization script
│           └── outputs.tf         # Node group outputs
```

## ✨ Key Features

### VPC & Networking

- **Dual Availability Zone** setup for high availability
- **Public Subnets** with Internet Gateway for NAT, Load Balancers
- **Private Subnets** for EKS nodes (isolated from internet)
- **NAT Gateway** for outbound internet access from private subnets
- **Route Tables** properly configured for public/private routing
- Kubernetes-specific tags for AWS Load Balancer Controller discovery

### Security Groups (2 Required SGs)

1. **EKS Control Plane SG**
   - HTTPS access (443) from allowed CIDRs
   - Inbound from worker nodes for kubelet communication
   - All outbound traffic allowed

2. **EKS Node SG**
   - Communication with control plane (1025-65535)
   - Node-to-node communication
   - VPC internal traffic (10.0.0.0/16)
   - All outbound traffic

### EKS Cluster

- **Manual Configuration** (no auto mode - full control)
- **Kubernetes 1.29** (configurable via variables)
- **Logging** to CloudWatch (API, Audit, Authenticator, Controller Manager, Scheduler)
- **KMS Encryption** for secrets
- **OIDC Provider** for IRSA (IAM Roles for Service Accounts)

### Node Groups

- **Configurable Min/Max/Desired** node count via variables
- **Multiple Instance Families** support (e.g., t3, t3a, m5, etc.)
- **Launch Template** for advanced configuration
- **Auto Scaling** with proper tagging for cluster autoscaler
- **100GB EBS** root volume with encryption
- **Monitoring** enabled via CloudWatch
- IAM roles for:
  - Worker Node Policy
  - CNI Policy
  - Container Registry Read-only
  - SSM Session Manager access

## 🚀 Getting Started

### Prerequisites

```bash
- Terraform >= 1.0
- AWS CLI configured with credentials
- kubectl (for cluster access)
- aws-iam-authenticator
```

### 1. Customize Variables

Edit `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
project_name = "my-eks-cluster"
environment = "prod"

# VPC
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Nodes
node_min_size = 2
node_desired_size = 3
node_max_size = 5
node_instance_families = ["t3", "t3a"]  # Configurable!

# Security
allowed_inbound_cidrs = ["203.0.113.0/24"]  # Your IP/VPN CIDR
```

### 2. Initialize Terraform

```bash
cd CLOUD/Terraform
terraform init
```

### 3. Plan and Review

```bash
terraform plan -out=tfplan
# Review the 30-40 resources to be created
```

### 4. Apply Configuration

```bash
terraform apply tfplan
# This takes ~15-20 minutes for EKS cluster and node groups
```

### 5. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-production-cluster
kubectl get nodes
```

## 📊 Module Details

### VPC Module

- Creates VPC with CIDR block
- 2 Public subnets in different AZs
- 2 Private subnets in different AZs
- Internet Gateway for public traffic
- NAT Gateway(s) for private subnet outbound
- Route tables with proper routes
- Tags for Kubernetes service discovery

### Security Groups Module

Creates 2 security groups:

1. **eks_control_plane_sg** - Control plane access rules
2. **eks_nodes_sg** - Worker node access rules

**Important:** These are wired together for proper communication.

### EKS Cluster Module

- Provisions EKS control plane
- Creates CloudWatch log group
- Enables encryption with KMS
- Sets up OIDC provider for IRSA
- Manages cluster roles and policies

### Node Groups Module

- Creates managed node groups
- Configurable instance types via variables
- Auto Scaling Group integration
- Launch template for advanced node setup
- Proper IAM roles and policies

## 🔧 Customization Examples

### Change Instance Families

```hcl
# Use memory-optimized instances
node_instance_families = ["r5", "r6i"]

# Use compute-optimized instances
node_instance_families = ["c5", "c6i"]

# Mixed on-demand and spot
node_instance_families = ["t3", "m5", "c5"]
```

### Scale Node Group

```hcl
node_min_size     = 3
node_desired_size = 5
node_max_size     = 10
```

### Change Availability Zones

```hcl
aws_region         = "eu-west-1"
availability_zones = ["eu-west-1a", "eu-west-1b"]
```

### Enable Spot Instances (Cost Optimization)

In the node_groups module `main.tf`, change:

```hcl
capacity_type = "SPOT"  # Instead of "ON_DEMAND"
```

## 📈 Scaling the Infrastructure

### Horizontal Scaling (More Nodes)

```hcl
# Just update terraform.tfvars
node_desired_size = 10
node_max_size = 20

# Apply changes
terraform apply
```

### Adding Multiple Node Groups

Create a new module invocation in `main.tf`:

```hcl
module "node_groups_gpu" {
  source         = "./module/node_groups"
  cluster_name   = module.eks_cluster.cluster_name
  node_group_name = "gpu"
  instance_families = ["g4dn"]
  # ... other configuration
}
```

## ❓ Multiple Cluster Strategies

### **Question: Should I create separate projects or update the same project for different cluster specs?**

### Answer: **Use the SAME project structure with environments**

#### Strategy 1: Environment-Based (Recommended ✅)

```
Terraform/
├── environments/
│   ├── prod/
│   │   └── terraform.tfvars
│   ├── staging/
│   │   └── terraform.tfvars
│   └── dev/
│       └── terraform.tfvars
├── main.tf
├── variables.tf
├── module/
└── provider.tf
```

Usage:

```bash
# Production
terraform apply -var-file="environments/prod/terraform.tfvars"

# Staging with different specs
terraform apply -var-file="environments/staging/terraform.tfvars"
```

#### Strategy 2: Multiple workspaces

```bash
terraform workspace new prod
terraform workspace new staging
terraform workspace new dev

# Switch and apply different configs
terraform workspace select prod
terraform apply -var-file="prod.tfvars"
```

#### Strategy 3: Different AWS Accounts

```bash
# Use AWS_PROFILE environment variable
export AWS_PROFILE=prod-account
terraform apply -var-file="prod.tfvars"

export AWS_PROFILE=dev-account
terraform apply -var-file="dev.tfvars"
```

### ✅ Why NOT separate projects?

❌ **Code Duplication** - Same module code repeated
❌ **Maintenance Nightmare** - Bug fixes needed in multiple places
❌ **Consistency Issues** - Different versions of modules
❌ **Storage Overhead** - Same code, multiple state files

### ✅ Why use single project with variables?

✅ **DRY Principle** - Code written once
✅ **Easy Maintenance** - Fix once, applies everywhere
✅ **Consistency** - All clusters use same infrastructure code
✅ **Version Control** - One source of truth
✅ **Cost Efficiency** - No duplicate code

## 📝 Example: Different Cluster Configurations

### Pod Configuration

```hcl
# prod.tfvars
node_min_size     = 3
node_desired_size = 5
node_max_size     = 10
node_instance_families = ["m5", "m6i"]

# dev.tfvars
node_min_size     = 1
node_desired_size = 2
node_max_size     = 3
node_instance_families = ["t3"]
```

### Staging Configuration

```hcl
# staging.tfvars
node_min_size     = 2
node_desired_size = 3
node_max_size     = 6
node_instance_families = ["t3", "t3a"]
```

### Multi-AZ vs Single-AZ

```hcl
# prod.tfvars - Multi-AZ HA
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
single_nat_gateway = false

# dev.tfvars - Cost optimized single NAT
availability_zones = ["us-east-1a", "us-east-1b"]
single_nat_gateway = true
```

## 🔐 Security Best Practices

1. **Restrict allowed_inbound_cidrs**

   ```hcl
   allowed_inbound_cidrs = ["203.0.113.0/24"]  # Your corporate VPN/IP
   ```

2. **Enable KMS encryption** (enabled by default)
   - Encrypts secrets in etcd

3. **Use OIDC for Service Accounts** (configured)
   - Enables fine-grained IAM permissions

4. **Enable logging** (configured)
   - All control plane logs sent to CloudWatch

5. **Use private subnets for nodes**
   - NAT gateway provides outbound access only

## 📊 Cost Optimization Tips

1. **Use SPOT instances in dev/staging**
   - Change `capacity_type = "SPOT"` in variables

2. **Single NAT Gateway for non-prod**
   - Set `single_nat_gateway = true`

3. **Right-size instances**
   - Dev: `t3.small` via node_instance_families
   - Prod: `m5`, `m6i` for better performance

4. **Auto-scaling**
   - Cluster Autoscaler will scale based on demand

## 🧪 Testing

```bash
# Validate syntax
terraform validate

# Check formatting
terraform fmt -recursive

# Dry run
terraform plan

# See what will be destroyed
terraform plan -destroy
```

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy -var-file="terraform.tfvars"

# Or specific resources
terraform destroy -target=module.node_groups
```

## 📚 Useful Commands

```bash
# Get cluster info
aws eks describe-cluster --name eks-production-cluster --region us-east-1

# Get node group info
aws eks describe-nodegroup --cluster-name eks-production-cluster \
  --nodegroup-name eks-production-cluster-primary-ng

# List all node groups
aws eks list-nodegroups --cluster-name eks-production-cluster

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name eks-production-cluster

# Verify cluster access
kubectl auth can-i create deployments --as=system:serviceaccount:kube-system:aws-node
```

## 🐛 Troubleshooting

### Nodes not joining cluster

```bash
# Check node group status
aws eks describe-nodegroup --cluster-name eks-production-cluster \
  --nodegroup-name eks-production-cluster-primary-ng

# Check node logs
aws ec2 describe-instances --filters "Name=tag:aws:eks:cluster-name,Values=eks-production-cluster" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
```

### OIDC provider issues

```bash
# Verify OIDC is configured
aws iam list-open-id-connect-providers

# Test IAM role assumption
aws sts assume-role-with-web-identity --role-arn <role-arn> \
  --role-session-name test --web-identity-token <token>
```

## 📖 Additional Resources

- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📄 License

This project is provided as-is for learning and production use.

## 🤝 Support

For issues:

1. Check the troubleshooting section
2. Review AWS CloudFormation events
3. Check EKS control plane logs in CloudWatch
4. Review Terraform state: `terraform show`

---

**Happy Kubernetes deployment! 🚀**
