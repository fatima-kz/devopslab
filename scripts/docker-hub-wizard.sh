#!/bin/bash

# Docker Hub Setup Wizard
# Interactive script to help configure Docker Hub integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║               🐳 Docker Hub Setup Wizard                 ║"
echo "║                                                           ║"
echo "║         DevOps Lab - Spring Boot Todo Application        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Step 1: Collect User Information
echo -e "${BLUE}📝 Step 1: Collect Information${NC}"
echo "=================================================="

read -p "Enter your Docker Hub username [fatima-kz]: " DOCKER_USERNAME
DOCKER_USERNAME=${DOCKER_USERNAME:-fatima-kz}

read -p "Enter your Docker repository name [todo-spring-boot-app]: " DOCKER_REPO
DOCKER_REPO=${DOCKER_REPO:-todo-spring-boot-app}

read -p "Enter your GitHub username [fatima-kz]: " GITHUB_USERNAME
GITHUB_USERNAME=${GITHUB_USERNAME:-fatima-kz}

read -p "Enter your GitHub repository name [devopslab]: " GITHUB_REPO
GITHUB_REPO=${GITHUB_REPO:-devopslab}

echo ""
echo -e "${GREEN}✅ Information collected:${NC}"
echo "   Docker Hub: ${DOCKER_USERNAME}/${DOCKER_REPO}"
echo "   GitHub: ${GITHUB_USERNAME}/${GITHUB_REPO}"
echo ""

# Step 2: Check Prerequisites
echo -e "${BLUE}🔍 Step 2: Check Prerequisites${NC}"
echo "=================================================="

# Check Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker is installed${NC}"
else
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check Git
if command -v git &> /dev/null; then
    echo -e "${GREEN}✅ Git is installed${NC}"
else
    echo -e "${RED}❌ Git is not installed${NC}"
    exit 1
fi

# Check curl
if command -v curl &> /dev/null; then
    echo -e "${GREEN}✅ curl is available${NC}"
else
    echo -e "${RED}❌ curl is not available${NC}"
    exit 1
fi

echo ""

# Step 3: Docker Hub Account Setup
echo -e "${BLUE}🐳 Step 3: Docker Hub Setup${NC}"
echo "=================================================="
echo "Please complete these steps manually:"
echo ""
echo "1. Go to https://hub.docker.com/"
echo "2. Create account or log in"
echo "3. Create a new repository:"
echo "   - Repository name: ${DOCKER_REPO}"
echo "   - Visibility: Public"
echo "   - Description: DevOps Lab - Spring Boot Todo Application"
echo ""
echo "4. Generate an access token:"
echo "   - Go to Account Settings → Security"
echo "   - Click 'New Access Token'"
echo "   - Name: GitHub-Actions-DevOps-Lab"
echo "   - Permissions: Read, Write, Delete"
echo "   - Copy the generated token!"
echo ""

read -p "Press Enter when you have completed the Docker Hub setup..."

# Step 4: Test Docker Login
echo -e "${BLUE}🔑 Step 4: Test Docker Login${NC}"
echo "=================================================="

read -p "Do you want to test Docker login now? [y/N]: " TEST_LOGIN
if [[ $TEST_LOGIN =~ ^[Yy]$ ]]; then
    echo "Please log in to Docker Hub (use your access token as password):"
    docker login
    
    if docker info | grep -q "Username:"; then
        echo -e "${GREEN}✅ Docker login successful${NC}"
    else
        echo -e "${RED}❌ Docker login failed${NC}"
        exit 1
    fi
fi

# Step 5: GitHub Secrets Configuration
echo -e "${BLUE}🔐 Step 5: GitHub Secrets Configuration${NC}"
echo "=================================================="
echo "Please add these secrets to your GitHub repository:"
echo ""
echo "1. Go to: https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}/settings/secrets/actions"
echo "2. Click 'New repository secret'"
echo "3. Add these secrets:"
echo ""
echo -e "${YELLOW}   Secret Name: DOCKER_USERNAME${NC}"
echo -e "${YELLOW}   Secret Value: ${DOCKER_USERNAME}${NC}"
echo ""
echo -e "${YELLOW}   Secret Name: DOCKER_PASSWORD${NC}"
echo -e "${YELLOW}   Secret Value: <your-docker-hub-access-token>${NC}"
echo ""

read -p "Press Enter when you have added the GitHub secrets..."

# Step 6: Test Pipeline Configuration
echo -e "${BLUE}🧪 Step 6: Test Pipeline Configuration${NC}"
echo "=================================================="

# Generate a test configuration file
cat > docker-hub-config.json << EOF
{
  "docker_hub": {
    "username": "${DOCKER_USERNAME}",
    "repository": "${DOCKER_REPO}",
    "full_name": "${DOCKER_USERNAME}/${DOCKER_REPO}"
  },
  "github": {
    "username": "${GITHUB_USERNAME}",
    "repository": "${GITHUB_REPO}",
    "full_name": "${GITHUB_USERNAME}/${GITHUB_REPO}"
  },
  "setup_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo -e "${GREEN}✅ Configuration saved to docker-hub-config.json${NC}"

# Step 7: Next Steps
echo -e "${BLUE}🚀 Step 7: Next Steps${NC}"
echo "=================================================="
echo "Your Docker Hub integration is now configured!"
echo ""
echo "To test everything:"
echo ""
echo "1. Build and test locally:"
echo "   ./scripts/test-docker-hub.sh"
echo ""
echo "2. Commit and push to trigger the pipeline:"
echo "   git add ."
echo "   git commit -m 'feat: configure Docker Hub integration'"
echo "   git push origin main"
echo ""
echo "3. Monitor the pipeline:"
echo "   https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}/actions"
echo ""
echo "4. Check your Docker Hub repository:"
echo "   https://hub.docker.com/r/${DOCKER_USERNAME}/${DOCKER_REPO}"
echo ""

# Final summary
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                    🎉 Setup Complete!                    ║"
echo "║                                                           ║"
echo "║  Your Docker Hub integration is ready for the pipeline!  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}📚 Documentation:${NC}"
echo "- Docker Hub Setup: ./DOCKER_HUB_SETUP.md"
echo "- GitHub Secrets: ./GITHUB_SECRETS_SETUP.md"
echo "- Test Script: ./scripts/test-docker-hub.sh"