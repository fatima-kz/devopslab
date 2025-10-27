# Quick Setup Verification Script
# Run this to test if your secrets are working

Write-Host "🔍 Testing Docker Hub Setup" -ForegroundColor Blue
Write-Host "==============================" -ForegroundColor Blue

# Test 1: Check if you can login to Docker Hub
Write-Host "`n1. Testing Docker Hub Login..." -ForegroundColor Yellow
Write-Host "Please enter your Docker Hub username when prompted, and use your ACCESS TOKEN (not password) when asked for password."

try {
    docker login
    Write-Host "✅ Docker login successful!" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker login failed. Check your credentials." -ForegroundColor Red
    exit 1
}

# Test 2: Try to pull a test image
Write-Host "`n2. Testing Docker Hub access..." -ForegroundColor Yellow
try {
    docker pull hello-world
    Write-Host "✅ Can pull images from Docker Hub!" -ForegroundColor Green
} catch {
    Write-Host "❌ Cannot pull images. Check your internet connection." -ForegroundColor Red
}

# Test 3: Check if your repository exists
Write-Host "`n3. Checking if your repository exists..." -ForegroundColor Yellow
$dockerUsername = Read-Host "Enter your Docker Hub username"
$repoName = "todo-spring-boot-app"

try {
    $response = Invoke-WebRequest -Uri "https://hub.docker.com/v2/repositories/$dockerUsername/$repoName/" -Method HEAD -ErrorAction Stop
    Write-Host "✅ Repository $dockerUsername/$repoName exists!" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Repository $dockerUsername/$repoName not found. Please create it manually." -ForegroundColor Yellow
    Write-Host "Go to: https://hub.docker.com/repository/create" -ForegroundColor Blue
}

# Summary
Write-Host "`n📋 Next Steps:" -ForegroundColor Blue
Write-Host "1. Make sure you've added GitHub secrets:"
Write-Host "   - DOCKER_USERNAME: $dockerUsername"
Write-Host "   - DOCKER_PASSWORD: <your-docker-hub-access-token>"
Write-Host "`n2. Repository URL: https://github.com/settings/secrets/actions"
Write-Host "`n3. After adding secrets, push your code to trigger the pipeline!"

Write-Host "`n🎉 Setup verification complete!" -ForegroundColor Green