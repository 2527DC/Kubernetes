# Complete EKS Infrastructure Project - Summary & Best Practices

## 📦 What Has Been Created

This is a **production-grade, modular Terraform project** for deploying AWS EKS clusters with complete networking, security, and auto-scaling capability.

### ✅ Complete Infrastructure Includes:

#### 1. **VPC & Networking Module** ✓

- Single VPC with configurable CIDR (default: 10.0.0.0/16)
- **2 Public Subnets** (different AZs) for Load Balancers and NAT
- **2 Private Subnets** (different AZs) for EKS nodes
- **Internet Gateway** for external traffic
- **NAT Gateway(s)** for private subnet outbound access
- **Route Tables** with proper routing rules
- Kubernetes tags for AWS Load Balancer Controller discovery

#### 2. **Security Groups Module** ✓

**Creates 2 Security Groups (as required):**

1. **EKS Control Plane SG**
   - HTTPS (443) from allowed CIDRs
   - Kubelet API (1025-65535) from worker nodes
   - All outbound traffic

2. **EKS Node SG**
   - Communication with control plane
   - Node-to-node communication
   - VPC internal traffic
   - All outbound traffic

#### 3. **EKS Cluster Module** ✓

- Manual configuration (NO auto mode)
- Manual selection of security groups ✓
- Manual networking specification ✓
- Kubernetes 1.29 (configurable)
- CloudWatch logging (all 5 types)
- KMS encryption for secrets
- OIDC provider for IRSA
- Proper IAM roles & policies

#### 4. **Node Groups Module** ✓

- Configurable min/max/desired node counts ✓
- **Configurable instance families** (t3, t3a, m5, c5, etc.) ✓
- Launch template for advanced configuration
- Auto Scaling Group with proper tagging
- 100GB encrypted EBS volumes
- IAM roles for all necessary permissions
- **No separate EC2 creation** - nodes managed via EKS Node Groups ✓
- CloudWatch monitoring enabled

### 📁 Project Structure

```
CLOUD/Terraform/
├── main.tf                          # Root orchestration
├── variables.tf                     # Root variables (all inputs)
├── outputs.tf                       # Root outputs
├── provider.tf                      # AWS provider
├── terraform.tfvars                 # Example values
├── .gitignore                       # Git ignore patterns
│
├── README.md                        # Complete documentation
├── DEPLOYMENT_GUIDE.md              # Step-by-step deployment
├── ARCHITECTURE.md                  # Visual diagrams & architecture
├── MULTI_CLUSTER_STRATEGY.md        # Answer to your question
│
└── module/
    ├── vpc/
    │   ├── main.tf                  # VPC infrastructure
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security_groups/
    │   ├── main.tf                  # 2 security groups
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── eks_cluster/
    │   ├── main.tf                  # EKS cluster & OIDC
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── node_groups/
        ├── main.tf                  # Node groups & IAM
        ├── variables.tf
        ├── user_data.sh             # Node bootstrap script
        └── outputs.tf
```

## ❓ ANSWER TO YOUR QUESTION: Multiple Cluster Specification

### **Question:**

"If I need to create a cluster with different specifications, is it best to use a different project or use the same project by updating it for different providers?"

### **Answer: Use the SAME project structure with environment-based tfvars** ✅

---

## 🎯 Strategy: Environment-Based Configuration (Recommended)

### Why This Approach?

```
✅ DRY Principle              - Code written once, used for all environments
✅ Consistency               - All clusters use same, tested code
✅ Easy Maintenance          - Fix bugs once, applies to all clusters
✅ Version Control           - Single source of truth in Git
✅ Cost Efficiency           - No duplicate code repositories
✅ Scaling Operations        - Simple to add new environments
❌ No code duplication       - Avoids copy-paste errors
```

### Implementation

#### Option 1: Single Project, Multiple tfvars Files

```
Terraform/
├── main.tf
├── variables.tf
├── provider.tf
│
├── prod.tfvars                     ← Different config
├── staging.tfvars                  ← Different config
└── dev.tfvars                      ← Different config
```

