# EKS Infrastructure Architecture

## Visual Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               AWS REGION: us-east-1                             │
│                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                    VPC: 10.0.0.0/16                                      │  │
│  │                                                                          │  │
│  │  ┌─────────────────────────────────────┐  ┌─────────────────────────┐  │  │
│  │  │      Availability Zone: us-east-1a  │  │  AZ: us-east-1b         │  │  │
│  │  │                                     │  │                         │  │  │
│  │  │  ┌─────────────────────────────┐    │  │  ┌─────────────────┐    │  │  │
│  │  │  │  Public Subnet              │    │  │  │ Public Subnet   │    │  │  │
│  │  │  │  CIDR: 10.0.1.0/24          │    │  │  │ 10.0.2.0/24     │    │  │  │
│  │  │  │                             │    │  │  │                 │    │  │  │
│  │  │  │ ┌─────────────────────────┐ │    │  │  │ ┌─────────────┐ │    │  │  │
│  │  │  │ │ NAT Gateway             │ │    │  │  │ │ NAT Gateway │ │    │  │  │
│  │  │  │ │ (for private -> IGW)    │ │    │  │  │ │  (standby)  │ │    │  │  │
│  │  │  │ └─────────────────────────┘ │    │  │  │ └─────────────┘ │    │  │  │
│  │  │  │                             │    │  │  │                 │    │  │  │
│  │  │  │ ┌─────────────────────────┐ │    │  │  │ ┌──────────────┐│    │  │  │
│  │  │  │ │   Load Balancer         │ │    │  │  │ │ Load Balancer││    │  │  │
│  │  │  │ │   (ALB/NLB)             │ │    │  │  │ │ (ALB/NLB)    ││    │  │  │
│  │  │  │ └─────────────────────────┘ │    │  │  │ └──────────────┘│    │  │  │
│  │  │  └─────────────────────────────┘    │  │  └─────────────────┘    │  │  │
│  │  │          ▲                          │  │         ▲                │  │  │
│  │  │          │ (Internet Traffic)       │  │         │ (Internet)    │  │  │
│  │  │          └──────────────────────────┴──┴─────────┘                │  │  │
│  │  │                     Internet Gateway (IGW)                         │  │  │
│  │  │                                                                    │  │  │
│  │  │  ┌────────────────────────────────────────────────────────────┐   │  │  │
│  │  │  │           PRIVATE SUBNETS (EKS NODES)                     │   │  │  │
│  │  │  │                                                           │   │  │  │
│  │  │  │ ┌──────────────────────────┐  ┌──────────────────────┐   │   │  │  │
│  │  │  │ │ Private Subnet: AZ-1a    │  │ Private Subnet: AZ-1b│   │   │  │  │
│  │  │  │ │ CIDR: 10.0.10.0/24        │  │ CIDR: 10.0.11.0/24   │   │   │  │  │
│  │  │  │ │                          │  │                      │   │   │  │  │
│  │  │  │ │ ┌──────────────────────┐ │  │ ┌──────────────────┐ │   │   │  │  │
│  │  │  │ │ │   EKS Node Group     │ │  │ │ EKS Node Group   │ │   │   │  │  │
│  │  │  │ │ │   (Min 1 node)       │ │  │ │ (Min 1 node)     │ │   │   │  │  │
│  │  │  │ │ │                      │ │  │ │                  │ │   │   │  │  │
│  │  │  │ │ │ ┌────────────────┐   │ │  │ │ ┌──────────────┐ │ │   │   │  │  │
│  │  │  │ │ │ │ EC2 Instance   │   │ │  │ │ │ EC2 Instance │ │ │   │   │  │  │
│  │  │  │ │ │ │ t3.medium/m5   │   │ │  │ │ │ t3.medium/m5 │ │ │   │   │  │  │
│  │  │  │ │ │ │ 100GB EBS       │   │ │  │ │ │ 100GB EBS    │ │ │   │   │  │  │
│  │  │  │ │ │ └────────────────┘   │ │  │ │ └──────────────┘ │ │   │   │  │  │
│  │  │  │ │ │                      │ │  │ │ ... (replicated) │ │   │   │  │  │
│  │  │  │ │ └──────────────────────┘ │  │ └──────────────────┘ │   │   │  │  │
│  │  │  │ └──────────────────────────┘  └──────────────────────┘   │   │  │  │
│  │  │  │                                                           │   │  │  │
│  │  │  │  ▲    Pod Communication (10.0.0.0/16)    ▲               │   │  │  │
│  │  │  │  │    ← Service-to-Service Communication → │               │   │  │  │
│  │  │  │  └───────────────────────────────────────┘               │   │  │  │
│  │  │  └────────────────────────────────────────────────────────────┘   │  │  │
│  │  │                                                                    │  │  │
│  │  │         ┌──────────────────────────────────────────────┐          │  │  │
│  │  │         │   EKS Control Plane (Managed by AWS)         │          │  │  │
│  │  │         │                                              │          │  │  │
│  │  │         │  - API Server (kube-apiserver)              │          │  │  │
│  │  │         │  - Scheduler (kube-scheduler)                │          │  │  │
│  │  │         │  - Controller Manager (kube-controller-mgr) │          │  │  │
│  │  │         │  - etcd (Encrypted with KMS)                │          │  │  │
│  │  │         │  - CloudWatch Logs (audit, api, auth)       │          │  │  │
│  │  │         │                                              │          │  │  │
│  │  │         │  ENDPOINT: https://xxxxx.eks.amazonaws.com  │          │  │  │
│  │  │         └──────────────────────────────────────────────┘          │  │  │
│  │  └──────────────────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │  │
│                                                                             │  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │  │
│  │                      SECURITY GROUPS (2)                           │  │  │
│  │                                                                    │  │  │
│  │  ┌──────────────────────────────────────────────────────────────┐ │  │  │
│  │  │  SG #1: EKS Control Plane Security Group                      │ │  │  │
│  │  │  ─────────────────────────────────────────────               │ │  │  │
│  │  │  Ingress:                                                     │ │  │  │
│  │  │    - HTTPS (443) from allowed_inbound_cidrs                 │ │  │  │
│  │  │    - TCP (1025-65535) from Node Security Group              │ │  │  │
│  │  │  Egress:                                                      │ │  │  │
│  │  │    - All traffic (0.0.0.0/0)                                │ │  │  │
│  │  └──────────────────────────────────────────────────────────────┘ │  │  │
│  │                                                                    │  │  │
│  │  ┌──────────────────────────────────────────────────────────────┐ │  │  │
│  │  │  SG #2: EKS Node Security Group                              │ │  │  │
│  │  │  ──────────────────────────────────────────                 │ │  │  │
│  │  │  Ingress:                                                     │ │  │  │
│  │  │    - TCP (1025-65535) from Control Plane SG                 │ │  │  │
│  │  │    - All TCP traffic from Node SG (self)                    │ │  │  │
│  │  │    - All TCP (0-65535) from VPC CIDR (10.0.0.0/16)         │ │  │  │
│  │  │  Egress:                                                      │ │  │  │
│  │  │    - All traffic (0.0.0.0/0)                                │ │  │  │
│  │  └──────────────────────────────────────────────────────────────┘ │  │  │
│  └────────────────────────────────────────────────────────────────────┘  │  │
│                                                                             │  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │  │
│  │                    TERRAFORM MODULES                               │  │  │
│  │                                                                    │  │  │
│  │  1. VPC Module → VPC, Subnets, IGW, NAT, Route Tables           │  │  │
│  │  2. Security Groups Module → 2 SGs with correct rules           │  │  │
│  │  3. EKS Cluster Module → Cluster, OIDC, KMS Encryption         │  │  │
│  │  4. Node Groups Module → Node Group, IAM, Launch Template       │  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │  │
│                                                                             │  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Layer-by-Layer Architecture

