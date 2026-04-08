#!/bin/bash

##############################################################################
# EKS Terraform Quickstart Script
# This script automates the initial setup and deployment
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}===============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===============================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Terraform
    if command -v terraform &> /dev/null; then
        TF_VERSION=$(terraform version | head -1)
        print_success "$TF_VERSION"
    else
        print_error "Terraform not installed. Install from: https://www.terraform.io/downloads"
        exit 1
    fi
    
    # Check AWS CLI
    if command -v aws &> /dev/null; then
        AWS_VERSION=$(aws --version)
        print_success "$AWS_VERSION"
    else
        print_error "AWS CLI not installed. Install from: https://aws.amazon.com/cli/"
        exit 1
    fi
    
    # Check kubectl
    if command -v kubectl &> /dev/null; then
        print_success "kubectl installed"
    else
        print_warning "kubectl not installed (will be needed later)"
    fi
    
    # Check AWS credentials
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
        print_success "AWS credentials configured (Account: $ACCOUNT)"
    else
        print_error "AWS credentials not configured. Run: aws configure"
        exit 1
    fi
}

setup_terraform() {
    print_header "Setting Up Terraform"
    
    # Initialize Terraform
    echo "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
    
    # Validate configuration
    echo "Validating Terraform configuration..."
    terraform validate
    print_success "Terraform configuration valid"
    
    # Format check
    echo "Checking code formatting..."
    terraform fmt -recursive
    print_success "Terraform code formatted"
}

create_plan() {
    print_header "Creating Terraform Plan"
    
    TFVARS_FILE="${1:-terraform.tfvars}"
    
    if [ ! -f "$TFVARS_FILE" ]; then
        print_error "$TFVARS_FILE not found"
        echo "Creating $TFVARS_FILE from example..."
        cp terraform.tfvars.example "$TFVARS_FILE"
        print_warning "Edit $TFVARS_FILE before proceeding!"
        return 1
    fi
    
    echo "Creating plan with $TFVARS_FILE..."
    terraform plan -var-file="$TFVARS_FILE" -out=tfplan
    print_success "Plan created: tfplan"
}

show_plan_summary() {
    print_header "Plan Summary"
    
    terraform show -json tfplan | jq '.resource_changes[] | select(.change.actions != ["no-op"]) | {address, actions: .change.actions}' 2>/dev/null || \
    terraform show tfplan | grep -E '(will be created|will be destroyed|will be updated)' | wc -l | xargs echo "Resources:"
}

apply_terraform() {
    print_header "Applying Terraform Configuration"
    
    read -p "Do you want to apply? (yes to confirm): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    
    terraform apply tfplan
    print_success "Infrastructure deployed!"
}

configure_kubectl() {
    print_header "Configuring kubectl"
    
    CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null)
    REGION=$(terraform output -raw aws_region 2>/dev/null)
    
    if [ -z "$CLUSTER_NAME" ] || [ -z "$REGION" ]; then
        print_error "Could not get cluster details from Terraform outputs"
        return 1
    fi
    
    echo "Cluster: $CLUSTER_NAME"
    echo "Region: $REGION"
    echo ""
    echo "Updating kubeconfig..."
    
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
    print_success "kubeconfig updated"
    
    echo ""
    echo "Verifying cluster access..."
    if kubectl cluster-info &> /dev/null; then
        print_success "Cluster accessible"
        echo ""
        echo "Current nodes:"
        kubectl get nodes
    else
        print_warning "Could not verify cluster access yet (nodes may still be launching)"
    fi
}

show_outputs() {
    print_header "Terraform Outputs"
    
    echo ""
    terraform output
    echo ""
    
    print_header "Next Steps"
    echo ""
    echo "1. Verify cluster is ready:"
    echo "   kubectl get nodes"
    echo ""
    echo "2. Check system pods:"
    echo "   kubectl get pods -A"
    echo ""
    echo "3. Install Ingress Controller (optional):"
    echo "   helm repo add eks https://aws.github.io/eks-charts"
    echo "   helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system"
    echo ""
    echo "4. View documentation:"
    echo "   cat README.md"
    echo "   cat DEPLOYMENT_GUIDE.md"
    echo "   cat ARCHITECTURE.md"
    echo ""
}

cleanup_plan() {
    rm -f tfplan
}

main() {
    print_header "EKS Infrastructure Quickstart"
    
    echo ""
    echo "This script will:"
    echo "  1. Check prerequisites (Terraform, AWS CLI, credentials)"
    echo "  2. Initialize Terraform"
    echo "  3. Create and review a plan"
    echo "  4. Apply the configuration (with confirmation)"
    echo "  5. Configure kubectl"
    echo ""
    
    read -p "Continue? (yes/no): " start
    if [ "$start" != "yes" ]; then
        echo "Cancelled."
        exit 0
    fi
    
    echo ""
    
    # Run steps
    check_prerequisites
    echo ""
    
    setup_terraform
    echo ""
    
    TFVARS="${1:-terraform.tfvars}"
    if ! create_plan "$TFVARS"; then
        exit 1
    fi
    echo ""
    
    show_plan_summary
    echo ""
    
    apply_terraform
    echo ""
    
    cleanup_plan
    
    if command -v kubectl &> /dev/null; then
        sleep 5  # Wait for cluster to be fully ready
        configure_kubectl
    else
        print_warning "kubectl not installed. Install from: https://kubernetes.io/docs/tasks/tools/"
    fi
    echo ""
    
    show_outputs
    
    print_success "Deployment Complete!"
}

# Handle arguments
case "${1:-deploy}" in
    deploy)
        main "${2:-terraform.tfvars}"
        ;;
    plan)
        check_prerequisites
        setup_terraform
        create_plan "${2:-terraform.tfvars}"
        show_plan_summary
        ;;
    apply)
        apply_terraform
        ;;
    destroy)
        print_header "Destroying Infrastructure"
        read -p "Are you sure? Type 'destroy' to confirm: " confirm
        if [ "$confirm" = "destroy" ]; then
            terraform destroy -var-file="${2:-terraform.tfvars}"
            print_success "Infrastructure destroyed"
        else
            echo "Cancelled"
        fi
        ;;
    kubeconfig)
        configure_kubectl
        ;;
    outputs)
        show_outputs
        ;;
    *)
        echo "Usage: $0 {deploy|plan|apply|destroy|kubeconfig|outputs} [tfvars_file]"
        echo ""
        echo "Commands:"
        echo "  deploy      - Full deployment (default)"
        echo "  plan        - Create and show plan"
        echo "  apply       - Apply existing plan"
        echo "  destroy     - Destroy infrastructure"
        echo "  kubeconfig  - Configure kubectl"
        echo "  outputs     - Show Terraform outputs"
        echo ""
        echo "Examples:"
        echo "  $0 deploy terraform.tfvars"
        echo "  $0 plan environments/prod.tfvars"
        echo "  $0 destroy environments/dev.tfvars"
        exit 1
        ;;
esac