**Deploy:**

```bash
# Production
terraform apply -var-file="prod.tfvars"

# Staging
terraform apply -var-file="staging.tfvars"

# Development
terraform apply -var-file="dev.tfvars"
```

#### Option 2: Environment-Based Directory Structure

```
Terraform/
├── main.tf
├── variables.tf
├── provider.tf
├── module/
│   └── (shared modules)
│
└── environments/
    ├── prod/
    │   └── prod.tfvars
    ├── staging/
    │   └── staging.tfvars
    └── dev/
        └── dev.tfvars
```

**Deploy:**

```bash
terraform apply -var-file="environments/prod/prod.tfvars"
terraform apply -var-file="environments/staging/staging.tfvars"
terraform apply -var-file="environments/dev/dev.tfvars"
```

#### Option 3: Terraform Workspaces

```bash
# Create workspaces
terraform workspace new prod
terraform workspace new staging
terraform workspace new dev

# Deploy
terraform workspace select prod
terraform apply -var-file="prod.tfvars"

terraform workspace select staging
terraform apply -var-file="staging.tfvars"
```

---

## 📊 Example: Different Cluster Specifications

### Production Cluster

```hcl
# prod.tfvars
aws_region = "us-east-1"
project_name = "eks-production"
environment = "prod"

# HA Configuration
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
single_nat_gateway = false  # NAT per AZ for HA

# Robust Nodes
node_min_size = 3
node_desired_size = 5
node_max_size = 10
node_instance_families = ["m5", "m6i"]  # Memory optimized
node_disk_size = 200  # Larger for production

# Security
allowed_inbound_cidrs = ["203.0.113.0/24"]  # Corporate VPN
```

### Staging Cluster

```hcl
# staging.tfvars
aws_region = "us-east-1"
project_name = "eks-staging"
environment = "staging"

# Balanced Configuration
availability_zones = ["us-east-1a", "us-east-1b"]
single_nat_gateway = true  # Cost optimization

# Moderate Nodes
node_min_size = 2
node_desired_size = 3
node_max_size = 6
node_instance_families = ["t3", "t3a"]  # General purpose
node_disk_size = 100

# More permissive
allowed_inbound_cidrs = ["0.0.0.0/0"]
```

### Development Cluster

```hcl
# dev.tfvars
aws_region = "us-east-1"
project_name = "eks-dev"
environment = "dev"

# Cost-optimized Configuration
availability_zones = ["us-east-1a", "us-east-1b"]
single_nat_gateway = true  # Single NAT

# Minimal Nodes
node_min_size = 1
node_desired_size = 2
node_max_size = 3
node_instance_families = ["t3"]  # Cheap option
node_disk_size = 50  # Minimal

# Open access for debugging
allowed_inbound_cidrs = ["0.0.0.0/0"]
```

---

## 🔄 Managing Multiple Clusters

### Scenario 1: Same Region, Different Clusters

```bash
# Production in us-east-1
terraform apply -var-file="prod.tfvars"
# Creates: eks-production-cluster, VPC 10.0.0.0/16

# Staging in us-east-1 (SAME region, different VPC CIDR)
# Modify prod.tfvars → staging.tfvars with different VPC_CIDR
terraform apply -var-file="staging.tfvars"
# Creates: eks-staging-cluster, VPC 10.1.0.0/16

# Dev in us-east-1 (SAME region, different VPC CIDR)
terraform apply -var-file="dev.tfvars"
# Creates: eks-dev-cluster, VPC 10.2.0.0/16
```

### Scenario 2: Multi-Region Deployment

```bash
# Update provider for each region
# Method A: Use provider alias
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

# Method B: Use separate terraforms per region
# Region 1
cd terraform-us-east-1/
terraform apply -var-file="prod.tfvars"

# Region 2
cd ../terraform-eu-west-1/
terraform apply -var-file="prod.tfvars"
```

