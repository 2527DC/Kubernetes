#!/bin/bash
set -o xtrace

# EKS Node User Data Script
# This script runs on node startup for additional configuration

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting EKS node user data script"
echo "Cluster Name: ${cluster_name}"

# System updates
yum update -y

# CloudWatch agent installation (optional)
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
# rpm -U ./amazon-cloudwatch-agent.rpm

echo "EKS node user data script completed successfully"
