# Docker Hub Integration Validation Script
# Validates that all components are properly configured

param(
    [switch]$Detailed,
    [switch]$FixIssues
)

# Colors for PowerShell output
$Host.UI.RawUI.ForegroundColor = "White"

function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $originalColor = $Host.UI.RawUI.ForegroundColor
    
    switch ($Color) {
        "Red" { $Host.UI.RawUI.ForegroundColor = "Red" }
        "Green" { $Host.UI.RawUI.ForegroundColor = "Green" }
        "Blue" { $Host.UI.RawUI.ForegroundColor = "Blue" }
        "Yellow" { $Host.UI.RawUI.ForegroundColor = "Yellow" }
        default { $Host.UI.RawUI.ForegroundColor = "White" }
    }
    
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

Write-ColoredOutput "🔍 Docker Hub Integration Validator" "Blue"
Write-ColoredOutput "======================================" "Blue"

$ValidationResults = @{
    Docker = $false
    GitHubWorkflow = $false
    DockerCompose = $false
    Scripts = $false
    Documentation = $false
}

# Check 1: Docker Installation
Write-ColoredOutput "`n📋 Checking Docker Installation..." "Blue"
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-ColoredOutput "✅ Docker is installed: $dockerVersion" "Green"
        $ValidationResults.Docker = $true
    } else {
        Write-ColoredOutput "❌ Docker is not installed" "Red"
    }
} catch {
    Write-ColoredOutput "❌ Docker is not installed or not in PATH" "Red"
}

# Check 2: GitHub Workflow Files
Write-ColoredOutput "`n📄 Checking GitHub Workflow Files..." "Blue"
$workflowFiles = @(
    ".\.github\workflows\ci-cd.yml",
    ".\.github\workflows\docker-hub-test.yml"
)

$workflowsExist = $true
foreach ($file in $workflowFiles) {
    if (Test-Path $file) {
        Write-ColoredOutput "✅ Found: $file" "Green"
    } else {
        Write-ColoredOutput "❌ Missing: $file" "Red"
        $workflowsExist = $false
    }
}
$ValidationResults.GitHubWorkflow = $workflowsExist

# Check 3: Docker Configuration Files
Write-ColoredOutput "`n🐳 Checking Docker Configuration..." "Blue"
$dockerFiles = @{
    ".\Dockerfile" = "Docker build configuration"
    ".\docker-compose.yml" = "Docker Compose orchestration"
    ".\.dockerignore" = "Docker build optimization"
}

$dockerConfigExists = $true
foreach ($file in $dockerFiles.Keys) {
    if (Test-Path $file) {
        Write-ColoredOutput "✅ Found: $file - $($dockerFiles[$file])" "Green"
        
        if ($Detailed -and $file -eq ".\Dockerfile") {
            $content = Get-Content $file -Raw
            if ($content -match "FROM.*openjdk") {
                Write-ColoredOutput "   ✓ Uses OpenJDK base image" "Green"
            }
            if ($content -match "EXPOSE 8080") {
                Write-ColoredOutput "   ✓ Exposes port 8080" "Green"
            }
        }
    } else {
        Write-ColoredOutput "❌ Missing: $file - $($dockerFiles[$file])" "Red"
        $dockerConfigExists = $false
    }
}
$ValidationResults.DockerCompose = $dockerConfigExists

# Check 4: Scripts and Tools
Write-ColoredOutput "`n🛠️ Checking Scripts and Tools..." "Blue"
$scripts = @{
    ".\scripts\test-docker-hub.sh" = "Bash test script"
    ".\scripts\test-docker-hub.ps1" = "PowerShell test script"
    ".\scripts\docker-hub-wizard.sh" = "Setup wizard"
}

$scriptsExist = $true
foreach ($script in $scripts.Keys) {
    if (Test-Path $script) {
        Write-ColoredOutput "✅ Found: $script - $($scripts[$script])" "Green"
    } else {
        Write-ColoredOutput "⚠️ Missing: $script - $($scripts[$script])" "Yellow"
    }
}
$ValidationResults.Scripts = $scriptsExist

# Check 5: Documentation
Write-ColoredOutput "`n📚 Checking Documentation..." "Blue"
$docs = @{
    ".\DOCKER_HUB_SETUP.md" = "Docker Hub setup guide"
    ".\GITHUB_SECRETS_SETUP.md" = "GitHub secrets configuration"
    ".\owasp-suppression.xml" = "Security scan configuration"
}

