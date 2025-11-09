# Docker Containerization - 100 Days DevOps Challenge

## Overview

Docker containerization was covered in Days 35-47 of the challenge, focusing on container fundamentals, image management, networking, orchestration, and production deployment patterns. This module transitioned from traditional virtualization to modern container-based application deployment and management.

## What We Practiced

### Container Fundamentals
- **Docker installation** and service management
- **Container lifecycle** (create, start, stop, remove)
- **Image management** (pull, build, push, tag)
- **Container execution** and process management

### Image Creation & Management
- **Dockerfile writing** and best practices
- **Multi-stage builds** for optimized images
- **Image layering** and caching strategies
- **Registry operations** (Docker Hub, private registries)

### Networking & Storage
- **Docker networks** (bridge, host, overlay, macvlan)
- **Port mapping** and service exposure
- **Volume management** (bind mounts, named volumes)
- **Data persistence** strategies

### Orchestration & Scaling
- **Docker Compose** for multi-container applications
- **Service discovery** and load balancing
- **Environment management** and configuration
- **Production deployment** patterns

## Key Commands Practiced

### Docker Installation & Setup
```bash
# Install Docker packages
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker run hello-world
```

### Container Operations
```bash
# Run container interactively
docker run -it ubuntu:latest /bin/bash

# Run container in background
docker run -d --name web-server nginx:latest

# List containers
docker ps                    # Running containers
docker ps -a                # All containers

# Container lifecycle
docker start container-name
docker stop container-name
docker restart container-name
docker rm container-name     # Remove container
docker rm -f container-name  # Force remove running container
```

### Image Management
```bash
# Pull image from registry
docker pull nginx:latest
docker pull ubuntu:20.04

# Build image from Dockerfile
docker build -t my-app:latest .
docker build -t my-app:v1.0 -f Dockerfile.prod .

# List images
docker images

# Tag and push images
docker tag my-app:latest myregistry.com/my-app:v1.0
docker push myregistry.com/my-app:v1.0

# Remove images
docker rmi image-id
docker image prune -a  # Remove unused images
```

### Container Inspection & Debugging
```bash
# View container logs
docker logs container-name
docker logs -f container-name  # Follow logs

# Execute commands in running container
docker exec -it container-name /bin/bash
docker exec container-name ps aux

# Inspect container details
docker inspect container-name

# View container resource usage
docker stats
docker stats container-name
```

### File Operations with Containers
```bash
# Copy files to/from container
docker cp host-file.txt container-name:/app/
docker cp container-name:/app/output.txt .

# Mount volumes
docker run -v /host/path:/container/path nginx:latest
docker run -v my-volume:/app/data nginx:latest

# Create named volumes
docker volume create my-volume
docker volume ls
docker volume inspect my-volume
```

## Technical Topics Covered

### Docker Architecture
```text
Docker Host
├── Docker Daemon (dockerd)
├── Container Runtime (containerd)
├── Images & Containers
│   ├── Image Layers (UnionFS)
│   ├── Container Filesystem (Copy-on-Write)
│   └── Container Metadata
└── Networking
    ├── Bridge Network (default)
    ├── Host Network
    └── Custom Networks
```

### Image Layering
```text
Docker Image Layers:
┌─────────────────────────────────┐
│ Application Code & Dependencies │ ← Layer 5 (Top Layer)
├─────────────────────────────────┤
│ Runtime Environment (Node.js)   │ ← Layer 4
├─────────────────────────────────┤
│ Base OS Libraries               │ ← Layer 3
├─────────────────────────────────┤
│ Base OS (Ubuntu/Alpine)         │ ← Layer 2
├─────────────────────────────────┤
│ Boot Filesystem                 │ ← Layer 1 (Bottom Layer)
└─────────────────────────────────┘
```

### Container Networking
```text
Docker Network Types:

1. Bridge Network (Default)
   Host ──── Bridge ──── Container
              │
              └──────── Container

2. Host Network
   Host ──── Container (Direct access)

3. Overlay Network (Swarm)
   Host1 ──── Overlay ──── Host2
      │           │           │
   Container   Container   Container
```