### Layer 1: VPC & Networking

```
Region: us-east-1
├── VPC (10.0.0.0/16)
│   ├── Internet Gateway (IGW)
│   │   └── Allows external traffic
│   │
│   ├── Public Subnets (2 AZs)
│   │   ├── 10.0.1.0/24 (us-east-1a)
│   │   │   └── NAT Gateway + Elastic IP
│   │   └── 10.0.2.0/24 (us-east-1b)
│   │       └── NAT Gateway + Elastic IP (optional)
│   │
│   ├── Private Subnets (2 AZs) ← EKS Nodes here
│   │   ├── 10.0.10.0/24 (us-east-1a)
│   │   │   └── Route: 0.0.0.0/0 → NAT Gateway
│   │   └── 10.0.11.0/24 (us-east-1b)
│   │       └── Route: 0.0.0.0/0 → NAT Gateway
│   │
│   └── Route Tables
│       ├── Public: Local + IGW
│       ├── Private-1: Local + NAT-1
│       └── Private-2: Local + NAT-2

Traffic Flow:
  External (Internet)
         ↓
   Internet Gateway
         ↓
   Public Subnets
         ↓
   NAT Gateway ← Private Subnet outbound traffic
         ↓
   Public Subnet (back to IGW)
         ↓
   Internet
```

