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

## Acknowledgements
This project was built as a learning exercise to understand AWS CI/CD automation, leveraging free tier resources.
