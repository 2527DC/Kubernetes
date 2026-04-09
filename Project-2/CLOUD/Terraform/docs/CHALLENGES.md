# 🚧 Challenges & Resolutions - EKS Infrastructure Project

This document outlines all challenges, errors, and issues encountered during the Terraform EKS infrastructure build for Mumbai (ap-south-1) region with practice configurations, and the solutions applied.

---

## 📋 Table of Contents

1. [Configuration Challenges](#configuration-challenges)
2. [Terraform Attribute Errors](#terraform-attribute-errors)
3. [IAM Policy & Security Issues](#iam-policy--security-issues)
4. [Launch Template & Node Group Issues](#launch-template--node-group-issues)
5. [Deployment Duration](#deployment-duration)

---

## Configuration Challenges

### Challenge 1: Incorrect Region & Availability Zones

**Issue:** Default configuration was set to `us-east-1` (US East) instead of `ap-south-1` (Mumbai).

**Error:** N/A — Configuration issue caught before deployment.

**Root Cause:** Template defaults were for US region; practice setup needed Mumbai AZs.

**Resolution:**

- Changed `aws_region` in `variables.tf` from `us-east-1` → `ap-south-1`
- Updated `availability_zones` from `["us-east-1a", "us-east-1b"]` → `["ap-south-1a", "ap-south-1b"]`
- Updated `terraform.tfvars` to match

**Files Modified:**

- `variables.tf`
- `terraform.tfvars`

---

### Challenge 2: Node Scaling Configuration Mismatch

**Issue:** Default node group scaling was too large for practice (min=2, max=5, desired=3).

**Error:** N/A — Optimization, not an error.

**Root Cause:** Template configured for production, not learning/practice.

**Resolution:**

- Changed node sizing:
  - `node_min_size`: `2` → `1`
  - `node_max_size`: `5` → `1`
  - `node_desired_size`: `3` → `1`
- Applied to both `variables.tf` and module defaults

**Files Modified:**

- `variables.tf`
- `module/node_groups/variables.tf`
- `terraform.tfvars`

---

### Challenge 3: Instance Type Configuration

**Issue:** Instance type needed to be `t2.micro` for minimal cost in practice, but was configured as families (`t3`, `t3a`) expecting `.medium` suffix.

**Error:** Invalid instance types like `t2.micro.medium` would be generated.

**Root Cause:** Vehicle mistaken between instance families (e.g., `t3`) and specific instance types (e.g., `t2.micro`).

**Resolution:**

- Updated `instance_families` variable to store exact instance types: `["t2.micro"]`
- Changed `node_instance_families` in `variables.tf` and module
- Removed `.medium` suffix appending logic in `module/node_groups/main.tf`
- Changed from: `instance_types = [for family in var.instance_families : "${family}.medium"]`
- Changed to: `instance_types = var.instance_families`

**Files Modified:**

- `variables.tf`
- `module/node_groups/variables.tf`
- `module/node_groups/main.tf`
- `terraform.tfvars`

---

### Challenge 4: EBS Volume Size Configuration

**Issue:** Needed 20 GiB for practice instead of 100 GiB (to reduce costs).

**Error:** N/A — Configuration optimization.

**Resolution:**

- Updated `node_disk_size` from `100` → `20` in:
  - `variables.tf`
  - `module/node_groups/variables.tf`
  - `terraform.tfvars`

**Files Modified:**

- `variables.tf`
- `module/node_groups/variables.tf`
- `terraform.tfvars`

---

### Challenge 5: NAT Gateway Removal

**Issue:** NAT Gateway adds cost; wanted to disable it for practice.

**Error:** ❌ **Unsupported attribute error** when trying to disable.

**Error Message:**

```
Error: Invalid index

on module/vpc/main.tf line 126, in resource "aws_route_table" "private":
  126:     nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    ├────────────────
    │ aws_nat_gateway.main is empty tuple
```

**Root Cause:** Private route table always tried to reference NAT Gateway even when `enable_nat_gateway = false`, causing index errors on empty list.

**Resolution:**

- Changed `enable_nat_gateway` from `true` → `false` in `terraform.tfvars`
- Separated NAT route into conditional `aws_route` resource in `module/vpc/main.tf`
- Route only created when `var.enable_nat_gateway = true`
- Changed from inline `route { ... }` block to:
  ```hcl
  resource "aws_route" "private_nat" {
    count = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0
    ...
  }
  ```

**Files Modified:**

- `terraform.tfvars`
- `module/vpc/main.tf`

---

## Terraform Attribute Errors

### Challenge 6: Invalid Launch Template Version Attribute

**Issue:** Launch template version attribute name was incorrect.

**Error:** ❌

```
Error: Unsupported attribute

on module/node_groups/main.tf line 82, in resource "aws_eks_node_group" "main":
  82:     version = aws_launch_template.eks_nodes.latest_version_number

This object has no argument, nested block, or exported attribute named "latest_version_number".
```

**Root Cause:** AWS Terraform provider exports `latest_version`, not `latest_version_number`.

**Resolution:**

- Changed attribute from `latest_version_number` → `latest_version`
- Line 82 in `module/node_groups/main.tf`

**Files Modified:**

- `module/node_groups/main.tf`

---

### Challenge 7: Incorrect ASG Tags Data Source

**Issue:** EKS node group data source attribute path was wrong.

**Error:** ❌

```
Error: Unsupported attribute

on module/node_groups/main.tf line 159, in resource "aws_autoscaling_group_tag":
  159:   for_each = data.aws_eks_node_group.node_group.asg_tags

This object does not have an attribute named "asg_tags".
```

**Root Cause:** EKS managed node groups don't expose `asg_tags` directly; AWS manages ASG internally.

**Resolution:**

- Removed non-functional `aws_autoscaling_group_tag` resource entirely
- Removed `data.aws_eks_node_group` data source (unnecessary)
- Changed output from `asg_tags[0].autoscaling_group_name` to simple `node_group_name`
- Output now: `aws_eks_node_group.main.node_group_name`

**Files Modified:**

- `module/node_groups/main.tf` (removed ASG tag loop & data source)
- `module/node_groups/outputs.tf` (simplified output)

---

## IAM Policy & Security Issues

### Challenge 8: Invalid IAM Policy ARN

**Issue:** ❌

```
Error: attaching IAM Policy (arn:aws:iam::aws:policy/AmazonEK_CNI_Policy) to IAM Role:
operation error IAM: AttachRolePolicy, https response error StatusCode: 404, RequestID: ...,
NoSuchEntity: Policy arn:aws:iam::aws:policy/AmazonEK_CNI_Policy does not exist or is not attachable.
```

**Root Cause:** Policy name typo: `AmazonEK_CNI_Policy` (missing `S` in `EKS`).

**Resolution:**

- Corrected policy ARN from `AmazonEK_CNI_Policy` → `AmazonEKS_CNI_Policy`
- Line 34 in `module/node_groups/main.tf`

**Files Modified:**

- `module/node_groups/main.tf`

---

### Challenge 9: Security Group Port Configuration Conflict

**Issue:** ❌

```
Error: updating VPC Security Group Rule

operation error EC2: ModifySecurityGroupRules, https response error StatusCode: 400,
InvalidParameterValue: You may not specify all protocols and specific ports.
Please specify each protocol and port ranges individually, or all protocols and no port range.
```

**Root Cause:** Security group egress rules used `ip_protocol = "-1"` (all protocols) WITH `from_port = 0, to_port = 0`, which is invalid. AWS requires:

- Either: `-1` (all protocols) WITHOUT port ranges
- Or: Specific protocol WITH specific ports

**Resolution:**

- Removed `from_port` and `to_port` from all-protocols (`-1`) rules
- Applied to both:
  - `aws_vpc_security_group_egress_rule` for EKS control plane
  - `aws_vpc_security_group_egress_rule` for EKS nodes

**Before:**

```hcl
ip_protocol = "-1"
from_port   = 0
to_port     = 0
```

**After:**

```hcl
ip_protocol = "-1"
# from_port and to_port removed
```

**Files Modified:**

- `module/security_groups/main.tf`

---

## Launch Template & Node Group Issues

### Challenge 10: Duplicate Disk Size Configuration

**Issue:** ❌

```
Error: creating EKS Node Group:
operation error EKS: CreateNodegroup, https response error StatusCode: 400,
InvalidParameterException: Disk size must be specified within the launch template.
```

**Root Cause:** Disk size was specified in TWO places:

1. In `aws_launch_template.eks_nodes` (correct location)
2. In `aws_eks_node_group.main` as `disk_size = var.disk_size` (conflicts)

AWS EKS requires disk size ONLY in launch template when launch template is used.

**Resolution:**

- Removed `disk_size = var.disk_size` from `aws_eks_node_group` resource
- Kept disk size ONLY in `aws_launch_template.eks_nodes` under `block_device_mappings`

**Files Modified:**

- `module/node_groups/main.tf`

---

### Challenge 11: Invalid User Data Format

**Issue:** ❌

```
Error: waiting for EKS Node Group create:
unexpected state 'CREATE_FAILED', wanted target 'ACTIVE'.
last error: Ec2LaunchTemplateInvalidConfiguration: User data was not in the MIME multipart format.
```

**Root Cause:** AWS EKS launch templates require user data in MIME multipart format, not raw base64.

**Resolution:**

- Changed user data from simple shell script encoding to MIME multipart format
- Format includes proper MIME headers:

  ```
  MIME-Version: 1.0
  Content-Type: multipart/mixed; boundary="==BOUNDARY=="

  --==BOUNDARY==
  Content-Type: text/x-shellscript; charset="us-ascii"

  #!/bin/bash
  # ... script content ...

  --==BOUNDARY==--
  ```

**Files Modified:**

- `module/node_groups/main.tf`

---

## Deployment Duration

### Challenge 12: Long Deployment Time (15–25 minutes)

**Issue:** Terraform `terraform apply` takes extended time to reach `ACTIVE` state.

**Expected Behavior:** Normal — not an error.

**Root Cause:** EKS node group creation involves:

1. EC2 instance launch (~5–10 min)
2. EKS bootstrap process (~10–15 min)
3. Kubelet startup and CNI initialization (~5–10 min)

**Resolution:** This is expected behavior. No code changes needed. Monitoring logs:

```bash
aws eks describe-nodegroup \
  --cluster-name eks-production-cluster \
  --nodegroup-name eks-production-cluster-primary-ng \
  --region ap-south-1
```

---

## Summary Table

| #   | Challenge                 | Error Type | Resolution                                 |
| --- | ------------------------- | ---------- | ------------------------------------------ |
| 1   | Wrong region              | Config     | Changed `us-east-1` → `ap-south-1`         |
| 2   | Over-scaled nodes         | Config     | Set min/max/desired to 1                   |
| 3   | Instance type format      | Config     | Use exact type (`t2.micro`) not family     |
| 4   | Oversized EBS             | Config     | Set disk from 100 → 20 GiB                 |
| 5   | NAT Gateway errors        | Terraform  | Made NAT route conditional                 |
| 6   | Launch template attribute | Terraform  | `latest_version_number` → `latest_version` |
| 7   | ASG tags not available    | Terraform  | Removed unused ASG tag resource            |
| 8   | Invalid IAM policy        | AWS API    | Policy name typo fixed                     |
| 9   | Security group ports      | AWS API    | Removed ports from all-protocols rule      |
| 10  | Disk size conflict        | EKS API    | Removed disk from node group, kept in LT   |
| 11  | User data format          | EKS API    | Wrapped in MIME multipart format           |
| 12  | Slow deployment           | N/A        | Normal 15–25 min duration                  |

---

## Key Learnings

1. **Region-specific configurations** must align with correct availability zones
2. **AWS EKS with launch templates** require disk size ONLY in template, not node group
3. **User data in launch templates** must be MIME multipart format
4. **Security group rules** with all-protocols flag (`-1`) cannot have specific port ranges
5. **Conditional resources** in Terraform prevent index errors on empty collections
6. **IAM policy names** are case-sensitive and version-dependent

---

## Files Affected During Resolution

- `variables.tf`
- `terraform.tfvars`
- `module/vpc/main.tf`
- `module/node_groups/main.tf`
- `module/node_groups/variables.tf`
- `module/node_groups/outputs.tf`
- `module/security_groups/main.tf`

---

## Testing & Validation

✅ `terraform plan` passes without errors  
✅ `terraform apply` initiates successfully  
✅ EKS cluster and node group creation proceeds  
✅ All security group rules valid  
✅ IAM policies correctly attached

---

_Last Updated: April 8, 2026_  
_Configuration: Mumbai (ap-south-1) | 1x t2.micro node | 20 GiB EBS | Practice Setup_
