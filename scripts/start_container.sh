#!/bin/bash
set -e
echo "Starting new container"

# Get Docker credentials and repo name from SSM
DOCKER_USERNAME=$(aws ssm get-parameter --name /docker/username --with-decryption --region ap-south-1 --query Parameter.Value --output text)
DOCKER_PASSWORD=$(aws ssm get-parameter --name /docker/password --with-decryption --region ap-south-1 --query Parameter.Value --output text)
REPO_NAME=$(aws ssm get-parameter --name /docker/repo/url --with-decryption --region ap-south-1 --query Parameter.Value --output text)

# Validate parameters
if [[ -z "$DOCKER_USERNAME" || -z "$DOCKER_PASSWORD" || -z "$REPO_NAME" ]]; then
    echo "Missing Docker credentials or repo name from SSM!"
    exit 1
fi

# Clean REPO_NAME to ensure valid Docker reference (remove protocol or extra slashes)
CLEANED_REPO=$(echo "$REPO_NAME" | sed 's|https://||g; s|http://||g; s|/docker/||g; s|/$||g')
if [[ -z "$CLEANED_REPO" ]]; then
    echo "Invalid Docker repository name after cleaning!"
    exit 1
fi

# Docker login
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
if [ $? -ne 0 ]; then
    echo "Docker login failed!"
    exit 1
fi
echo "Docker login successful"

# Remove old container if exists (before pull to avoid conflicts)
if docker ps -a -q -f name=my-app-container | grep -q .; then
    echo "Removing old container..."
    docker rm -f my-app-container
    if [ $? -ne 0 ]; then
        echo "Failed to remove old container!"
        exit 1
    fi
fi

# Pull the latest image
FULL_IMAGE="${CLEANED_REPO}:latest"
docker pull "$FULL_IMAGE"
if [ $? -ne 0 ]; then
    echo "Docker pull failed for $FULL_IMAGE!"
    exit 1
fi

# Run the new container
docker run -d --name my-app-container -p 80:80 "$FULL_IMAGE"
if [ $? -ne 0 ]; then
    echo "Docker run failed for $FULL_IMAGE!"
    exit 1
fi
echo "Container started successfully: $FULL_IMAGE"