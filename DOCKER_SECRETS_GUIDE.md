# 🔐 Docker Secrets Setup Guide

This guide shows you how to use **Docker Secrets** for production deployments as an alternative to `.env` files.

## 📋 What are Docker Secrets?

Docker Secrets provide secure storage for sensitive data like passwords, API keys, and certificates. They are:
- Encrypted at rest and in transit
- Only available to services that explicitly grant access
- More secure than environment variables

---

## 🚀 Quick Setup Steps

### 1️⃣ Initialize Docker Swarm (Required for Secrets)

```powershell
docker swarm init
```

### 2️⃣ Create Secrets

Create each secret from a value:

```powershell
# MySQL Root Password
echo "your_secure_root_password" | docker secret create mysql_root_password -

# MySQL Database Name
echo "tododb" | docker secret create mysql_database -

# MySQL User
echo "todouser" | docker secret create mysql_user -

# MySQL Password
echo "your_secure_user_password" | docker secret create mysql_password -
```

### 3️⃣ Verify Secrets Created

```powershell
docker secret ls
```

---

## 📝 Update docker-compose.yml for Secrets

Create a new file `docker-compose.secrets.yml`:

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:5.7
    secrets:
      - mysql_root_password
      - mysql_database
      - mysql_user
      - mysql_password
    environment:
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/mysql_root_password
      MYSQL_DATABASE_FILE: /run/secrets/mysql_database
      MYSQL_USER_FILE: /run/secrets/mysql_user
      MYSQL_PASSWORD_FILE: /run/secrets/mysql_password
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - todo-network

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - todo-network
    command: redis-server --appendonly yes

  app:
    build:
      context: .
      dockerfile: Dockerfile
    secrets:
      - mysql_database
      - mysql_user
      - mysql_password
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/tododb
      SPRING_DATASOURCE_USERNAME_FILE: /run/secrets/mysql_user
      SPRING_DATASOURCE_PASSWORD_FILE: /run/secrets/mysql_password
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PORT: 6379
    depends_on:
      - mysql
      - redis
    networks:
      - todo-network
    ports:
      - "8081:8080"

secrets:
  mysql_root_password:
    external: true
  mysql_database:
    external: true
  mysql_user:
    external: true
  mysql_password:
    external: true

volumes:
  mysql_data:
  redis_data:

networks:
  todo-network:
    driver: overlay
```

---

## 🏃 Deploy with Secrets

### Deploy Stack

```powershell
docker stack deploy -c docker-compose.secrets.yml todoapp
```

### Check Services

```powershell
docker stack ps todoapp
docker service ls
```

### View Logs

```powershell
docker service logs todoapp_app
docker service logs todoapp_mysql
```

---

## 🔄 Update or Remove Secrets

### Update a Secret

```powershell
# Remove old secret
docker secret rm mysql_password

# Create new secret
echo "new_secure_password" | docker secret create mysql_password -

# Redeploy service
docker service update --secret-rm mysql_password --secret-add mysql_password todoapp_app
```

### Remove Stack

```powershell
docker stack rm todoapp
```

### Remove Secrets

```powershell
docker secret rm mysql_root_password mysql_database mysql_user mysql_password
```

---

## 📊 Comparison: .env vs Docker Secrets

| Feature | `.env` File | Docker Secrets |
|---------|-------------|----------------|
| **Security** | Plain text on disk | Encrypted at rest & in transit |
| **Use Case** | Development/Testing | Production |
| **Setup** | Simple | Requires Docker Swarm |
| **Access Control** | File permissions | Service-level grants |
| **Rotation** | Manual file edit | Versioned updates |

---

## ✅ Best Practices

1. **Use `.env` for local development**
2. **Use Docker Secrets for production**
3. **Never commit secrets to Git** (add `.env` to `.gitignore`)
4. **Rotate secrets regularly**
5. **Use least-privilege access** (only grant secrets to services that need them)

---

## 🔧 Troubleshooting

### Error: "This node is not a swarm manager"
```powershell
docker swarm init
```

### Error: Secret already exists
```powershell
docker secret rm secret_name
# Then recreate it
```

### View secret metadata (not content)
```powershell
docker secret inspect mysql_password
```

---

## 📚 Additional Resources

- [Docker Secrets Documentation](https://docs.docker.com/engine/swarm/secrets/)
- [Docker Swarm Mode](https://docs.docker.com/engine/swarm/)
- [Security Best Practices](https://docs.docker.com/engine/security/)