### Dockerfile Best Practices
```dockerfile
# Use official base images
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Change ownership
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

## Production Environment Considerations

### Security Hardening
- **Non-root containers**: Run applications as non-privileged users
- **Minimal base images**: Use Alpine Linux or distroless images
- **Image scanning**: Automated vulnerability scanning
- **Secrets management**: Secure handling of sensitive data
- **Network isolation**: Proper network segmentation

### Resource Management
- **Memory limits**: Prevent container memory exhaustion
- **CPU limits**: Control CPU usage and scheduling
- **Storage quotas**: Limit disk usage per container
- **Resource monitoring**: Track and alert on resource usage

### High Availability & Scaling
- **Health checks**: Automatic container restart on failures
- **Rolling updates**: Zero-downtime deployments
- **Load balancing**: Distribute traffic across containers
- **Auto-scaling**: Scale based on resource utilization

### Image Optimization
- **Multi-stage builds**: Reduce final image size
- **Layer caching**: Optimize build performance
- **Base image selection**: Choose appropriate base images
- **Image tagging**: Semantic versioning and lifecycle management

### Monitoring & Logging
- **Container logs**: Centralized log aggregation
- **Metrics collection**: Resource usage and performance metrics
- **Health monitoring**: Application and infrastructure health
- **Alerting**: Proactive issue detection and notification

## Real-World Applications

### Multi-Container Application with Docker Compose
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
      - redis
    networks:
      - app-network

  db:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
    driver: bridge
```

### Production Dockerfile Example
```dockerfile
# Multi-stage build for Go application
FROM golang:1.19-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# Copy binary from builder stage
COPY --from=builder /app/main .

# Create non-root user
RUN adduser -D -s /bin/sh appuser
USER appuser

EXPOSE 8080

CMD ["./main"]
```

### Docker Swarm Production Setup
```bash
# Initialize swarm
docker swarm init

# Create overlay network
docker network create --driver overlay my-network

# Deploy stack
docker stack deploy -c docker-compose.yml my-stack

# Scale services
docker service scale my-stack_web=3

# Update services
docker service update --image nginx:1.21 my-stack_web

# Monitor services
docker service ls
docker service ps my-stack_web
```

## Troubleshooting Common Issues

### Container Won't Start
```bash
# Check container logs
docker logs container-name

# Inspect container configuration
docker inspect container-name

# Check resource limits
docker stats container-name

# Verify image exists
docker images | grep image-name
```

### Port Binding Issues
```bash
# Check if port is already in use
netstat -tlnp | grep :8080
ss -tlnp | grep :8080

# Verify container is running
docker ps | grep container-name

# Check firewall rules
sudo firewall-cmd --list-all
```

### Storage Issues
```bash
# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a --volumes

# Inspect volume usage
docker volume ls
docker volume inspect volume-name
```

### Networking Problems
```bash
# List networks
docker network ls

# Inspect network configuration
docker network inspect bridge

# Test connectivity
docker exec container-name ping google.com

# Check DNS resolution
docker exec container-name nslookup google.com
```

## Key Takeaways

1. **Immutable Infrastructure**: Containers should be stateless and immutable
2. **Layer Optimization**: Minimize layer count and optimize caching
3. **Security First**: Non-root users, minimal images, regular scanning
4. **Resource Limits**: Always set memory and CPU limits in production
5. **Monitoring**: Comprehensive logging and metrics collection

## Next Steps

- **Kubernetes Orchestration**: Advanced container orchestration
- **Service Mesh**: Istio, Linkerd for microservices
- **Docker Security**: Advanced security scanning and compliance
- **CI/CD Integration**: Automated container builds and deployments
- **Container Registries**: Harbor, ECR, GCR for enterprise use

Docker has revolutionized application deployment, enabling consistent environments from development to production and forming the foundation for modern microservices architectures.