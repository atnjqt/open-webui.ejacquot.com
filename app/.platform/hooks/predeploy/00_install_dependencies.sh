#!/bin/bash
# .platform/hooks/predeploy/00_install_dependencies.sh
# Install system dependencies needed for bedrock-gateway

set -e

echo "Installing system dependencies for Bedrock Gateway..."

# Update package manager
sudo yum update -y

# Install Python 3 and pip if not present
if ! command -v python3 &> /dev/null; then
    echo "Installing Python 3..."
    sudo yum install -y python3 python3-pip
fi

# Install git if not present
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    sudo yum install -y git
fi

echo "System dependencies installation complete"