### Layer 2: Security

```
Security Groups (2 Required)

┌─────────────────────────────────────────────────────────┐
│  SG #1: EKS Control Plane                               │
│  ─────────────────────────                              │
│  Ingress Rules:                                         │
│  • 443/tcp from allowed_inbound_cidrs (HTTPS)         │
│  • 1025-65535/tcp from SG #2 (kubelet API)            │
│                                                         │
│  Egress Rules:                                          │
│  • 0/0 (anywhere)                                      │
└─────────────────────────────────────────────────────────┘
                         ▲
                         │ Communication
                         ▼
┌─────────────────────────────────────────────────────────┐
│  SG #2: EKS Worker Nodes                                │
│  ────────────────────────                              │
│  Ingress Rules:                                         │
│  • 1025-65535/tcp from SG #1 (CP commands)            │
│  • All TCP from SG #2 (node-to-node)                  │
│  • All TCP (0-65535) from VPC CIDR (pod traffic)      │
│                                                         │
│  Egress Rules:                                          │
│  • 0/0 (anywhere)                                      │
└─────────────────────────────────────────────────────────┘

IAM Roles & Policies:
  ├── EKS Cluster Role
  │   ├── AmazonEKSClusterPolicy
  │   └── AmazonEKSVPCResourceController
  │
  └── EKS Node Role
      ├── AmazonEKSWorkerNodePolicy
      ├── AmazonEK_CNI_Policy
      ├── AmazonEC2ContainerRegistryReadOnly
      └── AmazonSSMManagedInstanceCore
```

### Layer 3: EKS Control Plane

```
EKS Cluster: eks-production-cluster
├── Kubernetes Version: 1.29
├── Status: ACTIVE
├── Endpoint: https://xxxxx.eks.us-east-1.amazonaws.com
│
├── Control Plane Components (Managed by AWS)
│   ├── API Server (kube-apiserver)
│   ├── Scheduler (kube-scheduler)
│   ├── Controller Manager (kube-controller-mgr)
│   ├── etcd (Encrypted with KMS)
│   └── Cloud Controller Manager
│
├── Networking
│   ├── VPC: vpc-xxxxx
│   ├── Subnets: [public-1, public-2, private-1, private-2]
│   └── Security Groups: [SG #1 (control plane)]
│
├── Logging (CloudWatch)
│   ├── API Server logs (audit)
│   ├── Authenticator logs
│   ├── Controller Manager logs
│   ├── Scheduler logs
│   └── Retention: 30 days
│
├── Encryption
│   ├── KMS Key: alias/eks-production-cluster
│   └── Encrypted: Secrets (etcd)
│
└── OIDC Provider (for IRSA)
    └── URL: https://oidc.eks.us-east-1.amazonaws.com/id/xxxxx
```

### Layer 4: Node Groups (Managed)

```
NodeGroup: eks-production-cluster-primary-ng
├── Cluster: eks-production-cluster
├── Status: ACTIVE
│
├── Scaling Configuration
│   ├── Min Size: 2 nodes
│   ├── Max Size: 5 nodes
│   ├── Desired Size: 3 nodes
│   └── Update Strategy: 25% max unavailable
│
├── Instance Configuration
│   ├── Types: t3.medium, t3a.medium (mixed)
│   ├── Capacity Type: ON_DEMAND (or SPOT for cost)
│   ├── Root Volume: 100GB gp3 (encrypted)
│   └── Monitoring: CloudWatch enabled
│
├── Launch Template
│   ├── AMI: Amazon EKS-optimized (auto-selected)
│   ├── User Data: Custom bootstrap script
│   ├── Security Groups: [SG #2]
│   └── Monitoring: Enabled
│
├── IAM Role (attached to EC2 instances)
│   ├── AmazonEKSWorkerNodePolicy
│   ├── AmazonEK_CNI_Policy
│   ├── AmazonEC2ContainerRegistryReadOnly
│   └── AmazonSSMManagedInstanceCore
│
└── Auto Scaling Group
    ├── Linked to Node Group
    ├── Lambda/ECS: Cluster Autoscaler can scale
    └── Tags: For discovery
```

## Data Flow

### 1. Kubectl Command Flow

```
┌─────────────┐
│   kubectl   │ (Your local machine)
└──────┬──────┘
       │ 1. AWS_PROFILE or IAM credentials
       │ 2. SendRequest(api-server-endpoint)
       ▼
┌──────────────────────────────────────────────────┐
│ IAM Authentication (STS assume with OIDC token)  │
└──────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────┐
│   Internet → IGW → Public Subnet → EKS Endpoint │
└──────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────┐
│      EKS API Server (Control Plane)              │
│      - Authenticates request                     │
│      - Authorizes (RBAC)                         │
│      - Process request                           │
└──────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────┐
│   Response → Back through IGW → kubectl          │
└──────────────────────────────────────────────────┘
```

