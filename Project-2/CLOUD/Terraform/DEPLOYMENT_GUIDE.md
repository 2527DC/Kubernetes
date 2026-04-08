# EKS Infrastructure Deployment Guide

## Quick Start (5 minutes)

### Step 1: Prerequisites Check

```bash
# Verify tools installed
terraform --version    # Should be >= 1.0
aws --version         # AWS CLI v2+
kubectl version --client
which aws-iam-authenticator

# Configure AWS credentials
aws configure
# Or export:
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"
```

### Step 2: Clone and Setup

```bash
cd /Users/admin/Desktop/Learning/Kubernetes/Project-2/CLOUD/Terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Step 3: Initialize

```bash
terraform init
```

### Step 4: Review Plan

```bash
terraform plan
# Review the ~35-40 resources that will be created
```

### Step 5: Deploy

```bash
terraform apply
# Type "yes" when prompted
# Wait 15-20 minutes for deployment
```

### Step 6: Configure kubectl

```bash
# Get cluster name from outputs
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw aws_region)

# Update kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Verify access
kubectl get nodes
kubectl get pods -A
```

---

## Detailed Deployment (Production Setup)

### Phase 1: Preparation (15 minutes)

#### 1.1 Review Project Structure

```bash
cd CLOUD/Terraform
tree -L 3
# Should show:
# ├── main.tf
# ├── variables.tf
# ├── outputs.tf
# ├── provider.tf
# ├── terraform.tfvars
# ├── README.md
# └── module/
#     ├── vpc/
#     ├── security_groups/
#     ├── eks_cluster/
#     └── node_groups/
```

#### 1.2 Set Up Environment Variables

```bash
# Create .env file for easy management
cat > .env << EOF
export AWS_REGION=us-east-1
export TF_VAR_aws_region=us-east-1
export TF_VAR_project_name=eks-prod
export TF_VAR_environment=prod
EOF

source .env
```

#### 1.3 Prepare terraform.tfvars

```bash
# Option A: For Production
cat > terraform.tfvars << 'EOF'
aws_region = "us-east-1"
project_name = "eks-production"
environment = "prod"

vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

eks_cluster_name = "eks-production-cluster"
eks_cluster_version = "1.29"

node_min_size = 2
node_desired_size = 3
node_max_size = 5
node_instance_families = ["m5", "m6i"]
node_disk_size = 100

enable_nat_gateway = true
single_nat_gateway = false

allowed_inbound_cidrs = ["203.0.113.0/24"]  # Your IP

tags = {
  Environment = "production"
  Managed_by  = "Terraform"
  Owner       = "DevOps"
}
EOF

# Option B: For Staging (Cost-optimized)
cat > terraform.tfvars << 'EOF'
aws_region = "us-east-1"
project_name = "eks-staging"
environment = "staging"

vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

eks_cluster_name = "eks-staging-cluster"
eks_cluster_version = "1.29"

node_min_size = 1
node_desired_size = 2
node_max_size = 3
node_instance_families = ["t3", "t3a"]
node_disk_size = 50

enable_nat_gateway = true
single_nat_gateway = true  # Save costs

allowed_inbound_cidrs = ["0.0.0.0/0"]

tags = {
  Environment = "staging"
  Managed_by  = "Terraform"
  Owner       = "DevOps"
}
EOF
```

### Phase 2: Infrastructure as Code Review (30 minutes)

#### 2.1 Validate Terraform Files

```bash
# Check syntax
terraform validate
# Output: Success! The configuration is valid.

# Format check
terraform fmt -recursive -check
# Apply formatting if needed
terraform fmt -recursive

# Security scan (optional but recommended)
# Install tfsec: brew install tfsec
tfsec . --minimum-severity=WARNING
```

#### 2.2 Review Modules

```bash
# Module 1: VPC
cat module/vpc/main.tf
# Creates: VPC, Subnets, IGW, NAT Gateway, Route Tables

# Module 2: Security Groups
cat module/security_groups/main.tf
# Creates: 2 Security Groups (Control Plane + Nodes)

# Module 3: EKS Cluster
cat module/eks_cluster/main.tf
# Creates: EKS Cluster, KMS Key, OIDC Provider, IAM Roles

