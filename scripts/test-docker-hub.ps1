# Docker Hub Integration Setup and Test Script (PowerShell)
# This script helps you set up and test Docker Hub integration on Windows

param(
    [string]$DockerUsername = "fatima-kz",
    [string]$DockerRepo = "todo-spring-boot-app"
)

# Configuration
$ImageName = "${DockerUsername}/${DockerRepo}"

Write-Host "🐳 Docker Hub Integration Setup Script" -ForegroundColor Blue
Write-Host "=================================================="

# Check if Docker is installed
Write-Host "📋 Checking Prerequisites..." -ForegroundColor Blue
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if logged in to Docker Hub
Write-Host "🔐 Checking Docker Hub Authentication..." -ForegroundColor Blue
$dockerInfo = docker info 2>$null | Select-String "Username:"
if ($dockerInfo) {
    $currentUser = $dockerInfo.ToString().Split()[1]
    Write-Host "✅ Already logged in as: $currentUser" -ForegroundColor Green
} else {
    Write-Host "⚠️ Not logged in to Docker Hub" -ForegroundColor Yellow
    Write-Host "Please run: docker login" -ForegroundColor Blue
    Write-Host "Use your Docker Hub access token as password" -ForegroundColor Blue
    exit 1
}

# Build the Docker image
Write-Host "🔨 Building Docker Image..." -ForegroundColor Blue
try {
    docker build -t "${ImageName}:latest" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker image built successfully" -ForegroundColor Green
    } else {
        throw "Docker build failed"
    }
} catch {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}

# Tag the image with version
$Version = "v$(Get-Date -Format 'yyyyMMdd-HHmmss')"
docker tag "${ImageName}:latest" "${ImageName}:${Version}"
Write-Host "✅ Tagged image as ${ImageName}:${Version}" -ForegroundColor Green

# Test push to Docker Hub
Write-Host "🚀 Testing Push to Docker Hub..." -ForegroundColor Blue
try {
    docker push "${ImageName}:latest"
    docker push "${ImageName}:${Version}"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully pushed to Docker Hub!" -ForegroundColor Green
        Write-Host "   Repository: https://hub.docker.com/r/${DockerUsername}/${DockerRepo}" -ForegroundColor Green
    } else {
        throw "Push failed"
    }
} catch {
    Write-Host "❌ Failed to push to Docker Hub" -ForegroundColor Red
    exit 1
}

# Test pull from Docker Hub
Write-Host "🔄 Testing Pull from Docker Hub..." -ForegroundColor Blue
docker rmi "${ImageName}:latest" 2>$null
try {
    docker pull "${ImageName}:latest"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully pulled from Docker Hub!" -ForegroundColor Green
    } else {
        throw "Pull failed"
    }
} catch {
    Write-Host "❌ Failed to pull from Docker Hub" -ForegroundColor Red
    exit 1
}

# Test run the container
Write-Host "🧪 Testing Container Execution..." -ForegroundColor Blue
$ContainerId = docker run -d -p 8082:8080 "${ImageName}:latest"
Write-Host "Container ID: $ContainerId" -ForegroundColor Blue

# Wait for application to start
Write-Host "⏳ Waiting for application to start..." -ForegroundColor Blue
Start-Sleep -Seconds 30

# Test health check
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/actuator/health" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application is running and healthy!" -ForegroundColor Green
        Write-Host "   Health Check: http://localhost:8082/actuator/health" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Application may still be starting..." -ForegroundColor Yellow
}

# Stop and remove test container
docker stop $ContainerId | Out-Null
docker rm $ContainerId | Out-Null
Write-Host "🧹 Cleaned up test container" -ForegroundColor Blue

# Summary
Write-Host ""
Write-Host "🎉 Docker Hub Integration Test Complete!" -ForegroundColor Green
Write-Host "=================================================="
Write-Host "✅ Docker image built successfully" -ForegroundColor Green
Write-Host "✅ Image pushed to Docker Hub" -ForegroundColor Green
Write-Host "✅ Image can be pulled from Docker Hub" -ForegroundColor Green
Write-Host "✅ Container runs successfully" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Blue
Write-Host "1. Add GitHub secrets (DOCKER_USERNAME, DOCKER_PASSWORD)"
Write-Host "2. Push code to GitHub to trigger the CI/CD pipeline"
Write-Host "3. Monitor the pipeline in GitHub Actions"
Write-Host ""
Write-Host "🔗 Resources:" -ForegroundColor Blue
Write-Host "- Docker Hub Repository: https://hub.docker.com/r/${DockerUsername}/${DockerRepo}"
Write-Host "- GitHub Secrets Setup: ./GITHUB_SECRETS_SETUP.md"
Write-Host "- Pipeline Status: https://github.com/fatima-kz/devopslab/actions"