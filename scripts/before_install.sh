#!/bin/bash
set -e
echo "Running BeforeInstall"

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing..."
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -aG docker ec2-user
    echo "Docker installed and started."
else
    echo "Docker is already installed."
fi

# Start Docker if not running
if ! sudo service docker status | grep -q running; then
    echo "Starting Docker..."
    sudo service docker start
    echo "Docker started."
fi