# Module 4: Node Groups
cat module/node_groups/main.tf
# Creates: Node Group, IAM Roles, Launch Template, ASG Tags
```

#### 2.3 Understand Resource Dependencies

```
VPC Module
├── Security Groups Module (depends on VPC)
├── EKS Cluster Module (depends on Security Groups)
└── Node Groups Module (depends on EKS Cluster)
```

### Phase 3: Terraform Planning (20 minutes)

#### 3.1 Create Plan File

```bash
# Generate execution plan (doesn't create resources)
terraform plan -out=tfplan

# Output will show:
# - 35-40 resources to be created
# - Resource dependencies
# - No changes to existing resources (first run)
```

#### 3.2 Review Plan Details

```bash
# Show detailed plan
terraform plan -out=tfplan -detailed-exitcode

# Check specific resources
terraform plan | grep "aws_eks"
terraform plan | grep "aws_security_group"
terraform plan | grep "aws_subnet"

# Save human-readable plan
terraform plan -out=tfplan
terraform show tfplan > plan.txt
# Review plan.txt
```

#### 3.3 Cost Estimation (Optional)

```bash
# Install Infracost: brew install infracost
infracost breakdown --path .

# Or manual estimation:
# - VPC, Subnets, IGW, NAT Gateway: ~$40/month
# - EKS Cluster: $0.10/hour = ~$74/month
# - 3 x t3.medium Nodes: ~$60/month
# - EBS Storage (300GB): ~$30/month
# - NAT Gateway data: ~$5/month
# Total: ~$200-250/month (minimum)
```

### Phase 4: Deployment (20 minutes)

#### 4.1 Apply Terraform

```bash
# Execute the plan (creates all resources)
terraform apply tfplan

# Progress output:
# module.vpc.aws_vpc.main: Creating...
# module.vpc.aws_vpc.main: Creation complete (ID: vpc-xxxxx)
# ... (many resources)
# Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

# Wait time: 15-20 minutes
# Longest wait: EKS cluster creation
```

#### 4.2 Monitor Deployment Progress

```bash
# In another terminal, watch AWS console:
# - VPC created
# - Subnets and Route Tables configured
# - Security Groups created
# - IAM Roles created
# - EKS Cluster creating... (10 minutes)
# - Node Group creating... (5 minutes)
# - Nodes launching...

# Or via AWS CLI:
aws eks describe-cluster --name eks-production-cluster \
  --query 'cluster.status' --region us-east-1

# Wait for: ACTIVE
```

#### 4.3 Verify Deployment

```bash
# Check all resources created
terraform state list | wc -l
# Should show 38-40 resources

# Verify key resources exist
aws ec2 describe-vpcs --filters "Name=cidr,Values=10.0.0.0/16"
aws eks describe-cluster --name eks-production-cluster
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-xxxxx"
```

### Phase 5: Cluster Access Setup (10 minutes)

#### 5.1 Configure kubectl

```bash
# Get cluster name and region from Terraform
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw aws_region)

# Update kubeconfig
aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME \
  --alias eks-prod

# Verify kubeconfig updated
cat ~/.kube/config | grep $CLUSTER_NAME
```

#### 5.2 Verify Cluster Access

```bash
# Get cluster info
kubectl cluster-info

# List nodes (should show 3 nodes for m5.medium)
kubectl get nodes
kubectl get nodes -o wide

# Check node details
kubectl describe node <node-name>

# Check system pods
kubectl get pods -A

# Expected namespaces:
# - kube-system (system components)
# - kube-public
# - kube-node-lease
# - default
```

#### 5.3 Test Cluster Connectivity

```bash
# Create test deployment
kubectl create deployment hello-world --image=nginx

# Verify deployment
kubectl get deployments
kubectl get pods

# Expose service
kubectl expose deployment hello-world --port=80 --type=LoadBalancer

# Get service info
kubectl get svc hello-world
# Wait for external IP (allocates NLB)

# Cleanup
kubectl delete svc hello-world
kubectl delete deployment hello-world
```

### Phase 6: Post-Deployment Setup (30 minutes)

#### 6.1 Install Essential Add-ons

```bash
# AWS Load Balancer Controller (for ALB/NLB)
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set serviceAccount.create=true

# Metrics Server (for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Cluster Autoscaler
helm repo add autoscaling https://kubernetes.github.io/autoscaler
helm install autoscaler autoscaling/cluster-autoscaler \
  -n kube-system \
  --set autoDiscovery.clusterName=$CLUSTER_NAME
```

#### 6.2 Configure RBAC

```bash
# Create example namespace
kubectl create namespace production

# Create service account with IRSA
kubectl create serviceaccount -n production app-sa

