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
else
    echo "Docker is already installed."
fi

# Start Docker if not running
if ! sudo service docker status | grep -q running; then
    echo "Starting Docker..."
    sudo service docker start
fi

# Get Docker credentials from SSM
DOCKER_USERNAME=$(aws ssm get-parameter --name /docker/username --region ap-south-1 --query Parameter.Value --output text)
DOCKER_PASSWORD=$(aws ssm get-parameter --name /docker/password --region ap-south-1 --with-decryption --query Parameter.Value --output text)

# Debug (optional - for testing only, remove later)
echo "Docker username is: $DOCKER_USERNAME"
# Don't echo the password for security reasons

# Login to Docker
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "Docker login successful"
