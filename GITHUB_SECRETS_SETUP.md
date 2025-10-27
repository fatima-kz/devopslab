# GitHub Secrets Setup Guide

This document explains how to set up the required GitHub secrets for the CI/CD pipeline to work properly.

## Required Secrets

### 1. Docker Hub Integration
- **DOCKER_USERNAME**: Your Docker Hub username
- **DOCKER_PASSWORD**: Your Docker Hub password or access token

### 2. Cloud Deployment (Optional - Choose One)
- **RAILWAY_TOKEN**: Railway deployment token (if using Railway)
- **RENDER_API_KEY**: Render API key (if using Render)

## How to Add Secrets

1. Go to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click on **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret with the exact name and value

## Setting Up Docker Hub Secrets

### Step 1: Create Docker Hub Account
1. Go to [Docker Hub](https://hub.docker.com/)
2. Create an account or log in
3. Go to **Account Settings** → **Security**
4. Click **New Access Token**
5. Give it a name like "GitHub Actions"
6. Copy the generated token

### Step 2: Add to GitHub Secrets
```
Secret Name: DOCKER_USERNAME
Secret Value: your-dockerhub-username

Secret Name: DOCKER_PASSWORD
Secret Value: your-dockerhub-access-token
```

## Setting Up Cloud Deployment (Optional)

### Option 1: Railway
1. Go to [Railway](https://railway.app/)
2. Create an account and a new project
3. Go to project settings and generate an API token
4. Add to GitHub secrets:
```
Secret Name: RAILWAY_TOKEN
Secret Value: your-railway-token
```

### Option 2: Render
1. Go to [Render](https://render.com/)
2. Create an account
3. Go to account settings and generate an API key
4. Add to GitHub secrets:
```
Secret Name: RENDER_API_KEY
Secret Value: your-render-api-key
```

## Environment Configuration

The pipeline includes an environment called `production` for deployment approval. 
To set this up:

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name it `production`
4. Add protection rules if desired (e.g., required reviewers)

## Testing the Pipeline

Once secrets are configured:

1. Push code to the `main` branch
2. The pipeline will automatically run all 5 stages
3. Deployment will only occur on the `main` branch
4. Check the **Actions** tab to monitor progress

## Pipeline Stages

✅ **Build & Install**: Compiles code and caches dependencies  
✅ **Lint & Security**: Code quality and security scanning  
✅ **Test**: Unit and integration tests with database  
✅ **Build Docker**: Creates and pushes Docker images  
✅ **Deploy**: Conditional deployment to production  

## Troubleshooting

- **Docker push fails**: Check DOCKER_USERNAME and DOCKER_PASSWORD
- **Deployment fails**: Verify cloud platform tokens
- **Tests fail**: Check database configuration in pipeline
- **Security scan fails**: Review and suppress false positives in owasp-suppression.xml