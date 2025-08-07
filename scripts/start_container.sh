#!/bin/bash
set -e
echo "Starting new container"
# Retrieve repo URL from Parameter Store
REPO_URL=$(aws ssm get-parameter --name /docker/repo/url --region ap-south-1 --query Parameter.Value --output text)
docker pull "${REPO_URL}:latest"
docker run -d --name my-app-container -p 80:80 "${REPO_URL}:latest"