# Create IAM role for IRSA (see Terraform output)
OIDC_ID=$(terraform output -raw oidc_issuer_url | cut -d '/' -f5)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

cat > ~/irsa-trust.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/$OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-east-1.amazonaws.com/id/$OIDC_ID:sub": "system:serviceaccount:production:app-sa"
        }
      }
    }
  ]
}
EOF

# Create IAM role with trust policy
aws iam create-role \
  --role-name eks-app-sa-role \
  --assume-role-policy-document file://~/irsa-trust.json

# Attach policies
aws iam attach-role-policy \
  --role-name eks-app-sa-role \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# Annotate service account
kubectl annotate serviceaccount app-sa \
  -n production \
  eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT_ID:role/eks-app-sa-role
```

#### 6.3 Enable Logging

```bash
# Verify CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix /aws/eks/

# View cluster logs
aws logs tail /aws/eks/eks-production-cluster/cluster --follow

# Check node logs (in web console via Systems Manager Session Manager)
# Or via CloudWatch Agent on nodes
```

#### 6.4 Set Up Monitoring

```bash
# Install Prometheus + Grafana (optional)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --create-namespace

# Or use CloudWatch Container Insights
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name cloudwatch_observability
```

### Phase 7: Verification Checklist

```bash
# Run verification script
cat > verify_eks.sh << 'EOF'
#!/bin/bash
set -e

echo "🔍 EKS Deployment Verification"
echo "================================"

CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw aws_region)

echo "✓ Cluster: $CLUSTER_NAME"
echo "✓ Region: $REGION"

echo ""
echo "Checking VPC..."
VPC_ID=$(terraform output -raw vpc_id)
echo "✓ VPC: $VPC_ID"

echo ""
echo "Checking Subnets..."
SUBNET_COUNT=$(terraform output -json public_subnet_ids | jq length)
echo "✓ Public Subnets: $SUBNET_COUNT"

echo ""
echo "Checking Security Groups..."
SG_CP=$(terraform output -raw eks_control_plane_sg_id)
SG_NODES=$(terraform output -raw eks_nodes_sg_id)
echo "✓ Control Plane SG: $SG_CP"
echo "✓ Nodes SG: $SG_NODES"

echo ""
echo "Checking Cluster..."
CLUSTER_STATUS=$(aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --query 'cluster.status' \
  --output text)
echo "✓ Cluster Status: $CLUSTER_STATUS"

echo ""
echo "Checking Nodes..."
NODE_COUNT=$(kubectl get nodes -o json | jq '.items | length')
echo "✓ Node Count: $NODE_COUNT"

echo ""
echo "Checking System Pods..."
SYSTEM_PODS=$(kubectl get pods -n kube-system -o json | jq '.items | length')
echo "✓ System Pods: $SYSTEM_PODS"

echo ""
echo "✅ All checks passed!"
EOF

chmod +x verify_eks.sh
./verify_eks.sh
```

### Phase 8: Cleanup (When needed)

```bash
# Destroy all resources
terraform destroy

# Confirm by typing "yes"

# Verify cleanup
aws eks describe-cluster --name eks-production-cluster --region us-east-1
# Should show: error (ResourceNotFoundException)
```

---

## Troubleshooting

### Issue: Nodes not joining cluster

```bash
# Solution: Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Check IAM role attachment
aws ec2 describe-instances --filters "Name=tag:aws:eks:cluster-name,Values=$CLUSTER_NAME"

# Check node group status
aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name
```

### Issue: kubectl cannot connect

```bash
# Solution: Update kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Check AWS credentials
aws sts get-caller-identity

# Verify RBAC
kubectl auth can-i get pods --as system:authenticated
```

### Issue: Pod networking issues

```bash
# Check CNI plugin
kubectl get daemonset -n kube-system -l k8s-app=aws-node

# Check security group ingress rules
aws ec2 describe-security-groups --group-ids <nodes-sg-id> \
  --query 'SecurityGroups[0].IpPermissions'
```

---

## Next Steps

1. **Deploy applications** to kubernetes
2. **Set up Ingress Controller** (ALB/NLB)
3. **Configure auto-scaling** (HPA + CA)
4. **Implement monitoring** (Prometheus/Grafana)
5. **Set up CI/CD** (GitOps - ArgoCD)
6. **Configure RBAC** for team access
7. **Enable Pod Security Standards**
8. **Set up backup** (Velero)

---

**Deployment Complete! 🎉**

For more information, see [README.md](README.md)
