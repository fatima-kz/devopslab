# 🚀 DevOps Lab - MySQL Spring Boot Todo Application

[![CI/CD Pipeline](https://github.com/fatima-kz/devopslab/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/fatima-kz/devopslab/actions/workflows/ci-cd.yml)
[![Docker Hub](https://img.shields.io/docker/v/fatimakz/todo-spring-boot-app?label=Docker%20Hub&logo=docker)](https://hub.docker.com/r/fatimakz/todo-spring-boot-app)

A comprehensive DevOps implementation of a Spring Boot Todo application featuring:

- 🏗️ **Multi-stage Docker builds** for optimized containerization
- 🔄 **5-stage CI/CD pipeline** with GitHub Actions
- 🐳 **Docker Compose** orchestration with MySQL persistence
- 🔐 **Secrets management** for secure deployments
- 🛡️ **Security scanning** with Trivy vulnerability detection
- 📊 **Health monitoring** with Spring Boot Actuator

## 📋 Table of Contents

- [🚀 Quick Start](#-quick-start)
- [🏗️ Architecture Overview](#️-architecture-overview)
- [🐳 Docker Setup](#-docker-setup)
- [🔄 CI/CD Pipeline](#-cicd-pipeline)
- [🔐 Security & Secrets](#-security--secrets)
- [📊 Monitoring & Health Checks](#-monitoring--health-checks)
- [🛠️ Development Setup](#️-development-setup)
- [📚 Documentation](#-documentation)

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Git

### Run with Docker Compose
```bash
# Clone the repository
git clone https://github.com/fatima-kz/devopslab.git
cd mysql-spring-boot-todo

# Start the application stack
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f app
```

### Access the Application
- **Main Application**: http://localhost:8081
- **Health Check**: http://localhost:8081/actuator/health
- **Application Info**: http://localhost:8081/actuator/info

### Pull from Docker Hub
```bash
# Pull the latest image
docker pull fatimakz/todo-spring-boot-app:latest

# Run with custom database
docker run -d \
  -p 8081:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://your-db:3306/tododb \
  -e SPRING_DATASOURCE_USERNAME=your-user \
  -e SPRING_DATASOURCE_PASSWORD=your-pass \
  fatimakz/todo-spring-boot-app:latest
```

## 🏗️ Architecture Overview

### Application Stack
```
┌─────────────────────┐
│   Frontend (Web)    │ ← Thymeleaf Templates
├─────────────────────┤
│   Spring Boot App   │ ← REST API & Business Logic
├─────────────────────┤
│   Spring Data JPA   │ ← Data Access Layer
├─────────────────────┤
│   MySQL Database    │ ← Persistent Storage
└─────────────────────┘
```

### DevOps Architecture
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   GitHub    │───▶│ GitHub       │───▶│ Docker Hub  │
│ Repository  │    │ Actions      │    │ Registry    │
└─────────────┘    │ CI/CD        │    └─────────────┘
                   └──────────────┘           │
                          │                   │
                   ┌──────────────┐    ┌─────────────┐
                   │  Security    │    │ Production  │
                   │  Scanning    │    │ Deployment  │
                   └──────────────┘    └─────────────┘
```

### Technology Stack
- **Backend**: Java 8, Spring Boot 1.5.3, Spring Data JPA
- **Database**: MySQL 5.7 with persistent volumes
- **Frontend**: Thymeleaf, HTML5, Bootstrap CSS
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions (5-stage pipeline)
- **Registry**: Docker Hub
- **Security**: Trivy vulnerability scanning
- **Monitoring**: Spring Boot Actuator

## 🐳 Docker Setup

### Multi-Stage Dockerfile
```dockerfile
# Stage 1: Build Environment (Maven + OpenJDK 8)
FROM maven:3.8.6-openjdk-8 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime Environment (OpenJDK 8 JRE)
FROM openjdk:8-jre-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY --from=build /app/target/TodoDemo-0.0.1-SNAPSHOT.war app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

### Docker Compose Services

#### Application Service
```yaml
app:
  build: .
  ports: ["8081:8080"]
  environment:
    SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/tododb
    SPRING_DATASOURCE_USERNAME: username
    SPRING_DATASOURCE_PASSWORD: mysqlpass
  depends_on:
    mysql: { condition: service_healthy }
  restart: unless-stopped
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
```

#### Database Service
```yaml
mysql:
  image: mysql:5.7
  environment:
    MYSQL_DATABASE: tododb
    MYSQL_USER: username
    MYSQL_PASSWORD: mysqlpass
  volumes:
    - mysql_data:/var/lib/mysql  # Persistent storage
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
```

### Docker Commands
```bash
# Build image locally
docker build -t todo-app .

# Run container
docker run -d -p 8081:8080 todo-app

# Check container health
docker ps
docker logs <container-id>

# Access container shell
docker exec -it <container-id> /bin/sh
```

## 🔄 CI/CD Pipeline

### 5-Stage GitHub Actions Workflow

#### 🔨 Stage 1: Build & Install Dependencies
```yaml
- Checkout source code
- Setup Java 8 (Temurin distribution)
- Cache Maven dependencies (~/.m2)
- Compile source code: mvn clean compile
- Download dependencies: mvn dependency:go-offline
- Upload build artifacts for next stages
```

#### 🔍 Stage 2: Lint & Security Scan
```yaml
- Maven code validation
- Trivy filesystem security scanning
- Generate vulnerability reports
- Continue on warnings (non-blocking)
```

#### 🧪 Stage 3: Test with Database Service
```yaml
Services:
  mysql:
    image: mysql:5.7
    env: [MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD]
    
Steps:
- Wait for MySQL readiness (health check)
- Run unit tests: mvn test
- Run integration tests: mvn verify  
- Generate coverage reports (JaCoCo)
```

#### 🐳 Stage 4: Build Docker Image
```yaml
- Setup Docker Buildx for advanced builds
- Login to Docker Hub (secrets-based auth)
- Extract metadata for image tagging
- Build multi-platform image (AMD64)
- Push to Docker Hub registry
- Run container security scan
- Cache Docker layers for performance
```

#### 🚀 Stage 5: Deploy (Conditional)
```yaml
Conditions:
- Branch: main only
- Event: push (not PR)
- All previous stages: success

Steps:
- Pull latest image from registry
- Verify image integrity
- Health check deployed services
- Generate deployment summary
```

### Pipeline Triggers
```yaml
on:
  push:
    branches: [ main, develop ]      # Auto-trigger on push
  pull_request:
    branches: [ main ]               # Test on PRs
  workflow_dispatch:                 # Manual trigger
    inputs:
      deploy_to_production: boolean  # Optional production deploy
```

### Image Tagging Strategy
```yaml
Generated Tags:
- fatimakz/todo-spring-boot-app:main           # Branch name
- fatimakz/todo-spring-boot-app:pr-1           # PR number  
- fatimakz/todo-spring-boot-app:commit-abc123  # Git SHA
- fatimakz/todo-spring-boot-app:latest         # Main branch only
```

## 🔐 Security & Secrets

### GitHub Repository Secrets
Configure in: `Repository Settings → Secrets and variables → Actions`

```yaml
DOCKER_USERNAME: "fatimakz"
  Purpose: Docker Hub registry authentication
  Usage: Login for image push/pull operations

DOCKER_PASSWORD: "your-docker-hub-access-token"  
  Purpose: Docker Hub access token (NOT password)
  Security: Revocable, scoped permissions
  Best Practice: Use tokens instead of passwords
```

### Security Scanning
```yaml
Trivy Security Scanner:
- Filesystem scanning for source code vulnerabilities
- Container image scanning for runtime vulnerabilities  
- CVE database updates for latest threat intelligence
- SARIF report generation for GitHub Security tab
- Configurable severity levels (LOW, MEDIUM, HIGH, CRITICAL)
```

### Security Best Practices
- ✅ No hardcoded credentials in source code
- ✅ Environment variable-based configuration
- ✅ Docker Hub token authentication
- ✅ Least privilege access principles
- ✅ Regular dependency updates via Dependabot
- ✅ Multi-stage builds for smaller attack surface

## 📊 Monitoring & Health Checks

### Application Health Endpoints
```yaml
Spring Boot Actuator Endpoints:
- /actuator/health     # Application health status
- /actuator/info       # Application information
- /actuator/metrics    # Application metrics (if enabled)

Health Check Response:
{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "diskSpace": { "status": "UP" }
  }
}
```

### Container Health Checks
```yaml
Application Container:
  test: curl -f http://localhost:8080/actuator/health
  interval: 30s
  timeout: 10s
  retries: 3

Database Container:
  test: mysqladmin ping -h localhost -u username -p$MYSQL_PASSWORD
  interval: 10s
  timeout: 5s
  retries: 3
```

### Monitoring Commands
```bash
# Check service status
docker-compose ps

# View application logs
docker-compose logs -f app

# View database logs  
docker-compose logs -f mysql

# Monitor resource usage
docker stats

# Health check verification
curl http://localhost:8081/actuator/health | jq
```

## 🛠️ Development Setup

### Local Development (Manual)
```bash
# Prerequisites
- Java 8 JDK
- Maven 3.6+
- MySQL 5.7+

# Setup database
mysql -u root -p
CREATE DATABASE tododb;
CREATE USER 'username'@'localhost' IDENTIFIED BY 'mysqlpass';
GRANT ALL PRIVILEGES ON tododb.* TO 'username'@'localhost';

# Run application
./mvnw clean compile
./mvnw spring-boot:run

# Access: http://localhost:8080
```

### Development with Docker
```bash
# Start only database
docker-compose up -d mysql

# Run app locally (connects to containerized DB)
./mvnw spring-boot:run

# Or run everything in containers
docker-compose up -d
```

### Testing
```bash
# Unit tests
./mvnw test

# Integration tests  
./mvnw verify

# With coverage report
./mvnw clean test jacoco:report
open target/site/jacoco/index.html
```

### Build Optimization
```yaml
Maven Wrapper Benefits:
- Consistent Maven version across environments
- No need to install Maven locally
- Automatic Maven download and setup

Docker Layer Caching:
- Separate COPY for pom.xml (dependencies layer)
- Source code copied after dependencies
- Faster rebuilds when only code changes
```

## 📚 Documentation

### Project Documentation
- **[devops_report.md](./devops_report.md)** - Comprehensive DevOps implementation report
- **[DOCKER_HUB_SETUP.md](./DOCKER_HUB_SETUP.md)** - Docker Hub configuration guide  
- **[GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md)** - GitHub secrets configuration
- **[docker-compose.yml](./docker-compose.yml)** - Service orchestration configuration
- **[Dockerfile](./Dockerfile)** - Container build specification

### API Documentation
```yaml
Todo Item Endpoints:
GET    /                    # List all todos (Web UI)
POST   /addtodo             # Add new todo item
POST   /updatetodo/{id}     # Update todo item  
POST   /deletetodo/{id}     # Delete todo item

Health & Monitoring:
GET    /actuator/health     # Health check endpoint
GET    /actuator/info       # Application information
```

### Configuration Files
```yaml
Application Configuration:
- application.properties     # Spring Boot configuration
- pom.xml                   # Maven dependencies & plugins

Docker Configuration:  
- Dockerfile               # Multi-stage container build
- docker-compose.yml       # Service orchestration
- .dockerignore           # Build context optimization

CI/CD Configuration:
- .github/workflows/ci-cd.yml        # Main pipeline
- .github/workflows/docker-hub-test.yml  # Docker connectivity test
- .github/dependabot.yml             # Dependency updates
```

## 🚀 Deployment Environments

### Development Environment
```bash
# Local development with hot reload
docker-compose -f docker-compose.dev.yml up -d

# Access development tools
http://localhost:8081/actuator/health
```

### Production Environment  
```bash
# Pull latest production image
docker pull fatimakz/todo-spring-boot-app:latest

# Deploy to production
docker-compose -f docker-compose.prod.yml up -d

# Health verification
curl https://your-domain.com/actuator/health
```

### Environment Variables
```yaml
Development:
- SPRING_PROFILES_ACTIVE=dev
- LOGGING_LEVEL_ROOT=DEBUG
- SPRING_JPA_SHOW_SQL=true

Production:  
- SPRING_PROFILES_ACTIVE=prod
- LOGGING_LEVEL_ROOT=WARN
- SPRING_JPA_SHOW_SQL=false
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`  
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is part of a DevOps Lab assignment and is for educational purposes.

## 👥 Authors

- **Fatima** - [@fatima-kz](https://github.com/fatima-kz)

## 🎯 DevOps Achievements

✅ **Containerization** - Multi-stage Docker builds with optimization  
✅ **Orchestration** - Docker Compose with persistent volumes  
✅ **CI/CD Pipeline** - 5-stage GitHub Actions workflow  
✅ **Cloud Registry** - Docker Hub integration with automated pushes  
✅ **Security** - Vulnerability scanning and secrets management  
✅ **Monitoring** - Health checks and observability  
✅ **Documentation** - Comprehensive project documentation  
✅ **Best Practices** - Industry-standard DevOps implementation

---

🚀 **Ready for production deployment with enterprise-grade DevOps practices!**