### 2. Pod-to-Pod Communication (Intra-Node)

```
Pod A (Node 1)
    │ 10.0.10.5 (pod IP)
    ▼
Docker Bridge (CNI - AWS VPC CNI)
    │ 10.0.10.15 (node's secondary IP)
    ▼
Node 1 Network Interface
    │ 10.0.10.x (private subnet)
    ▼
VPC Routing (same subnet)
    │
Pod B (Node 1)
    ▲
    │ Direct communication
    └─ Same host
```

### 3. Pod-to-Pod Communication (Inter-Node)

```
Pod A (Node 1, Subnet 10.0.10.0/24)
    │
    ▼
Node 1 ENI (10.0.10.x)
    │ (routes to 10.0.11.0/24)
    ▼
VPC Route Table
    │ Private subnet route (same VPC)
    ▼
Node 2 ENI (10.0.11.x)
    │
Pod B (Node 2, Subnet 10.0.11.0/24)
```

### 4. pod-to-Internet Communication

```
Pod A (Node 1)
    │ needs access to internet
    ▼
Node 1 (Private Subnet 10.0.10.0/24)
    │ 0.0.0.0/0 → NAT Gateway
    ▼
NAT Gateway (in Public Subnet)
    │ Translates IP
    │ elastic-ip:random-port → pod:port
    ▼
IGW (Internet Gateway)
    │
Internet
```

## Terraform Module Dependencies

```
terra form

apply
    │
    ├─→ [VPC Module]
    │       ├── VPC
    │       ├── Public Subnets
    │       ├── Private Subnets
    │       ├── IGW
    │       ├── NAT Gateway (+ Elastic IPs)
    │       └── Route Tables
    │
    ├─→ [Security Groups Module] (depends on VPC)
    │       ├── EKS Control Plane SG
    │       └── EKS Node SG
    │
    ├─→ [EKS Cluster Module] (depends on Security Groups)
    │       ├── CloudWatch Log Group
    │       ├── KMS Key
    │       ├── IAM Role + Policies
    │       ├── OIDC Provider
    │       └── EKS Cluster Resource
    │
    └─→ [Node Groups Module] (depends on EKS Cluster)
            ├── IAM Role + Policies
            ├── Launch Template
            └── Managed Node Group

Total Resources: ~40
Build Time: 15-20 minutes
```

## Production-Grade Features

| Feature                    | Implementation                                |
| -------------------------- | --------------------------------------------- |
| **High Availability**      | 2+ Availability Zones                         |
| **Networking**             | Public/Private subnets with NAT               |
| **Security**               | 2 Security Groups, KMS encryption             |
| **Logging**                | CloudWatch (5 log types)                      |
| **Monitoring**             | CloudWatch metrics enabled                    |
| **Scaling**                | Auto Scaling with configurable limits         |
| **RBAC**                   | IAM Roles for Service Accounts (OIDC)         |
| **Node Configuration**     | Configurable instance types/families          |
| **Cost Control**           | Spot instances, instance families support     |
| **Infrastructure as Code** | Modular, version-controlled                   |
| **Automatic Updates**      | Rolling update strategy (25% max unavailable) |

## Resource Count Breakdown

```
VPC Module:
  - 1 VPC
  - 2 Public Subnets
  - 2 Private Subnets
  - 1 Internet Gateway
  - 1-2 NAT Gateways
  - 1-2 Elastic IPs
  - 1 Public Route Table
  - 2 Private Route Tables
  - 4 Route Table Associations
  Subtotal: 12-14 resources

Security Groups Module:
  - 2 Security Groups
  - 4 Security Group Rules (ingress) + 2 (egress)
  Subtotal: 8-10 resources

EKS Cluster Module:
  - 1 CloudWatch Log Group
  - 1 KMS Key + 1 Alias
  - 1 IAM Role + 2 IAM Policy Attachments
  - 1 OIDC Provider
  - 1 EKS Cluster
  Subtotal: 8 resources

Node Groups Module:
  - 1 IAM Role + 4 IAM Policy Attachments
  - 1 Launch Template
  - 1 Managed Node Group
  Subtotal: 7 resources

Total: 35-40 resources
Estimated build time: 15-20 minutes
```

---

**Architecture is production-ready and follows AWS best practices!** ✅
