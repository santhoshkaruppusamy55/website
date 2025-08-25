#!/bin/bash
set -e
echo "Starting new container"

# Get Docker credentials and repo URL from SSM
DOCKER_USERNAME=$(aws ssm get-parameter --name /docker/username --with-decryption --region ap-south-1 --query Parameter.Value --output text)
DOCKER_PASSWORD=$(aws ssm get-parameter --name /docker/password --with-decryption --region ap-south-1 --query Parameter.Value --output text)
REPO_URL=$(aws ssm get-parameter --name /docker/repo/url --with-decryption --region ap-south-1 --query Parameter.Value --output text)

# Validate parameters
if [[ -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" || -z "$REPO_URL" ]]; then
    echo "Missing Docker credentials or repo URL from SSM!"
    exit 1
fi

# Docker login
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
if [ $? -ne 0 ]; then
    echo "Docker login failed!"
    exit 1
fi
echo "Docker login successful"

# Pull the latest image
docker pull "$REPO_URL:latest"
if [ $? -ne 0 ]; then
    echo "Docker pull failed!"
    exit 1
fi

# Check and remove any leftover container (failsafe)
if docker ps -a -q -f name=my-app-container | grep -q .; then
    echo "Removing leftover container..."
    docker rm -f my-app-container
fi

# Run the new container
docker run -d --name my-app-container -p 80:80 "$REPO_URL:latest"
if [ $? -ne 0 ]; then
    echo "Docker run failed!"
    exit 1
fi
echo "Container started successfully"