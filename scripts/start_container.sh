#!/bin/bash
set -e
echo "Starting new container"

# Get full DockerHub URL from SSM (stored as SecureString)
FULL_REPO_URL=$(aws ssm get-parameter --name /docker/repo/url --with-decryption --region ap-south-1 --query Parameter.Value --output text)

# Validate
if [[ -z "$FULL_REPO_URL" ]]; then
  echo "Docker repo URL is missing from SSM!"
  exit 1
fi

# Extract Docker image name from full URL
# From: https://hub.docker.com/repository/docker/username/repo-name
# To: username/repo-name
REPO_PATH=$(echo "$FULL_REPO_URL" | awk -F'/docker/' '{print $2}')

# Confirm extracted path
if [[ -z "$REPO_PATH" ]]; then
  echo "Failed to extract image path from DockerHub URL!"
  exit 1
fi

# Pull and run container
docker pull "$REPO_PATH:latest"
docker run -d --name my-app-container -p 80:80 "$REPO_PATH:latest"