### Scenario 3: Multiple AWS Accounts

```bash
# Account 1 (Production)
export AWS_PROFILE=production-account
terraform apply -var-file="prod.tfvars"

# Account 2 (Staging)
export AWS_PROFILE=staging-account
terraform apply -var-file="staging.tfvars"

# Account 3 (Development)
export AWS_PROFILE=dev-account
terraform apply -var-file="dev.tfvars"
```

---

## ❌ Why NOT Separate Projects?

### Problem: Code Duplication

```
Project 1: eks-prod/
├── main.tf (300 lines)
├── variables.tf
├── module/ (vpc/, security_groups/, eks_cluster/, node_groups/)
└── ... (all configuration)

Project 2: eks-staging/
├── main.tf (300 lines - DUPLICATE) ❌
├── variables.tf
├── module/ (vpc/, security_groups/, eks_cluster/, node_groups/) ❌ DUPLICATE
└── ... (all configuration - DUPLICATE)

Project 3: eks-dev/
├── main.tf (300 lines - DUPLICATE) ❌
├── variables.tf
├── module/ (vpc/, security_groups/, eks_cluster/, node_groups/) ❌ DUPLICATE
└── ... (all configuration - DUPLICATE)

Total Lines of Code: 900+ (should be 300)
```

### Problems This Creates:

1. **Maintenance Nightmare**
   - Fix a bug? Fix it 3 times
   - Security patch? Apply it 3 times
   - New feature? Implement 3 times

2. **Consistency Issues**
   - Accidentally use different module version
   - Different security settings
   - Hard to track which projects are out of sync

3. **Storage & Repository Bloat**
   - 3x code size
   - 3 Git repositories
   - 3x state files to manage

4. **Operational Overhead**
   - More complex CI/CD
   - Harder to onboard team members
   - More places to make mistakes

---

## ✅ Single Project with Variables (DRY)

```
Terraform/ (Single project)
├── main.tf (300 lines) ← Used for ALL clusters
├── variables.tf
├── module/ ← Used for ALL clusters
│   ├── vpc/
│   ├── security_groups/
│   ├── eks_cluster/
│   └── node_groups/
│
├── prod.tfvars     ← Different values
├── staging.tfvars  ← Different values
└── dev.tfvars      ← Different values

Total Lines of Code: 300 + 50 + 50 + 50 = 450 (minimal!)
Benefits: -50% code, easier maintenance, consistent
```

---

## 🚀 Recommended Folder Structure for Your Use Case

### Setup for managing 3+ environments:

```
Project-2/
├── CLOUD/
│   ├── k8s/
│   │   ├── Deployment.md
│   │   └── (k8s manifests)
│   │
│   ├── Terraform/
│   │   ├── main.tf               ← Core logic (unchanged)
│   │   ├── variables.tf          ← Input variables
│   │   ├── outputs.tf            ← Output values
│   │   ├── provider.tf           ← AWS provider
│   │   ├── .gitignore
│   │   ├── README.md             ← Comprehensive docs
│   │   ├── DEPLOYMENT_GUIDE.md   ← Step-by-step guide
│   │   ├── ARCHITECTURE.md       ← Visual diagrams
│   │   │
│   │   ├── module/               ← Reusable modules
│   │   │   ├── vpc/
│   │   │   ├── security_groups/
│   │   │   ├── eks_cluster/
│   │   │   └── node_groups/
│   │   │
│   │   └── environments/         ← Environment configs
│   │       ├── prod.tfvars       ← Production config
│   │       ├── staging.tfvars    ← Staging config
│   │       └── dev.tfvars        ← Dev config
│   │
│   └── LOCAL/ (deprecated, use k8s/)
│       └── (local k8s manifests)
│
└── (other project folders)
```

### Deploy to different environments:

```bash
cd CLOUD/Terraform

# Production
terraform apply -var-file="environments/prod.tfvars"

# Staging
terraform apply -var-file="environments/staging.tfvars"

# Development
terraform apply -var-file="environments/dev.tfvars"
```

