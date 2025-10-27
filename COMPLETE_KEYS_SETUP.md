# 🔑 Complete Keys & Secrets Setup Guide

This guide will walk you through getting ALL the keys you need, step by step, with visual descriptions.

## 🐳 Part 1: Docker Hub Setup (Required)

### Step 1: Create Docker Hub Account
```
🌐 Go to: https://hub.docker.com/
👆 Click: "Sign Up" (blue button, top right)
📝 Fill in:
   - Username: fatima-kz (or your choice)
   - Email: your-email@example.com  
   - Password: (create a strong password)
✅ Click: "Sign Up"
📧 Check your email and click the verification link
```

### Step 2: Create Repository
```
🏠 After login, you'll see the Docker Hub dashboard
👆 Click: "Create Repository" (big blue button)
📝 Fill in:
   - Repository name: todo-spring-boot-app
   - Description: DevOps Lab - Spring Boot Todo Application
   - Visibility: Public ✅ (must be public for free accounts)
✅ Click: "Create"
```

### Step 3: Generate Access Token (This is your secret!)
```
👤 Click: Your profile picture (top right corner)
⚙️ Select: "Account Settings"
🔒 Click: "Security" (left sidebar)
🆕 Click: "New Access Token" (blue button)
📝 Fill in:
   - Token description: GitHub-Actions-DevOps-Lab
   - Access permissions: ✅ Read ✅ Write ✅ Delete
🎯 Click: "Generate"

⚠️ CRITICAL: Copy the token immediately!
📋 It looks like: dckr_pat_abcd1234567890efgh...
💾 Save it temporarily in Notepad - you'll need it in the next step!
```

## 🔐 Part 2: GitHub Secrets Setup (Required)

### Step 4: Navigate to Repository Settings
```
🌐 Go to: https://github.com/fatima-kz/devopslab
👆 Click: "Settings" tab (at the top, next to "Code", "Issues", etc.)
📜 Scroll down in left sidebar
👆 Click: "Secrets and variables"
🎯 Click: "Actions"
```

### Step 5: Add Docker Hub Username
```
🆕 Click: "New repository secret" (green button)
📝 Enter:
   - Name: DOCKER_USERNAME
   - Secret: fatima-kz (your Docker Hub username)
✅ Click: "Add secret"
```

### Step 6: Add Docker Hub Access Token
```
🆕 Click: "New repository secret" again
📝 Enter:
   - Name: DOCKER_PASSWORD
   - Secret: (paste the dckr_pat_... token you copied earlier)
✅ Click: "Add secret"
```

## ☁️ Part 3: Cloud Platform Keys (Optional but Recommended)

### Option A: Railway Setup (Easier)
```
🌐 Go to: https://railway.app/
🔗 Click: "Login with GitHub" (easiest option)
📝 Create new project:
   👆 Click: "New Project"
   📦 Select: "Empty Project" 
   📝 Name: devops-todo-app
🔧 Get API Token:
   ⚙️ Go to project settings (gear icon)
   🎫 Click: "Tokens" tab
   🆕 Click: "Create Token"
   📝 Description: GitHub-Actions-DevOps
   📋 Copy the token (railway_...)

🔐 Add to GitHub:
   - Name: RAILWAY_TOKEN
   - Secret: (paste the Railway token)
```

### Option B: Render Setup (Alternative)
```
🌐 Go to: https://render.com/
📝 Sign up or login with GitHub
🔧 Get API Key:
   👤 Go to Account Settings (top right)
   🔑 Click: "API Keys"
   🆕 Click: "Create API Key"
   📝 Description: GitHub-Actions
   📋 Copy the generated key

🔐 Add to GitHub:
   - Name: RENDER_API_KEY
   - Secret: (paste the Render API key)
```

## ✅ Part 4: Verification Checklist

After completing the above steps, you should have:

### In Docker Hub:
- ✅ Account created and verified
- ✅ Repository `fatima-kz/todo-spring-boot-app` exists
- ✅ Access token generated and copied

### In GitHub Repository Secrets:
- ✅ DOCKER_USERNAME = fatima-kz
- ✅ DOCKER_PASSWORD = dckr_pat_...
- ✅ (Optional) RAILWAY_TOKEN = railway_...
- ✅ (Optional) RENDER_API_KEY = rnd_...

## 🧪 Part 5: Test Everything

### Run the verification script:
```powershell
# In PowerShell, navigate to your project folder and run:
.\scripts\verify-setup.ps1
```

### Manual test:
```bash
# Test Docker Hub login
docker login
# Enter username: fatima-kz
# Enter password: (paste your dckr_pat_... token)

# If successful, you'll see: "Login Succeeded"
```

## 🚀 Part 6: Trigger Your Pipeline

Once all secrets are added:

```bash
# Make a small change to trigger the pipeline
echo "# Pipeline test" >> README.md
git add .
git commit -m "feat: trigger CI/CD pipeline with secrets"
git push origin main
```

Then watch your pipeline run:
- 🌐 Go to: https://github.com/fatima-kz/devopslab/actions
- 👀 Watch the "Complete DevOps CI/CD Pipeline" workflow run
- 🎉 All 5 stages should complete successfully!

## 🆘 Troubleshooting

### "Authentication failed" when pushing Docker image:
- ❌ Wrong username: Check DOCKER_USERNAME matches exactly
- ❌ Wrong token: Regenerate Docker Hub access token
- ❌ Token permissions: Ensure Read+Write+Delete permissions

### "Repository not found":
- ❌ Repository doesn't exist: Create `fatima-kz/todo-spring-boot-app` in Docker Hub
- ❌ Wrong name: Check repository name matches exactly
- ❌ Private repo: Must be public for free accounts

### GitHub secrets not working:
- ❌ Wrong secret name: Must be exact: `DOCKER_USERNAME`, `DOCKER_PASSWORD`
- ❌ Typos: Check for extra spaces or characters
- ❌ Wrong repository: Make sure you're in `fatima-kz/devopslab`

## 📞 Need Help?

If you get stuck:
1. 📧 Check the error messages in GitHub Actions logs
2. 🔍 Run the verification script: `.\scripts\verify-setup.ps1`
3. 📖 Review this guide step by step
4. 🔄 Try regenerating the Docker Hub access token

## 🎯 Success Indicators

You'll know everything is working when:
- ✅ GitHub Actions pipeline runs all 5 stages
- ✅ Docker image appears in your Docker Hub repository
- ✅ No authentication errors in the logs
- ✅ Green checkmarks on all pipeline stages

**You've got this! Follow each step carefully and you'll have it working in no time! 🚀**