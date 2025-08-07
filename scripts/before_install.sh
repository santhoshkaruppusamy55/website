#!/bin/bash
set -e
echo "Running BeforeInstall"
if ! command -v docker &> /dev/null; then
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -aG docker ec2-user
fi
echo "$(aws ssm get-parameter --name /docker/password --region ap-south-1 --query Parameter.Value --output text --with-decryption)" | docker login -u "$(aws ssm get-parameter --name /docker/username --region ap-south-1 --query Parameter.Value --output text)" --password-stdin