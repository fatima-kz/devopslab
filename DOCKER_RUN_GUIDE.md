# 🐳 Docker Run Guide - Todo Application

Complete guide to run the Todo application using Docker and Docker Compose.

---

## 📋 Prerequisites

- **Docker Desktop** installed and running
- **Git** (to clone the repository)
- **Port availability**: 8081, 3306, 6379

---

## 🚀 Quick Start (5 Steps)

### Step 1: Clone the Repository

```powershell
git clone https://github.com/fatima-kz/devopslab.git
cd devopslab\mysql-spring-boot-todo
```

### Step 2: Configure Environment Variables

Copy the example environment file and update with your values:

```powershell
Copy-Item .env.example .env
```

Edit `.env` file with your credentials (or keep defaults for testing):

```env
MYSQL_ROOT_PASSWORD=mysqlpass
MYSQL_DATABASE=tododb
MYSQL_USER=username
MYSQL_PASSWORD=mysqlpass
```

### Step 3: Build and Start Services

```powershell
docker-compose up -d --build
```

This will:
- Build the Spring Boot application (multi-stage build)
- Start MySQL database with persistent storage
- Start Redis cache
- Start the Todo application
- Create network and volumes

### Step 4: Verify Services are Running

```powershell
docker-compose ps
```

You should see 3 services running:
- `mysql-todo` (MySQL 5.7)
- `redis-todo` (Redis 7)
- `todo-app` (Spring Boot App)

### Step 5: Access the Application

Open your browser and navigate to:

**Application URL:** http://localhost:8081

**Health Check:** http://localhost:8081/actuator/health

---

## 📊 Monitoring & Logs

### View All Logs

```powershell
docker-compose logs -f
```

### View Specific Service Logs

```powershell
# Application logs
docker-compose logs -f app

# MySQL logs
docker-compose logs -f mysql

# Redis logs
docker-compose logs -f redis
```

### Check Service Health

```powershell
# Check all containers
docker-compose ps

# Check specific container health
docker inspect mysql-todo --format='{{.State.Health.Status}}'
docker inspect redis-todo --format='{{.State.Health.Status}}'
docker inspect todo-app --format='{{.State.Health.Status}}'
```

---

## 🔧 Common Operations

### Stop Services (Keep Data)

```powershell
docker-compose stop
```

### Start Stopped Services

```powershell
docker-compose start
```

### Restart All Services

```powershell
docker-compose restart
```

### Restart Specific Service

```powershell
docker-compose restart app
```

### Rebuild Application After Code Changes

```powershell
docker-compose up -d --build app
```

### Stop and Remove Everything (Including Volumes)

```powershell
docker-compose down -v
```

⚠️ **Warning:** This deletes all database data!

### Stop Without Removing Volumes (Keep Data)

```powershell
docker-compose down
```

---

## 🗄️ Database Management

### Access MySQL Container

```powershell
docker exec -it mysql-todo mysql -u username -pmysqlpass tododb
```

### View Database Tables

```sql
SHOW TABLES;
SELECT * FROM todo_item;
```

### Exit MySQL

```sql
exit;
```

### Backup Database

```powershell
docker exec mysql-todo mysqldump -u username -pmysqlpass tododb > backup.sql
```

### Restore Database

```powershell
Get-Content backup.sql | docker exec -i mysql-todo mysql -u username -pmysqlpass tododb
```

---

## 🔴 Redis Cache Management

### Access Redis CLI

```powershell
docker exec -it redis-todo redis-cli
```

### Check Cached Items

```redis
KEYS *
GET todos
```

### Clear Cache

```redis
FLUSHALL
```

### Exit Redis

```redis
exit
```

---

## 🐛 Troubleshooting

### Issue: Port Already in Use

**Error:** `Bind for 0.0.0.0:8081 failed: port is already allocated`

**Solution:**

```powershell
# Find process using port 8081
netstat -ano | findstr :8081

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
# ports:
#   - "8082:8080"  # Change 8081 to 8082
```

### Issue: Container Keeps Restarting

