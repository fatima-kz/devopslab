# Docker Hub Integration Setup Guide

This guide will help you set up Docker Hub integration with proper secrets management for your DevOps pipeline.

## 🐳 Step 1: Create Docker Hub Account & Repository

### 1.1 Create Docker Hub Account
1. Go to [Docker Hub](https://hub.docker.com/)
2. Sign up for a free account (if you don't have one)
3. Verify your email address

### 1.2 Create a Repository
1. Log into Docker Hub
2. Click **"Create Repository"**
3. Set repository name: `todo-spring-boot-app`
4. Set visibility: **Public** (free tier)
5. Add description: `DevOps Lab - Spring Boot Todo Application`
6. Click **"Create"**

### 1.3 Generate Access Token (Recommended)
1. Go to **Account Settings** → **Security**
2. Click **"New Access Token"**
3. Token Name: `GitHub-Actions-DevOps-Lab`
4. Permissions: **Read, Write, Delete**
5. Click **"Generate"**
6. **IMPORTANT**: Copy the token immediately (you won't see it again!)

## 🔐 Step 2: Configure GitHub Secrets

### 2.1 Access GitHub Repository Settings
1. Go to your GitHub repository: `https://github.com/fatima-kz/devopslab`
2. Click **"Settings"** tab
3. In the left sidebar, click **"Secrets and variables"** → **"Actions"**

### 2.2 Add Required Secrets
Add these secrets by clicking **"New repository secret"**:

```
Secret Name: DOCKER_USERNAME
Secret Value: your-dockerhub-username

Secret Name: DOCKER_PASSWORD
Secret Value: your-dockerhub-access-token-or-password
```

**⚠️ SECURITY NOTE**: Always use access tokens instead of passwords for better security!

## 🔧 Step 3: Test Docker Hub Integration Locally

Before pushing to GitHub, let's test the Docker integration locally:

### 3.1 Build and Tag Image
```bash
# Build the image
docker build -t fatima-kz/todo-spring-boot-app:latest .

# Tag with version
docker tag fatima-kz/todo-spring-boot-app:latest fatima-kz/todo-spring-boot-app:v1.0.0
```

### 3.2 Test Login and Push
```bash
# Login to Docker Hub (use your access token as password)
docker login -u your-dockerhub-username

# Push the image
docker push fatima-kz/todo-spring-boot-app:latest
docker push fatima-kz/todo-spring-boot-app:v1.0.0
```

## 🚀 Step 4: Verify Pipeline Configuration

The pipeline is already configured with:

### 4.1 Docker Build & Push Stage
```yaml
- name: 🔑 Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

- name: 🐳 Build and Push Docker Image
  uses: docker/build-push-action@v5
  with:
    context: .
    platforms: linux/amd64,linux/arm64
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
```

### 4.2 Image Tagging Strategy
The pipeline automatically creates these tags:
- `latest` (for main branch)
- `main-<commit-sha>` (for main branch commits)
- `develop-<commit-sha>` (for develop branch commits)
- `pr-<number>` (for pull requests)

## 📋 Step 5: Environment Setup (Optional)

### 5.1 Create Production Environment
1. Go to **Settings** → **Environments**
2. Click **"New environment"**
3. Name: `production`
4. Add protection rules:
   - ✅ Required reviewers: Add yourself
   - ✅ Wait timer: 5 minutes
   - ✅ Deployment branches: `main` only

## 🧪 Step 6: Test the Full Pipeline

### 6.1 Trigger Pipeline
```bash
# Make a small change and push to main
echo "# DevOps Pipeline Test" >> README.md
git add README.md
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

### 6.2 Monitor Pipeline
1. Go to **Actions** tab in your GitHub repository
2. Watch the pipeline execute all 5 stages
3. Verify Docker image is pushed to Docker Hub

## 🔍 Verification Checklist

After setup, verify:

- [ ] Docker Hub repository exists and is accessible
- [ ] GitHub secrets are configured correctly
- [ ] Pipeline runs without errors
- [ ] Docker images are pushed successfully
- [ ] Images have proper tags and metadata
- [ ] Security scans complete successfully

## 🛠️ Troubleshooting

### Common Issues:

**❌ "unauthorized: authentication required"**
- Check DOCKER_USERNAME matches exactly
- Verify DOCKER_PASSWORD is the access token, not account password
- Ensure token has Read/Write permissions

**❌ "repository does not exist"**
- Verify repository name matches in Docker Hub
- Check if repository is public (required for free accounts)

**❌ "denied: requested access to the resource is denied"**
- Verify you own the Docker Hub repository
- Check token permissions include Write access

### Pipeline Debugging:
```bash
# Check Docker Hub from command line
docker pull fatima-kz/todo-spring-boot-app:latest

# Test authentication
echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
```

## 🎯 Success Indicators

When properly configured, you should see:
- ✅ Green checkmark on Docker build stage
- ✅ New images in your Docker Hub repository
- ✅ Proper tags and metadata on images
- ✅ Security scan results in GitHub
- ✅ Successful deployment stage (if triggered)

## 📚 Additional Resources

- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [GitHub Actions Docker Documentation](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [Docker Build Push Action](https://github.com/docker/build-push-action)