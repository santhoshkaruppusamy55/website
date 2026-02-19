# Automated CI/CD Pipeline for Web Hosting on AWS

## Overview
This project demonstrates an automated CI/CD pipeline using AWS to deploy a simple Flask-based web application. Changes pushed to the GitHub repository are seamlessly reflected on an EC2 instance, showcasing cloud automation for beginners. The setup includes Docker containerization, CodeBuild for image creation, and CodeDeploy for deployment, enhancing efficiency and real-time updates.

## Description
- **Developed an automated CI/CD pipeline** using AWS services to deploy a Flask app, enabling real-time updates to an EC2 instance from GitHub pushes.
- **Implemented Docker containerization**, CodeBuild for building Docker images, and CodeDeploy for seamless deployment to the cloud server.

## Tech Stack
- **AWS**: CodePipeline, CodeBuild, CodeDeploy, EC2, S3, SSM Parameter Store
- **Other**: GitHub, Flask, Docker, Python, HTML

## Layered Approach
The project follows a layered architecture to manage the CI/CD process effectively:

### 1. **Presentation Layer**
- **Component**: `index.html` in the `templates` folder.
- **Purpose**: Defines the webpage structure and content (e.g., displaying text and images like `myimage.png`), served by the Flask app.
- **Interaction**: Updated via GitHub pushes, triggering the pipeline to reflect changes on the EC2-hosted site.

### 2. **Application Layer**
- **Component**: `app.py` with Flask framework.
- **Purpose**: Handles webpage rendering (`render_template("index.html")`) and serves static files (e.g., `myimage.png`) from the `static` folder.
- **Interaction**: Processes requests and integrates with the CI/CD pipeline for deployment updates.

### 3. **Containerization Layer**
- **Component**: `Dockerfile` and `requirements.txt`.
- **Purpose**: Defines the Docker image (`santhoshkaruppusamy/website:latest`) and installs dependencies (e.g., Flask) for the app.
- **Interaction**: Built by CodeBuild and pushed to DockerHub, secured with SSM-stored credentials.

### 4. **CI Layer (Continuous Integration)**
- **Component**: `buildspec.yml` and CodeBuild project.
- **Purpose**: Automates building the Docker image and pushing it to DockerHub when changes are pushed to GitHub.
- **Interaction**: Triggered by the pipeline’s Source stage webhook, ensuring a new image is ready for deployment.

### 5. **CD Layer (Continuous Deployment)**
- **Component**: `appspec.yml`, `scripts/` (e.g., `before_install.sh`, `start_container.sh`, `stop_container.sh`), and CodeDeploy.
- **Purpose**: Manages deployment to the EC2 instance, executing scripts to stop, install, and start the Docker container.
- **Interaction**: Activated by the pipeline’s Deploy stage, using the `SourceArtifact` from the S3 bucket.

### 6. **Infrastructure Layer**
- **Component**: AWS EC2 instance, S3 bucket (`codepipeline-ap-south-1-aa376c8d5759-4fd6-9ebd-e7e52fd53e9f`), IAM roles, and CodePipeline.
- **Purpose**: Hosts the Dockerized app, stores artifacts, manages permissions, and orchestrates the CI/CD pipeline.
- **Interaction**: The pipeline webhook triggers automation, deploying updates to the EC2 instance.

## How It Works
- A push or pull request to the GitHub repo triggers a webhook.
- CodePipeline starts, using CodeBuild to build and push a Docker image, then CodeDeploy to update the EC2 instance.
- The updated `index.html` is reflected at `http://<ec2-public-ip>`.

## Getting Started
- Clone this repo
- Set up AWS services (EC2, CodePipeline, etc.) under the free tier.
- Configure GitHub connection and SSM parameters for Docker credentials.
- Push changes to see the pipeline in action!

Step-by-Step Implementation
Step 1: Set Up SSM Parameters

In the AWS Console:
Create /docker/username (String, value: your DockerHub username).
Create /docker/password (SecureString, value: your DockerHub password or token).
Create /docker/repo/url (String, value: your-username/website).


Step 2: Create IAM Roles

In IAM:
CodeBuild Role: Create codebuild-website-service-role with permissions for CodeBuild, SSM, S3, CodeConnections.
EC2/CodeDeploy Role: Create website-role-ec2 with permissions for CodeDeploy, EC2, SSM, S3.
CodePipeline Role: Create aws-codepipelineservice-role-ap-south-1-website with permissions for CodePipeline, CodeBuild, CodeDeploy, S3.


Step 3: Launch EC2 Instance

In EC2:
Launch a t2.micro instance with Amazon Linux AMI.
Add tags (e.g., Key: Name, Value: my-ec2).
Attach website-role-ec2 role.
Security group: Allow inbound SSH (port 22) and HTTP (port 80) from 0.0.0.0/0.
SSH into the instance and install CodeDeploy agent:Bashsudo yum update -y
sudo yum install -y ruby wget
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo systemctl enable codedeploy-agent


Step 4: Create CodeBuild Project

In CodeBuild:
Project name: website.
Source: GitHub, connect via AWS-managed GitHub app, select repo, branch main.
Environment: On-demand, managed image, EC2, container, Amazon Linux, standard runtime, AMI image.
Role: codebuild-website-service-role.
Buildspec: Use buildspec.yml.
Enable CloudWatch logs.
Create the project (no webhooks needed, as pipeline handles them).


Step 5: Create CodeDeploy Application and Deployment Group

In CodeDeploy:
Create application: Name website-app, platform EC2/On-premises.
Create deployment group: Name website-deployment-group, role website-role-ec2, in-place, EC2 instances (tag: Key Name, Value my-ec2), configuration CodeDeployDefault.AllAtOnce.


Step 6: Create CodePipeline

In CodePipeline:
Name: website-pipeline.
Role: aws-codepipelineservice-role-ap-south-1-website.
Source: GitHub (Version 2), connect via AWS-managed app, repo/branch main, enable webhooks for push (^refs/heads/main), output artifact SourceArtifact.
Build: AWS CodeBuild, project website, input artifact SourceArtifact.
Deploy: AWS CodeDeploy, application website-app, group website-deployment-group, input artifact SourceArtifact.
Create the pipeline.


Testing

Push changes to main (e.g., update index.html).
Monitor the pipeline in the console.
Verify the app at http://<ec2-public-ip>.

Troubleshooting

Check CloudWatch logs for CodeBuild.
SSH into EC2 and check CodeDeploy logs: sudo cat /var/log/aws/codedeploy-agent/codedeploy-agent.log.
Ensure SSM parameters are correct.

Cleanup

Stop/delete EC2 instance to avoid charges.
Delete the pipeline and S3 bucket.
