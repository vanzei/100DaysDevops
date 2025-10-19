# Docker Compose Complete Guide and Reference

## Table of Contents

1. [Introduction to Docker Compose](#introduction-to-docker-compose)
2. [Dockerfile vs Docker Compose](#dockerfile-vs-docker-compose)
3. [When to Use What](#when-to-use-what)
4. [Benefits of Docker Compose](#benefits-of-docker-compose)
5. [Docker Compose File Structure](#docker-compose-file-structure)
6. [Essential Docker Compose Commands](#essential-docker-compose-commands)
7. [Real-World Examples](#real-world-examples)
8. [Advanced Docker Compose Features](#advanced-docker-compose-features)
9. [Challenge 44 Solution](#challenge-44-solution)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)
12. [Production Considerations](#production-considerations)

## Introduction to Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application's services, networks, and volumes. Then, with a single command, you create and start all the services from your configuration.

### Core Concepts

**Orchestration**: Manage multiple containers as a single application
**Declarative Configuration**: Define what you want, not how to achieve it
**Service Discovery**: Containers can communicate by service name
**Environment Management**: Different configurations for different environments

### Key Components

- **Services**: Individual containers that make up your application
- **Networks**: Communication channels between services
- **Volumes**: Persistent data storage
- **Secrets**: Sensitive data management
- **Configs**: Configuration file management

## Dockerfile vs Docker Compose

Understanding the difference between Dockerfile and Docker Compose is crucial for effective containerization.

### Dockerfile

**Purpose**: Defines how to **build** a custom Docker image

**Scope**: Single image creation

**Contains**: 
- Base image selection
- Software installation
- File copying
- Environment configuration
- Default commands

**Example Dockerfile**:
```dockerfile
FROM httpd:latest
COPY ./my-website/ /usr/local/apache2/htdocs/
RUN chmod -R 755 /usr/local/apache2/htdocs/
EXPOSE 80
CMD ["httpd-foreground"]
```

**Use Case**: When you need to customize an existing image or create a completely new image

### Docker Compose

**Purpose**: Defines how to **run** one or multiple containers

**Scope**: Multi-container application orchestration

**Contains**:
- Service definitions
- Port mappings
- Volume mounts
- Environment variables
- Network configurations

**Example Docker Compose**:
```yaml
version: '3.8'
services:
  web:
    image: httpd:latest
    ports:
      - "8084:80"
    volumes:
      - ./website:/usr/local/apache2/htdocs
```

**Use Case**: When you need to run containers with specific configurations or multiple related containers

### Key Differences Table

| Aspect | Dockerfile | Docker Compose |
|--------|------------|----------------|
| **Purpose** | Build images | Run containers |
| **Scope** | Single image | Multiple services |
| **Output** | Docker image | Running application |
| **Command** | `docker build` | `docker-compose up` |
| **Configuration** | Build instructions | Runtime configuration |
| **Networking** | Not handled | Automatic networks |
| **Dependencies** | Not handled | Service dependencies |

## When to Use What

### Use Dockerfile When:

- Creating custom application images
- Installing specific software packages
- Modifying existing images
- Building from source code
- Creating reusable base images

```dockerfile
# Custom Node.js application
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Use Docker Compose When:

- Running existing images with specific configurations
- Orchestrating multi-container applications
- Managing development environments
- Defining service relationships
- Handling complex networking and volumes

```yaml
# Multi-service application
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: secret
```

### Use Both Together When:

- Building custom images AND orchestrating services
- Complex applications with custom components
- Production deployments with custom configurations

```yaml
version: '3.8'
services:
  web:
    build:                    # Use Dockerfile to build
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - db
  db:
    image: postgres:13        # Use existing image
```

## Benefits of Docker Compose

### 1. Simplified Multi-Container Management

**Without Docker Compose** (Manual approach):
```bash
# Start database
docker run -d --name db \
  -e POSTGRES_PASSWORD=secret \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:13

# Start Redis
docker run -d --name cache redis:alpine

# Start application
docker run -d --name app \
  -p 3000:3000 \
  --link db:database \
  --link cache:redis \
  -e DATABASE_URL=postgresql://db:5432/myapp \
  myapp:latest

# Start web server
docker run -d --name web \
  -p 80:80 \
  --link app:backend \
  nginx:alpine
```

**With Docker Compose**:
```yaml
version: '3.8'
services:
  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres_data:/var/lib/postgresql/data

  cache:
    image: redis:alpine

  app:
    image: myapp:latest
    environment:
      DATABASE_URL: postgresql://db:5432/myapp
    depends_on:
      - db
      - cache

  web:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      - app

volumes:
  postgres_data:
```

```bash
# Single command to start everything
docker-compose up -d
```

### 2. Environment Consistency

**Development Environment**:
```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app                # Live code reloading
    environment:
      - DEBUG=true
      - LOG_LEVEL=debug
    ports:
      - "3000:3000"
```

**Production Environment**:
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  app:
    image: myapp:v1.2.3       # Specific version
    environment:
      - DEBUG=false
      - LOG_LEVEL=info
    restart: unless-stopped
    deploy:
      replicas: 3
```

### 3. Built-in Service Discovery

Services can communicate by name without complex networking setup:

```yaml
version: '3.8'
services:
  web:
    image: nginx
    # Can reach app service at http://app:3000
    
  app:
    image: myapp
    # Can reach database at postgresql://db:5432
    
  db:
    image: postgres
```

### 4. Simplified Development Workflow

```bash
# Start development environment
docker-compose up

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f

# Scale services
docker-compose up --scale app=3

# Stop everything
docker-compose down

# Rebuild and restart
docker-compose up --build
```

### 5. Volume and Network Management

```yaml
version: '3.8'
services:
  app:
    image: myapp
    networks:
      - frontend
      - backend
    volumes:
      - app_data:/app/data

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true          # No external access

volumes:
  app_data:
    driver: local
```

## Docker Compose File Structure

### Basic Structure

```yaml
version: '3.8'              # Compose file format version

services:                   # Container definitions
  service1:
    # Service configuration
  service2:
    # Service configuration

networks:                   # Custom networks (optional)
  network1:
    # Network configuration

volumes:                    # Named volumes (optional)
  volume1:
    # Volume configuration

secrets:                    # Secrets management (optional)
  secret1:
    # Secret configuration

configs:                    # Configuration files (optional)
  config1:
    # Config configuration
```

### Service Configuration Options

```yaml
services:
  myapp:
    # Image specification
    image: nginx:alpine                    # Use existing image
    build: .                              # Build from Dockerfile
    build:                                # Advanced build options
      context: .
      dockerfile: Dockerfile.prod
      args:
        - VERSION=1.0.0

    # Container configuration
    container_name: my-nginx              # Specific container name
    hostname: web-server                  # Container hostname
    restart: unless-stopped               # Restart policy

    # Networking
    ports:
      - "80:80"                          # Host:Container port mapping
      - "443:443"
    expose:
      - "8080"                           # Internal port exposure
    networks:
      - frontend
      - backend

    # Environment
    environment:
      - NODE_ENV=production
      - API_KEY=secret
    env_file:
      - .env                             # Load from file

    # Storage
    volumes:
      - ./data:/app/data                 # Host directory mount
      - app_volume:/app/storage          # Named volume mount
      - /etc/ssl:/etc/ssl:ro             # Read-only mount

    # Dependencies
    depends_on:
      - db
      - cache
    links:                               # Legacy linking (avoid)
      - db:database

    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

    # Health checks
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    # Security
    user: "1000:1000"                    # Run as specific user
    privileged: false                     # Disable privileged mode
    cap_add:
      - NET_ADMIN
    cap_drop:
      - ALL
```

## Essential Docker Compose Commands

### Basic Commands

```bash
# Start services
docker-compose up                        # Foreground
docker-compose up -d                     # Background (detached)
docker-compose up --build               # Rebuild images first
docker-compose up service1 service2     # Start specific services

# Stop services
docker-compose down                      # Stop and remove containers
docker-compose down -v                  # Also remove volumes
docker-compose stop                     # Stop without removing
docker-compose kill                     # Force stop

# Service management
docker-compose start                     # Start stopped services
docker-compose restart                  # Restart services
docker-compose pause                    # Pause services
docker-compose unpause                  # Unpause services
```

### Monitoring and Debugging

```bash
# View status
docker-compose ps                       # List services
docker-compose top                      # Show running processes

# View logs
docker-compose logs                     # All service logs
docker-compose logs -f                  # Follow logs
docker-compose logs service1           # Specific service logs
docker-compose logs --tail=50 service1 # Last 50 lines

# Execute commands
docker-compose exec service1 bash      # Interactive shell
docker-compose exec service1 ls -la    # Run specific command
docker-compose run service1 bash       # Run new container
```

### Advanced Commands

```bash
# Scaling
docker-compose up --scale web=3         # Scale web service to 3 instances

# Configuration
docker-compose config                   # Validate and view configuration
docker-compose config --services       # List services

# Images and builds
docker-compose build                    # Build all images
docker-compose build service1          # Build specific service
docker-compose pull                    # Pull latest images
docker-compose push                    # Push images to registry

# Environment-specific files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## Real-World Examples

### Example 1: LAMP Stack

```yaml
version: '3.8'

services:
  web:
    image: httpd:alpine
    container_name: apache-web
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/local/apache2/htdocs
      - ./httpd.conf:/usr/local/apache2/conf/httpd.conf
    depends_on:
      - php
    networks:
      - lamp-network

  php:
    image: php:8.1-fpm-alpine
    container_name: php-fpm
    volumes:
      - ./html:/var/www/html
      - ./php.ini:/usr/local/etc/php/php.ini
    networks:
      - lamp-network

  mysql:
    image: mysql:8.0
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: myapp
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - lamp-network

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    ports:
      - "8080:80"
    environment:
      PMA_HOST: mysql
      PMA_USER: root
      PMA_PASSWORD: rootpassword
    depends_on:
      - mysql
    networks:
      - lamp-network

networks:
  lamp-network:
    driver: bridge

volumes:
  mysql_data:
```

### Example 2: Node.js Microservices

```yaml
version: '3.8'

services:
  # API Gateway
  nginx:
    image: nginx:alpine
    container_name: api-gateway
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - user-service
      - order-service
      - product-service
    networks:
      - frontend

  # User Service
  user-service:
    build: ./services/user
    container_name: user-api
    environment:
      - NODE_ENV=production
      - DB_HOST=user-db
      - REDIS_HOST=cache
    depends_on:
      - user-db
      - cache
    networks:
      - frontend
      - backend

  # Order Service
  order-service:
    build: ./services/order
    container_name: order-api
    environment:
      - NODE_ENV=production
      - DB_HOST=order-db
      - USER_SERVICE_URL=http://user-service:3000
    depends_on:
      - order-db
    networks:
      - frontend
      - backend

  # Product Service
  product-service:
    build: ./services/product
    container_name: product-api
    environment:
      - NODE_ENV=production
      - DB_HOST=product-db
    depends_on:
      - product-db
    networks:
      - frontend
      - backend

  # Databases
  user-db:
    image: postgres:13
    container_name: user-database
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: userapp
      POSTGRES_PASSWORD: userpass
    volumes:
      - user_data:/var/lib/postgresql/data
    networks:
      - backend

  order-db:
    image: postgres:13
    container_name: order-database
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: orderapp
      POSTGRES_PASSWORD: orderpass
    volumes:
      - order_data:/var/lib/postgresql/data
    networks:
      - backend

  product-db:
    image: postgres:13
    container_name: product-database
    environment:
      POSTGRES_DB: products
      POSTGRES_USER: productapp
      POSTGRES_PASSWORD: productpass
    volumes:
      - product_data:/var/lib/postgresql/data
    networks:
      - backend

  # Cache
  cache:
    image: redis:alpine
    container_name: redis-cache
    volumes:
      - redis_data:/data
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true

volumes:
  user_data:
  order_data:
  product_data:
  redis_data:
```

### Example 3: WordPress with MySQL

```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    container_name: my-wordpress
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: mysql:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
      - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
    depends_on:
      - mysql
    restart: unless-stopped

  mysql:
    image: mysql:8.0
    container_name: wordpress-mysql
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped

volumes:
  wordpress_data:
  mysql_data:
```

## Advanced Docker Compose Features

### Environment-Specific Configurations

**Base configuration** (`docker-compose.yml`):
```yaml
version: '3.8'
services:
  app:
    image: myapp:latest
    environment:
      - NODE_ENV=production
```

**Development overrides** (`docker-compose.override.yml`):
```yaml
version: '3.8'
services:
  app:
    build: .                    # Build instead of using image
    volumes:
      - .:/app                  # Mount source code
    environment:
      - NODE_ENV=development    # Override environment
      - DEBUG=true
    ports:
      - "3000:3000"            # Expose port for development
```

**Production overrides** (`docker-compose.prod.yml`):
```yaml
version: '3.8'
services:
  app:
    image: myapp:v1.2.3        # Specific version
    restart: unless-stopped
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

**Usage**:
```bash
# Development (uses override automatically)
docker-compose up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### Environment Variables and Secrets

**Environment Variables**:
```yaml
version: '3.8'
services:
  app:
    image: myapp
    environment:
      - NODE_ENV=${ENV:-production}
      - DATABASE_URL=${DATABASE_URL}
      - API_KEY=${API_KEY}
    env_file:
      - .env
      - .env.local
```

**Secrets** (Docker Swarm):
```yaml
version: '3.8'
services:
  app:
    image: myapp
    secrets:
      - db_password
      - api_key
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    external: true
```

### Health Checks and Dependencies

```yaml
version: '3.8'
services:
  db:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s

  app:
    image: myapp
    depends_on:
      db:
        condition: service_healthy    # Wait for healthy db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Custom Networks

```yaml
version: '3.8'
services:
  web:
    image: nginx
    networks:
      - frontend

  app:
    image: myapp
    networks:
      - frontend
      - backend

  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16

  backend:
    driver: bridge
    internal: true              # No external access
    ipam:
      driver: default
      config:
        - subnet: 172.21.0.0/16
```

### Volume Management

```yaml
version: '3.8'
services:
  app:
    image: myapp
    volumes:
      # Named volume
      - app_data:/app/data
      
      # Host directory (bind mount)
      - ./logs:/app/logs
      
      # Anonymous volume
      - /app/temp
      
      # Read-only mount
      - ./config:/app/config:ro
      
      # Volume with options
      - type: volume
        source: app_data
        target: /app/data
        volume:
          nocopy: true

volumes:
  app_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=10.40.0.199,nolock,soft,rw
      device: ":/docker/app_data"
```

## Challenge 44 Solution

### Understanding the Requirements

**Challenge 44 asks for**:
1. Create container named `httpd` using Docker Compose
2. Use `httpd:latest` image
3. Map container port 80 to host port 8084
4. Mount host directory `/opt/finance` to container's `/usr/local/apache2/htdocs`
5. Place Docker Compose file at `/opt/docker/docker-compose.yml`

### Step-by-Step Solution

#### Step 1: Create Directory Structure
```bash
# Create directory for Docker Compose file
sudo mkdir -p /opt/docker

# Change to the directory
cd /opt/docker
```

#### Step 2: Create docker-compose.yml
```bash
# Create the compose file
sudo vi /opt/docker/docker-compose.yml
```

#### Step 3: Docker Compose Configuration
```yaml
version: '3.8'

services:
  web-service:                          # Service name (can be any name)
    image: httpd:latest                 # Use Apache HTTP Server latest version
    container_name: httpd               # Container name must be 'httpd'
    ports:
      - "8084:80"                       # Map host port 8084 to container port 80
    volumes:
      - /opt/finance:/usr/local/apache2/htdocs    # Mount finance directory
    restart: unless-stopped             # Restart policy for reliability
```

#### Step 4: Deploy the Service
```bash
# Navigate to compose file directory
cd /opt/docker

# Start the service in background
sudo docker-compose up -d
```

#### Step 5: Verification
```bash
# Check if container is running
docker ps | grep httpd

# Check compose service status
docker-compose ps

# Test the web server
curl localhost:8084

# Check if files from /opt/finance are being served
ls -la /opt/finance
curl localhost:8084/index.html    # If index.html exists in /opt/finance
```

### Detailed Configuration Explanation

#### **Version Declaration**
```yaml
version: '3.8'
```
- Specifies Docker Compose file format version
- Version 3.8 supports all modern Docker features
- Ensures compatibility with current Docker installations

#### **Services Section**
```yaml
services:
  web-service:
```
- Defines all containers that make up your application
- `web-service` is the service name (internal identifier)
- Can be any name; used for service-to-service communication

#### **Image Specification**
```yaml
image: httpd:latest
```
- Uses Apache HTTP Server Docker image
- `latest` tag pulls the most recent stable version
- httpd is the official Apache HTTP Server image from Docker Hub

#### **Container Naming**
```yaml
container_name: httpd
```
- Sets the actual container name visible in `docker ps`
- Challenge specifically requires container name to be 'httpd'
- Without this, Docker Compose would generate a name like `docker_web-service_1`

#### **Port Mapping**
```yaml
ports:
  - "8084:80"
```
- Maps host port 8084 to container port 80
- Format: `"host_port:container_port"`
- Apache listens on port 80 inside container
- External access via http://server-ip:8084

#### **Volume Mounting**
```yaml
volumes:
  - /opt/finance:/usr/local/apache2/htdocs
```
- Mounts host directory `/opt/finance` into container
- Container path `/usr/local/apache2/htdocs` is Apache's document root
- Any files in `/opt/finance` will be served by Apache
- Changes to files are immediately reflected (no container restart needed)

#### **Restart Policy**
```yaml
restart: unless-stopped
```
- Container automatically restarts if it crashes
- Won't restart if manually stopped with `docker stop`
- Ensures service availability after system reboots

### Alternative Configurations

#### **With Build Context** (if you need custom Apache config):
```yaml
version: '3.8'
services:
  web-service:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: httpd
    ports:
      - "8084:80"
    volumes:
      - /opt/finance:/usr/local/apache2/htdocs
```

#### **With Environment Variables**:
```yaml
version: '3.8'
services:
  web-service:
    image: httpd:latest
    container_name: httpd
    ports:
      - "8084:80"
    volumes:
      - /opt/finance:/usr/local/apache2/htdocs
    environment:
      - APACHE_LOG_LEVEL=info
      - TZ=UTC
```

#### **With Health Check**:
```yaml
version: '3.8'
services:
  web-service:
    image: httpd:latest
    container_name: httpd
    ports:
      - "8084:80"
    volumes:
      - /opt/finance:/usr/local/apache2/htdocs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Management Commands for Challenge 44

```bash
# Start service
docker-compose up -d

# View logs
docker-compose logs
docker-compose logs -f              # Follow logs

# Stop service
docker-compose down

# Restart service
docker-compose restart

# Check status
docker-compose ps

# View configuration
docker-compose config

# Scale service (create multiple containers)
docker-compose up -d --scale web-service=2

# Update service (after changing compose file)
docker-compose up -d

# Access container shell
docker-compose exec web-service bash
```

### Testing the Solution

```bash
# 1. Verify container is running with correct name
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"

# Expected output should show:
# NAMES    IMAGE         PORTS                  STATUS
# httpd    httpd:latest  0.0.0.0:8084->80/tcp   Up X minutes

# 2. Test web server response
curl -I localhost:8084
# Should return HTTP/1.1 200 OK

# 3. Check if content from /opt/finance is served
# Create test file
echo "<h1>Hello from Finance Directory</h1>" | sudo tee /opt/finance/test.html

# Access the file
curl localhost:8084/test.html
# Should return the HTML content

# 4. Verify volume mount
docker-compose exec web-service ls -la /usr/local/apache2/htdocs
# Should show contents of /opt/finance directory
```

## Best Practices

### 1. File Organization

```bash
# Recommended project structure
project/
├── docker-compose.yml              # Main compose file
├── docker-compose.override.yml     # Development overrides
├── docker-compose.prod.yml         # Production overrides
├── .env                           # Environment variables
├── .env.example                   # Example environment file
├── services/
│   ├── web/
│   │   ├── Dockerfile
│   │   └── src/
│   └── api/
│       ├── Dockerfile
│       └── src/
└── volumes/
    ├── mysql/
    └── redis/
```

### 2. Environment Management

```yaml
# Use environment variables for configuration
version: '3.8'
services:
  app:
    image: myapp:${APP_VERSION:-latest}
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - API_KEY=${API_KEY}
      - DEBUG=${DEBUG:-false}
    ports:
      - "${APP_PORT:-3000}:3000"
```

**Create .env file**:
```bash
# .env
APP_VERSION=1.2.3
DATABASE_URL=postgresql://user:pass@db:5432/myapp
API_KEY=your-secret-api-key
DEBUG=true
APP_PORT=3000
```

### 3. Security Considerations

```yaml
version: '3.8'
services:
  app:
    image: myapp:latest
    # Run as non-root user
    user: "1000:1000"
    
    # Limit resources
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    
    # Use secrets for sensitive data
    secrets:
      - db_password
    
    # Limit capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### 4. Networking Best Practices

```yaml
version: '3.8'
services:
  web:
    image: nginx
    networks:
      - frontend
    # Only expose necessary ports
    ports:
      - "80:80"

  app:
    image: myapp
    networks:
      - frontend
      - backend
    # No ports exposed (internal only)

  db:
    image: postgres
    networks:
      - backend
    # Completely isolated from external access

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true    # No external internet access
```

### 5. Volume Management

```yaml
version: '3.8'
services:
  app:
    image: myapp
    volumes:
      # Use named volumes for data persistence
      - app_data:/app/data
      
      # Use bind mounts for configuration
      - ./config:/app/config:ro
      
      # Avoid mounting sensitive host directories
      # - /:/host-root  # DON'T DO THIS

volumes:
  app_data:
    driver: local
    # Use labels for documentation
    labels:
      - "backup=daily"
      - "environment=production"
```

### 6. Service Dependencies

```yaml
version: '3.8'
services:
  db:
    image: postgres
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    image: myapp
    depends_on:
      db:
        condition: service_healthy
    # App won't start until DB is healthy
```

### 7. Logging and Monitoring

```yaml
version: '3.8'
services:
  app:
    image: myapp
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    # Health check for monitoring
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Port Already in Use

**Error**: `Bind for 0.0.0.0:8084 failed: port is already allocated`

**Solutions**:
```bash
# Find what's using the port
sudo netstat -tlnp | grep :8084
sudo lsof -i :8084

# Kill the process
sudo kill -9 <PID>

# Or change the port in docker-compose.yml
ports:
  - "8085:80"    # Use different host port
```

#### 2. Permission Denied on Volume Mounts

**Error**: Permission denied accessing mounted directories

**Solutions**:
```bash
# Check directory permissions
ls -la /opt/finance

# Fix permissions
sudo chown -R $USER:$USER /opt/finance
sudo chmod -R 755 /opt/finance

# Or run container as specific user
version: '3.8'
services:
  web:
    image: httpd:latest
    user: "1000:1000"    # Run as specific UID:GID
```

#### 3. Service Won't Start

**Error**: Container exits immediately

**Debugging**:
```bash
# Check logs
docker-compose logs web-service

# Run container interactively
docker-compose run web-service bash

# Check container status
docker-compose ps
```

#### 4. Network Issues

**Error**: Services can't communicate

**Solutions**:
```bash
# Check if services are on same network
docker network ls
docker network inspect docker_default

# Test connectivity
docker-compose exec service1 ping service2

# Ensure services are in same compose file or network
```

#### 5. Environment Variable Issues

**Error**: Environment variables not loaded

**Solutions**:
```bash
# Check if .env file is in same directory as docker-compose.yml
ls -la .env

# Verify environment variables are loaded
docker-compose config

# Check inside container
docker-compose exec service env
```

### Debugging Commands

```bash
# Validate compose file syntax
docker-compose config

# View effective configuration
docker-compose config --services
docker-compose config --volumes

# Check service logs
docker-compose logs service-name
docker-compose logs -f --tail=100 service-name

# Execute commands in running container
docker-compose exec service-name bash
docker-compose exec service-name ps aux

# Run one-off commands
docker-compose run service-name bash
docker-compose run --rm service-name curl http://other-service

# View resource usage
docker stats
docker-compose top
```

## Production Considerations

### 1. Security Hardening

```yaml
version: '3.8'
services:
  app:
    image: myapp:v1.2.3        # Use specific versions, not 'latest'
    read_only: true            # Read-only root filesystem
    tmpfs:
      - /tmp                   # Writable temp directory
    security_opt:
      - no-new-privileges:true # Prevent privilege escalation
    cap_drop:
      - ALL                    # Drop all capabilities
    cap_add:
      - NET_BIND_SERVICE       # Add only necessary capabilities
```

### 2. Resource Limits

```yaml
version: '3.8'
services:
  app:
    image: myapp
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
```

### 3. Health Checks and Monitoring

```yaml
version: '3.8'
services:
  app:
    image: myapp
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
  nginx:
    image: nginx
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 5s
      retries: 3
```

### 4. Secrets Management

```yaml
version: '3.8'
services:
  app:
    image: myapp
    secrets:
      - db_password
      - api_key
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - API_KEY_FILE=/run/secrets/api_key

secrets:
  db_password:
    external: true
  api_key:
    external: true
```

### 5. Backup and Recovery

```yaml
version: '3.8'
services:
  db:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password

  backup:
    image: postgres:13
    depends_on:
      - db
    volumes:
      - backup_data:/backup
      - ./backup-script.sh:/backup-script.sh
    command: /backup-script.sh
    restart: "no"

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=backup-server,rw
      device: ":/backups/postgres"
  backup_data:
```

### 6. Multi-Environment Deployment

**Production Stack**:
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  app:
    image: myapp:${VERSION}
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.example.com`)"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"

networks:
  traefik:
    external: true
```

**Deployment**:
```bash
# Deploy to production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Update with zero downtime
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale app=6
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale app=3
```

---

## Summary

Docker Compose revolutionizes container management by:

**Simplifying Complexity**: Multi-container applications become manageable with declarative YAML configuration

**Ensuring Consistency**: Same application stack across all environments with version-controlled infrastructure

**Enabling Scalability**: Easy service scaling and load balancing

**Improving Development**: Rapid environment setup and teardown for development teams

**Supporting Production**: Production-ready features like health checks, secrets management, and rolling updates

**For Challenge 44 specifically**: Docker Compose provides a clean, maintainable way to define the httpd service with proper port mapping and volume mounting, making it trivial to recreate the exact same Apache web server environment anywhere.

The solution transforms a complex `docker run` command into a simple, readable configuration file that can be version-controlled, shared, and deployed consistently across environments.