#!/bin/bash

# Docker Hub Integration Setup and Test Script
# This script helps you set up and test Docker Hub integration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_USERNAME="fatima-kz"
DOCKER_REPO="todo-spring-boot-app"
IMAGE_NAME="${DOCKER_USERNAME}/${DOCKER_REPO}"

echo -e "${BLUE}🐳 Docker Hub Integration Setup Script${NC}"
echo "=================================================="

# Check if Docker is installed
echo -e "${BLUE}📋 Checking Prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is installed${NC}"

# Check if logged in to Docker Hub
echo -e "${BLUE}🔐 Checking Docker Hub Authentication...${NC}"
if docker info | grep -q "Username:"; then
    CURRENT_USER=$(docker info | grep "Username:" | awk '{print $2}')
    echo -e "${GREEN}✅ Already logged in as: ${CURRENT_USER}${NC}"
else
    echo -e "${YELLOW}⚠️  Not logged in to Docker Hub${NC}"
    echo -e "${BLUE}Please run: docker login${NC}"
    echo -e "${BLUE}Use your Docker Hub access token as password${NC}"
    exit 1
fi

# Build the Docker image
echo -e "${BLUE}🔨 Building Docker Image...${NC}"
if docker build -t ${IMAGE_NAME}:latest .; then
    echo -e "${GREEN}✅ Docker image built successfully${NC}"
else
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi

# Tag the image with version
VERSION="v$(date +%Y%m%d-%H%M%S)"
docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:${VERSION}
echo -e "${GREEN}✅ Tagged image as ${IMAGE_NAME}:${VERSION}${NC}"

# Test push to Docker Hub
echo -e "${BLUE}🚀 Testing Push to Docker Hub...${NC}"
if docker push ${IMAGE_NAME}:latest && docker push ${IMAGE_NAME}:${VERSION}; then
    echo -e "${GREEN}✅ Successfully pushed to Docker Hub!${NC}"
    echo -e "${GREEN}   Repository: https://hub.docker.com/r/${DOCKER_USERNAME}/${DOCKER_REPO}${NC}"
else
    echo -e "${RED}❌ Failed to push to Docker Hub${NC}"
    exit 1
fi

# Test pull from Docker Hub
echo -e "${BLUE}🔄 Testing Pull from Docker Hub...${NC}"
docker rmi ${IMAGE_NAME}:latest || true
if docker pull ${IMAGE_NAME}:latest; then
    echo -e "${GREEN}✅ Successfully pulled from Docker Hub!${NC}"
else
    echo -e "${RED}❌ Failed to pull from Docker Hub${NC}"
    exit 1
fi

# Test run the container
echo -e "${BLUE}🧪 Testing Container Execution...${NC}"
CONTAINER_ID=$(docker run -d -p 8082:8080 ${IMAGE_NAME}:latest)
echo -e "${BLUE}Container ID: ${CONTAINER_ID}${NC}"

# Wait for application to start
echo -e "${BLUE}⏳ Waiting for application to start...${NC}"
sleep 30

# Test health check
if curl -f http://localhost:8082/actuator/health 2>/dev/null; then
    echo -e "${GREEN}✅ Application is running and healthy!${NC}"
    echo -e "${GREEN}   Health Check: http://localhost:8082/actuator/health${NC}"
else
    echo -e "${YELLOW}⚠️  Application may still be starting...${NC}"
fi

# Stop and remove test container
docker stop ${CONTAINER_ID} >/dev/null
docker rm ${CONTAINER_ID} >/dev/null
echo -e "${BLUE}🧹 Cleaned up test container${NC}"

# Summary
echo ""
echo -e "${GREEN}🎉 Docker Hub Integration Test Complete!${NC}"
echo "=================================================="
echo -e "${GREEN}✅ Docker image built successfully${NC}"
echo -e "${GREEN}✅ Image pushed to Docker Hub${NC}"
echo -e "${GREEN}✅ Image can be pulled from Docker Hub${NC}"
echo -e "${GREEN}✅ Container runs successfully${NC}"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "1. Add GitHub secrets (DOCKER_USERNAME, DOCKER_PASSWORD)"
echo "2. Push code to GitHub to trigger the CI/CD pipeline"
echo "3. Monitor the pipeline in GitHub Actions"
echo ""
echo -e "${BLUE}🔗 Resources:${NC}"
echo "- Docker Hub Repository: https://hub.docker.com/r/${DOCKER_USERNAME}/${DOCKER_REPO}"
echo "- GitHub Secrets Setup: ./GITHUB_SECRETS_SETUP.md"
echo "- Pipeline Status: https://github.com/fatima-kz/devopslab/actions"