---

## 📋 Checklist: Single Project Setup

- [ ] Create `/environments/` directory
- [ ] Create `prod.tfvars`, `staging.tfvars`, `dev.tfvars`
- [ ] Set appropriate values for each environment
- [ ] Initialize Terraform: `terraform init`
- [ ] Validate: `terraform validate`
- [ ] Plan for each: `terraform plan -var-file="environments/prod.tfvars"`
- [ ] Apply to production first: `terraform apply -var-file="environments/prod.tfvars"`
- [ ] Then staging: `terraform apply -var-file="environments/staging.tfvars"`
- [ ] Finally dev: `terraform apply -var-file="environments/dev.tfvars"`

---

## 📊 Comparison: Single Project vs Separate Projects

| Aspect               | Single Project     | Separate Projects      |
| -------------------- | ------------------ | ---------------------- |
| **Code Duplication** | ✅ None            | ❌ 100%                |
| **Maintenance**      | ✅ Easy (fix once) | ❌ Hard (fix 3x)       |
| **Consistency**      | ✅ Guaranteed      | ❌ Manual effort       |
| **Storage**          | ✅ ~450 lines      | ❌ ~1350 lines         |
| **Version Control**  | ✅ 1 repo          | ❌ 3 repos             |
| **Team Onboarding**  | ✅ Simple          | ❌ Complex             |
| **CI/CD Complexity** | ✅ Low             | ❌ High                |
| **Cost**             | ✅ Lower           | ❌ Higher (more state) |
| **Security Updates** | ✅ Apply once      | ❌ Apply 3x            |
| **Scalability**      | ✅ Easy to add env | ❌ Add whole project   |

---

## 🎓 Next Steps

### 1. Organize Environment Configurations

```bash
mkdir -p CLOUD/Terraform/environments
cp CLOUD/Terraform/terraform.tfvars CLOUD/Terraform/environments/prod.tfvars
cp CLOUD/Terraform/terraform.tfvars CLOUD/Terraform/environments/staging.tfvars
cp CLOUD/Terraform/terraform.tfvars CLOUD/Terraform/environments/dev.tfvars
```

### 2. Customize Each Environment

Edit each tfvars file with appropriate values

### 3. Deploy to Production First

```bash
cd CLOUD/Terraform
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

### 4. Then Deploy to Other Environments

```bash
terraform apply -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

### 5. Add CI/CD Pipeline (GitLab/GitHub Actions)

```yaml
# Example GitHub Actions workflow
deploy:
  stage: apply
  script:
    - terraform init
    - terraform apply -var-file="environments/$ENV.tfvars" -auto-approve
  only:
    - main
```

---

## 📚 Documentation Included

1. **README.md** - Complete project documentation
2. **DEPLOYMENT_GUIDE.md** - Step-by-step deployment instructions
3. **ARCHITECTURE.md** - Visual diagrams and architecture
4. **This file** - Multi-cluster strategy and best practices

---

## ✨ Key Takeaways

1. **This is NOT auto mode** - Manual control over all security groups and networking ✅
2. **2 Security Groups** - Control Plane + Nodes (as required) ✅
3. **Configurable Node Count** - Min/Max/Desired via variables ✅
4. **Configurable Instance Families** - t3, t3a, m5, c5, etc. ✅
5. **Modular Design** - Reusable across different clusters ✅
6. **Production Ready** - KMS encryption, logging, OIDC, HA ✅
7. **Use ONE project** - With multiple tfvars for different environments ✅

---

## 🎉 You're Ready to Deploy!

```bash
cd /Users/admin/Desktop/Learning/Kubernetes/Project-2/CLOUD/Terraform

# Initialize
terraform init

# Review
terraform plan -var-file="terraform.tfvars"

# Deploy
terraform apply -var-file="terraform.tfvars"

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name eks-production-cluster

# Verify
kubectl get nodes
```

**Happy Kubernetes deployment! 🚀**