$docsExist = $true
foreach ($doc in $docs.Keys) {
    if (Test-Path $doc) {
        Write-ColoredOutput "✅ Found: $doc - $($docs[$doc])" "Green"
    } else {
        Write-ColoredOutput "❌ Missing: $doc - $($docs[$doc])" "Red"
        $docsExist = $false
    }
}
$ValidationResults.Documentation = $docsExist

# Check 6: GitHub Workflow Content Validation
Write-ColoredOutput "`n🔍 Validating Workflow Content..." "Blue"
if (Test-Path ".\.github\workflows\ci-cd.yml") {
    $workflowContent = Get-Content ".\.github\workflows\ci-cd.yml" -Raw
    
    $requiredStages = @(
        "build-and-install",
        "lint-and-security", 
        "test-with-database",
        "build-docker-image",
        "deploy"
    )
    
    $stagesFound = 0
    foreach ($stage in $requiredStages) {
        if ($workflowContent -match $stage) {
            Write-ColoredOutput "   ✓ Stage found: $stage" "Green"
            $stagesFound++
        } else {
            Write-ColoredOutput "   ❌ Stage missing: $stage" "Red"
        }
    }
    
    if ($stagesFound -eq 5) {
        Write-ColoredOutput "✅ All 5 required pipeline stages are present" "Green"
    } else {
        Write-ColoredOutput "❌ Only $stagesFound/5 pipeline stages found" "Red"
    }
    
    # Check for secrets usage
    if ($workflowContent -match '\$\{\{\s*secrets\.DOCKER_USERNAME\s*\}\}') {
        Write-ColoredOutput "   ✓ Uses DOCKER_USERNAME secret" "Green"
    } else {
        Write-ColoredOutput "   ❌ DOCKER_USERNAME secret not used" "Red"
    }
    
    if ($workflowContent -match '\$\{\{\s*secrets\.DOCKER_PASSWORD\s*\}\}') {
        Write-ColoredOutput "   ✓ Uses DOCKER_PASSWORD secret" "Green"
    } else {
        Write-ColoredOutput "   ❌ DOCKER_PASSWORD secret not used" "Red"
    }
}

# Summary
Write-ColoredOutput "`n📊 Validation Summary" "Blue"
Write-ColoredOutput "======================================" "Blue"

$totalChecks = $ValidationResults.Count
$passedChecks = ($ValidationResults.Values | Where-Object { $_ -eq $true }).Count
$passRate = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

foreach ($check in $ValidationResults.Keys) {
    $status = if ($ValidationResults[$check]) { "✅ PASS" } else { "❌ FAIL" }
    $color = if ($ValidationResults[$check]) { "Green" } else { "Red" }
    Write-ColoredOutput "$status $check" $color
}

Write-ColoredOutput "`nOverall Score: $passedChecks/$totalChecks ($passRate%)" $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 60) { "Yellow" } else { "Red" })

# Recommendations
Write-ColoredOutput "`n💡 Next Steps:" "Blue"
if ($passRate -eq 100) {
    Write-ColoredOutput "🎉 Perfect! Your Docker Hub integration is fully configured." "Green"
    Write-ColoredOutput "Ready to push to GitHub and trigger the pipeline!" "Green"
} elseif ($passRate -ge 80) {
    Write-ColoredOutput "⚠️ Almost ready! Fix the failing items and re-run validation." "Yellow"
} else {
    Write-ColoredOutput "❌ Major issues detected. Please review and fix the failing items." "Red"
}

Write-ColoredOutput "`n🔗 Helpful Commands:" "Blue"
Write-ColoredOutput "- Test Docker Hub: .\scripts\test-docker-hub.ps1" "White"
Write-ColoredOutput "- Run setup wizard: bash .\scripts\docker-hub-wizard.sh" "White"  
Write-ColoredOutput "- Check pipeline: https://github.com/fatima-kz/devopslab/actions" "White"
Write-ColoredOutput "- View Docker Hub: https://hub.docker.com/r/fatima-kz/todo-spring-boot-app" "White"

if ($FixIssues) {
    Write-ColoredOutput "`n🔧 Auto-fix not implemented yet. Please fix issues manually." "Yellow"
}