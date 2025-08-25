#!/bin/bash
set -e
echo "Starting new container"

# Get Docker credentials and repo name from SSM
DOCKER_USERNAME=$(aws ssm get-parameter --name /docker/username --with-decryption --region ap-south-1 --query Parameter.Value --output text)
DOCKER_PASSWORD=$(aws ssm get-parameter --name /docker/password --with-decryption --region ap-south-1 --query Parameter.Value --output text)
REPO_NAME=$(aws ssm get-parameter --name /docker/repo/url --with-decryption --region ap-south-1 --query Parameter.Value --output text)

# Validate
if [[ -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" || -z "$REPO_NAME" ]]; then
    echo "Missing Docker credentials or repo name from SSM!"
    exit 1
fi

# Docker login
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
echo "Docker login successful"

# Remove old container if exists
if docker ps -a -q -f name=my-app-container | grep -q .; then
    echo "Removing old container..."
    docker rm -f my-app-container
fi

# Pull the latest image
FULL_IMAGE="${REPO_NAME}:latest"
docker pull "$FULL_IMAGE"

# Run the new container
docker run -d --name my-app-container -p 80:80 "$FULL_IMAGE"
echo "Container started successfully: $FULL_IMAGE"