```powershell
# Check logs for errors
docker-compose logs app

# Common fixes:
# 1. Wait for MySQL to be ready (check mysql logs)
docker-compose logs mysql

# 2. Verify .env file exists and has correct values
Get-Content .env

# 3. Rebuild without cache
docker-compose build --no-cache app
docker-compose up -d
```

### Issue: Database Connection Failed

```powershell
# Verify MySQL is healthy
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Test connection manually
docker exec -it mysql-todo mysql -u username -pmysqlpass tododb

# Restart services in order
docker-compose restart mysql
docker-compose restart app
```

### Issue: Cannot Access Application

**Check 1:** Verify container is running
```powershell
docker-compose ps
```

**Check 2:** Check app health
```powershell
curl http://localhost:8081/actuator/health
```

**Check 3:** View app logs
```powershell
docker-compose logs app
```

### Issue: Slow Build Times

```powershell
# Clean Docker cache
docker system prune -a

# Rebuild with fresh dependencies
docker-compose build --no-cache
docker-compose up -d
```

---

## 🔍 Inspect Container Details

### View Container Configuration

```powershell
docker inspect todo-app
docker inspect mysql-todo
docker inspect redis-todo
```

### View Networks

```powershell
docker network ls
docker network inspect mysql-spring-boot-todo_todo-network
```

### View Volumes

```powershell
docker volume ls
docker volume inspect mysql-spring-boot-todo_mysql_data
docker volume inspect mysql-spring-boot-todo_redis_data
```

---

## 🧹 Cleanup Commands

### Remove Stopped Containers

```powershell
docker-compose down
```

### Remove All (Containers + Volumes)

```powershell
docker-compose down -v
```

### Clean Docker System

```powershell
# Remove unused containers, networks, images
docker system prune

# Remove everything including volumes
docker system prune -a --volumes
```

---

## 📈 Performance Testing

### Check Resource Usage

```powershell
docker stats
```

### Execute Commands Inside Container

```powershell
# App container
docker exec -it todo-app sh

# MySQL container
docker exec -it mysql-todo bash

# Redis container
docker exec -it redis-todo sh
```

---

## 🔄 Update Application

### After Code Changes

```powershell
# Stop app container
docker-compose stop app

# Rebuild and start
docker-compose up -d --build app

# View logs to verify
docker-compose logs -f app
```

### Update Docker Images

```powershell
# Pull latest base images
docker-compose pull

# Rebuild with latest images
docker-compose up -d --build
```

---

## ✅ Verification Checklist

After starting the application, verify:

- [ ] All 3 containers are running: `docker-compose ps`
- [ ] Application accessible: http://localhost:8081
- [ ] Health check passes: http://localhost:8081/actuator/health
- [ ] MySQL is healthy: `docker inspect mysql-todo --format='{{.State.Health.Status}}'`
- [ ] Redis is healthy: `docker inspect redis-todo --format='{{.State.Health.Status}}'`
- [ ] Can create new todos
- [ ] Data persists after restart
- [ ] No errors in logs: `docker-compose logs`

---

## 📚 Additional Resources

- **Docker Compose Docs:** https://docs.docker.com/compose/
- **Spring Boot Actuator:** https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html
- **MySQL Docker:** https://hub.docker.com/_/mysql
- **Redis Docker:** https://hub.docker.com/_/redis

---

## 🎯 Production Deployment

For production environments, use Docker Secrets instead of `.env` files.

See: [`DOCKER_SECRETS_GUIDE.md`](./DOCKER_SECRETS_GUIDE.md)

---

## 💡 Quick Reference

| Command | Description |
|---------|-------------|
| `docker-compose up -d` | Start all services in background |
| `docker-compose down` | Stop and remove containers |
| `docker-compose logs -f` | View live logs |
| `docker-compose ps` | List running containers |
| `docker-compose restart` | Restart all services |
| `docker-compose build` | Rebuild images |
| `docker-compose exec app sh` | Access app container shell |

---

**Need Help?** Check the troubleshooting section or view logs with `docker-compose logs -f`
