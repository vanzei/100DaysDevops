# Dockerfile Complete Guide and Reference

## Table of Contents
1. [What is a Dockerfile?](#what-is-a-dockerfile)
2. [Why Dockerfiles are Essential](#why-dockerfiles-are-essential)
3. [Dockerfile Structure and Components](#dockerfile-structure-and-components)
4. [Essential Dockerfile Instructions](#essential-dockerfile-instructions)
5. [Advanced Dockerfile Instructions](#advanced-dockerfile-instructions)
6. [Best Practices](#best-practices)
7. [Common Use Cases and Examples](#common-use-cases-and-examples)
8. [Troubleshooting Common Issues](#troubleshooting-common-issues)
9. [Optimization Techniques](#optimization-techniques)

## What is a Dockerfile?

A **Dockerfile** is a text file containing a series of instructions that Docker uses to automatically build images. It's essentially a recipe that defines:
- The base operating system or image
- Software packages to install
- Configuration files to copy
- Environment variables to set
- Commands to run during build
- The default command when container starts

### Key Characteristics:
- **Declarative**: You describe what you want, not how to achieve it
- **Layered**: Each instruction creates a new layer in the image
- **Reproducible**: Same Dockerfile = Same image (when properly written)
- **Version Controllable**: Can be stored in Git alongside source code

## Why Dockerfiles are Essential

### 1. **Infrastructure as Code (IaC)**
```dockerfile
# Your infrastructure is now code
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 2. **Reproducibility**
- Same environment across development, testing, and production
- Eliminates "it works on my machine" problems
- Consistent deployments regardless of host system

### 3. **Version Control**
- Track changes to your infrastructure
- Rollback to previous configurations
- Collaborate on infrastructure changes

### 4. **Scalability**
- Build once, run anywhere
- Easy horizontal scaling
- Consistent performance characteristics

### 5. **Automation**
- Integrate with CI/CD pipelines
- Automated testing environments
- Streamlined deployment processes

## Dockerfile Structure and Components

### Basic Structure
```dockerfile
# Comments start with #
INSTRUCTION arguments

# Example:
FROM ubuntu:24.04          # Base image
LABEL maintainer="devops@company.com"
RUN apt-get update         # Execute command
COPY . /app               # Copy files
WORKDIR /app              # Set working directory
EXPOSE 3000               # Expose port
CMD ["node", "server.js"] # Default command
```

### Layer Architecture
Each instruction creates a new layer:
```dockerfile
FROM ubuntu:24.04         # Layer 1: Base Ubuntu image
RUN apt-get update        # Layer 2: Package updates
RUN apt-get install -y nginx  # Layer 3: Nginx installation
COPY index.html /var/www/html/  # Layer 4: Custom content
EXPOSE 80                 # Layer 5: Port configuration
CMD ["nginx", "-g", "daemon off;"]  # Layer 6: Start command
```

## Essential Dockerfile Instructions

### 1. FROM - Base Image (Required)
```dockerfile
# Always the first instruction (except ARG for build-time variables)
FROM ubuntu:24.04
FROM node:18-alpine
FROM scratch              # Empty base image
FROM python:3.11-slim AS builder  # Multi-stage builds
```

**Common Base Images:**
- **Ubuntu/Debian**: Full-featured, larger size
- **Alpine**: Minimal, security-focused, small size
- **Scratch**: Empty image for static binaries
- **Language-specific**: node:18, python:3.11, openjdk:17

### 2. RUN - Execute Commands
```dockerfile
# Shell form (runs in /bin/sh -c)
RUN apt-get update && apt-get install -y nginx

# Exec form (no shell processing)
RUN ["apt-get", "update"]

# Multiple commands (best practice)
RUN apt-get update && \
    apt-get install -y \
        nginx \
        curl \
        vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 3. COPY vs ADD - File Operations
```dockerfile
# COPY - Simple file copying (preferred)
COPY src/ /app/
COPY requirements.txt .
COPY --chown=nginx:nginx index.html /var/www/html/

# ADD - Advanced features (use sparingly)
ADD https://example.com/file.tar.gz /tmp/  # Download from URL
ADD archive.tar.gz /app/                   # Auto-extract archives
```

**When to use each:**
- **COPY**: For simple file/directory copying (99% of cases)
- **ADD**: Only when you need URL downloads or auto-extraction

### 4. WORKDIR - Set Working Directory
```dockerfile
WORKDIR /app              # Creates directory if it doesn't exist
COPY package.json .       # Copies to /app/package.json
RUN npm install           # Runs in /app directory

# Avoid using cd in RUN commands
RUN cd /app && npm install    # ❌ Bad practice
WORKDIR /app                  # ✅ Good practice
RUN npm install
```

### 5. EXPOSE - Document Port Usage
```dockerfile
EXPOSE 80                 # HTTP
EXPOSE 443                # HTTPS
EXPOSE 3000/tcp           # Explicit protocol
EXPOSE 53/udp             # UDP port

# Multiple ports
EXPOSE 80 443 3000
```

**Important**: EXPOSE is documentation only - doesn't actually publish ports!

### 6. CMD vs ENTRYPOINT - Container Startup
```dockerfile
# CMD - Default command (can be overridden)
CMD ["nginx", "-g", "daemon off;"]
CMD echo "Hello World"    # Shell form

# ENTRYPOINT - Always executed (cannot be overridden)
ENTRYPOINT ["python", "app.py"]
ENTRYPOINT python app.py  # Shell form

# Combined usage
ENTRYPOINT ["python", "app.py"]
CMD ["--help"]            # Default argument
```

**Key Differences:**
- **CMD**: `docker run myimage` uses CMD, `docker run myimage ls` overrides CMD
- **ENTRYPOINT**: Always runs, arguments are appended

### 7. ENV - Environment Variables
```dockerfile
ENV NODE_ENV=production
ENV PATH="/app/bin:${PATH}"
ENV DATABASE_URL="postgresql://localhost:5432/mydb" \
    REDIS_URL="redis://localhost:6379" \
    DEBUG=false

# Usage in other instructions
RUN echo $NODE_ENV
COPY app.js $WORKDIR/
```

### 8. ARG - Build-time Variables
```dockerfile
ARG VERSION=latest
ARG BUILD_DATE
ARG PYTHON_VERSION=3.11

FROM python:${PYTHON_VERSION}
LABEL build-date=${BUILD_DATE}
RUN echo "Building version: ${VERSION}"

# Build with: docker build --build-arg VERSION=v1.2.3 .
```

## Advanced Dockerfile Instructions

### 1. LABEL - Metadata
```dockerfile
LABEL maintainer="devops@company.com"
LABEL version="1.0.0"
LABEL description="Web application container"
LABEL org.opencontainers.image.source="https://github.com/company/app"
```

### 2. USER - Security Context
```dockerfile
# Create non-root user
RUN useradd -r -s /bin/false appuser
USER appuser

# Or use existing user
USER nginx
USER 1001              # By UID
```

### 3. VOLUME - Persistent Data
```dockerfile
VOLUME ["/var/log", "/var/db"]
VOLUME /data

# Better to define in docker run or docker-compose
```

### 4. HEALTHCHECK - Container Health
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Disable inherited healthcheck
HEALTHCHECK NONE
```

### 5. SHELL - Change Default Shell
```dockerfile
# Change from /bin/sh to bash
SHELL ["/bin/bash", "-c"]

# Windows example
SHELL ["powershell", "-command"]
```

### 6. ONBUILD - Trigger Instructions
```dockerfile
# In base image
ONBUILD COPY . /app
ONBUILD RUN make /app

# Triggers when this image is used as FROM in another Dockerfile
```

## Best Practices

### 1. Layer Optimization
```dockerfile
# ❌ Bad - Creates multiple layers
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get clean

# ✅ Good - Single layer
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 2. .dockerignore File
```dockerfile
# .dockerignore
node_modules/
.git/
*.log
.env
README.md
Dockerfile
.dockerignore
```

### 3. Multi-stage Builds
```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### 4. Security Best Practices
```dockerfile
# Use specific versions
FROM ubuntu:24.04         # Not ubuntu:latest

# Run as non-root user
RUN useradd -r appuser
USER appuser

# Minimal attack surface
FROM alpine:3.18          # Use minimal base images

# Keep packages updated
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y nginx && \
    apt-get clean
```

### 5. Cache Optimization
```dockerfile
# Copy dependency files first (better caching)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code after dependencies
COPY . .
```

## Common Use Cases and Examples

### 1. Web Application (Node.js)
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

USER nextjs

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "server.js"]
```

### 2. Apache Web Server
```dockerfile
FROM ubuntu:24.04

# Install Apache
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache for custom port
RUN sed -i 's/Listen 80/Listen 3002/g' /etc/apache2/ports.conf && \
    sed -i 's/:80>/:3002>/g' /etc/apache2/sites-available/000-default.conf

# Copy custom content
COPY ./html/ /var/www/html/

EXPOSE 3002

# Start Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
```

### 3. Python Application
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

EXPOSE 8000

CMD ["python", "app.py"]
```

### 4. Multi-stage Build Example
```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o main .

# Production stage
FROM alpine:3.18

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/main ./

EXPOSE 8080

CMD ["./main"]
```

## Troubleshooting Common Issues

### 1. Build Context Too Large
```bash
# Problem: Slow builds, large context
ERROR: failed to solve: failed to read dockerfile: open /var/lib/docker/tmp/buildkit-mount123/Dockerfile: no such file or directory

# Solutions:
# 1. Use .dockerignore
echo "node_modules/" >> .dockerignore

# 2. Use specific build context
docker build -f Dockerfile . --no-cache
```

### 2. Permission Denied Issues
```dockerfile
# Problem: Container runs as root, files owned by root
# Solution: Use non-root user
RUN useradd -m appuser
USER appuser

# Or set ownership during COPY
COPY --chown=appuser:appuser . /app
```

### 3. Package Installation Failures
```dockerfile
# Problem: Package not found, GPG errors
# Solutions:
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        package-name && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# For Alpine
RUN apk add --no-cache package-name
```

### 4. Large Image Sizes
```dockerfile
# Problem: Multi-GB images
# Solutions:

# 1. Use multi-stage builds
FROM node:18 AS builder
# ... build steps ...
FROM node:18-alpine
COPY --from=builder /app/dist ./dist

# 2. Use smaller base images
FROM alpine:3.18          # Instead of ubuntu
FROM node:18-alpine       # Instead of node:18

# 3. Clean up in same layer
RUN apt-get update && \
    apt-get install -y package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```

### 5. Service Won't Start
```dockerfile
# Problem: Service exits immediately
# Common causes and solutions:

# 1. Run service in foreground
CMD ["nginx", "-g", "daemon off;"]      # Not service nginx start

# 2. Use proper init system
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["nginx", "-g", "daemon off;"]

# 3. Check service configuration
RUN nginx -t    # Test configuration during build
```

### 6. Environment Variable Issues
```dockerfile
# Problem: Variables not available at runtime
# Solution: Use ENV not ARG for runtime variables
ENV DATABASE_URL="postgresql://localhost:5432/db"  # Available at runtime
ARG BUILD_VERSION="1.0.0"                         # Only at build time

# Problem: Variable substitution not working
ENV PATH="/app/bin:${PATH}"    # ✅ Works
ENV PATH="/app/bin:$PATH"      # ✅ Also works
ENV PATH='/app/bin:${PATH}'    # ❌ No substitution in single quotes
```

## Optimization Techniques

### 1. Layer Caching Strategy
```dockerfile
# Optimize for Docker layer caching
FROM node:18-alpine

WORKDIR /app

# 1. Copy package files first (changes less frequently)
COPY package*.json ./
RUN npm ci --only=production

# 2. Copy source code last (changes more frequently)
COPY . .

CMD ["node", "server.js"]
```

### 2. Minimize Layers
```dockerfile
# ❌ Many layers
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# ✅ Single optimized layer
RUN apt-get update && \
    apt-get install -y \
        nginx \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 3. Use BuildKit Features
```dockerfile
# syntax=docker/dockerfile:1.4

FROM ubuntu:24.04

# Use cache mounts
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y nginx

# Use secret mounts
RUN --mount=type=secret,id=apikey \
    curl -H "Authorization: $(cat /run/secrets/apikey)" \
    https://api.example.com/data
```

### 4. Health Checks and Monitoring
```dockerfile
# Add comprehensive health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3002/health || exit 1

# Add labels for monitoring
LABEL org.opencontainers.image.title="My Web App"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.created="2024-01-15T10:00:00Z"
```

## Challenge 41 Specific Example

Based on the current challenge requirements:

```dockerfile
FROM ubuntu:24.04

# Update package list and install Apache2
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache to listen on port 3002
RUN sed -i 's/Listen 80/Listen 3002/g' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:3002>/g' /etc/apache2/sites-available/000-default.conf

# Expose the port
EXPOSE 3002

# Start Apache in foreground mode
CMD ["apache2ctl", "-D", "FOREGROUND"]
```

This Dockerfile:
1. Uses Ubuntu 24.04 as base image
2. Installs Apache2 efficiently in one layer
3. Configures Apache for port 3002
4. Exposes the port for documentation
5. Starts Apache in foreground mode (essential for containers)

---

## Summary

Dockerfiles are the foundation of containerization, enabling:
- **Reproducible** infrastructure
- **Version-controlled** environments  
- **Automated** deployments
- **Scalable** applications

Master these concepts and you'll be able to containerize any application effectively and troubleshoot common Docker issues with confidence.

Remember: A good Dockerfile is secure, efficient, and maintainable!