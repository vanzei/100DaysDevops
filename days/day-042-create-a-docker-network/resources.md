# Docker Networks Complete Guide

## Table of Contents

1. [Introduction to Docker Networking](#introduction-to-docker-networking)
2. [Why Docker Networks Matter](#why-docker-networks-matter)
3. [Docker Network Types and Drivers](#docker-network-types-and-drivers)
4. [Docker Network Commands](#docker-network-commands)
5. [Bridge Networks - Default Behavior](#bridge-networks---default-behavior)
6. [Host Networks - Direct Host Access](#host-networks---direct-host-access)
7. [Overlay Networks - Multi-Host Communication](#overlay-networks---multi-host-communication)
8. [Macvlan Networks - Direct Physical Network Access](#macvlan-networks---direct-physical-network-access)
9. [Network Configuration Examples](#network-configuration-examples)
10. [Real-World Use Cases](#real-world-use-cases)
11. [Troubleshooting Docker Networks](#troubleshooting-docker-networks)
12. [Challenge 42 Solution](#challenge-42-solution)
13. [Best Practices](#best-practices)

## Introduction to Docker Networking

Docker networking enables containers to communicate with each other, the host system, and external networks. By default, Docker creates isolated environments, but networks allow controlled communication between containers and services.

### Core Concepts

**Container Isolation**: Each container has its own network namespace by default
**Network Drivers**: Different types of networks for different use cases
**Service Discovery**: Containers can find and communicate with each other by name
**Port Management**: Control which ports are exposed and how traffic flows

### Default Docker Networking

When you install Docker, it automatically creates three networks:

```bash
# View default networks
docker network ls

# Output:
NETWORK ID     NAME      DRIVER    SCOPE
abcdef123456   bridge    bridge    local
789012345678   host      host      local
345678901234   none      null      local
```

## Why Docker Networks Matter

### 1. **Container Communication**

Without custom networks, containers can only communicate through:
- Exposed ports on the host
- External services
- Complex port mapping

With networks:
- Direct container-to-container communication
- Service discovery by container name
- Isolated communication channels

### 2. **Security Isolation**

```bash
# Containers in different networks cannot communicate directly
docker network create frontend
docker network create backend

# Frontend containers cannot reach backend containers directly
docker run --network frontend nginx
docker run --network backend postgres
```

### 3. **Service Architecture**

```bash
# Multi-tier application example
docker network create web-tier
docker network create app-tier
docker network create db-tier

# Web server can only access app tier
docker run --network web-tier nginx

# App server connected to both web and db tiers
docker run --network app-tier --network db-tier myapp

# Database isolated in db tier only
docker run --network db-tier postgres
```

### 4. **Development Environment Consistency**

Networks ensure the same communication patterns work across:
- Development laptops
- Testing environments  
- Production servers

## Docker Network Types and Drivers

### 1. **Bridge Networks** (Default)

**Purpose**: Container-to-container communication on single host
**Scope**: Local host only
**Use Case**: Most common for single-host applications

```bash
# Create bridge network
docker network create my-bridge

# Containers can communicate by name
docker run --name app1 --network my-bridge nginx
docker run --name app2 --network my-bridge alpine ping app1
```

### 2. **Host Networks**

**Purpose**: Container uses host's network directly
**Scope**: Host network namespace
**Use Case**: High performance, monitoring tools

```bash
# Container uses host networking
docker run --network host nginx
# Now accessible directly on host IP
```

### 3. **Overlay Networks**

**Purpose**: Multi-host container communication
**Scope**: Docker Swarm cluster
**Use Case**: Distributed applications, microservices

```bash
# Create overlay network (requires swarm mode)
docker swarm init
docker network create --driver overlay my-overlay
```

### 4. **Macvlan Networks**

**Purpose**: Containers appear as physical devices on network
**Scope**: Physical network segment
**Use Case**: Legacy applications, network appliances, monitoring

```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan
```

### 5. **None Networks**

**Purpose**: No networking
**Scope**: Isolated
**Use Case**: Security-sensitive applications, batch processing

```bash
# No network access
docker run --network none alpine
```

## Docker Network Commands

### Basic Network Management

```bash
# List all networks
docker network ls

# Inspect network details
docker network inspect bridge

# Create network
docker network create my-network

# Remove network
docker network rm my-network

# Remove unused networks
docker network prune
```

### Advanced Network Operations

```bash
# Create network with custom subnet
docker network create --subnet=192.168.1.0/24 my-subnet

# Create with custom gateway
docker network create --subnet=192.168.1.0/24 --gateway=192.168.1.1 my-gw

# Create with specific driver
docker network create --driver macvlan my-macvlan

# Connect running container to network
docker network connect my-network my-container

# Disconnect container from network
docker network disconnect my-network my-container
```

### Network Inspection and Debugging

```bash
# View network configuration
docker network inspect my-network

# See which containers are connected
docker network inspect my-network --format '{{json .Containers}}'

# Check container's network settings
docker inspect my-container --format '{{json .NetworkSettings}}'
```

## Bridge Networks - Default Behavior

Bridge networks are the most common Docker network type.

### Default Bridge Behavior

```bash
# Run container on default bridge
docker run -d --name web nginx

# Containers get automatic IP addresses
docker inspect web --format '{{.NetworkSettings.IPAddress}}'
# Output: 172.17.0.2
```

### Custom Bridge Networks

```bash
# Create custom bridge
docker network create --driver bridge my-app

# Containers can communicate by name
docker run -d --name web --network my-app nginx
docker run -d --name api --network my-app node:alpine

# Test communication
docker exec web ping api  # Works!
docker exec api curl http://web  # Works!
```

### Bridge Network Features

- **DNS Resolution**: Container names resolve to IP addresses
- **Isolation**: Only containers in same network can communicate
- **Port Publishing**: `-p` flag still needed for host access
- **Automatic IP Assignment**: DHCP-like behavior

## Host Networks - Direct Host Access

Host networking removes network isolation between container and host.

### When to Use Host Networks

```bash
# Performance-critical applications
docker run --network host nginx
# Now accessible on host IP:80 directly

# Network monitoring tools
docker run --network host --privileged monitoring-tool

# Development/debugging
docker run --network host -it alpine sh
```

### Host Network Characteristics

- **No Port Mapping**: Container uses host ports directly
- **Performance**: No network translation overhead
- **Security**: Less isolation from host
- **Compatibility**: Some applications require host networking

## Overlay Networks - Multi-Host Communication

Overlay networks enable containers on different Docker hosts to communicate.

### Setting Up Overlay Networks

```bash
# Initialize swarm on manager node
docker swarm init

# Join worker nodes
docker swarm join --token <token> <manager-ip>:2377

# Create overlay network
docker network create --driver overlay --attachable my-overlay

# Deploy services using overlay
docker service create --network my-overlay --name web nginx
docker service create --network my-overlay --name api node:alpine
```

### Overlay Network Use Cases

- **Microservices Architecture**: Services across multiple hosts
- **Load Balancing**: Distribute containers across cluster
- **High Availability**: Redundancy across hosts
- **Scaling**: Add capacity by adding hosts

## Macvlan Networks - Direct Physical Network Access

Macvlan networks make containers appear as physical devices on your network.

### Understanding Macvlan

**Concept**: Each container gets a unique MAC address and appears as a separate device on the physical network

**Benefits**:
- Containers get IP addresses from physical network DHCP
- Direct access without port mapping
- Legacy application compatibility
- Network appliance simulation

### Macvlan Network Creation

```bash
# Basic macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan

# With IP range restriction
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.100/28 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan
```

### Macvlan Configuration Options

```bash
# Multiple subnets
docker network create -d macvlan \
  --subnet=192.168.1.0/24 --gateway=192.168.1.1 \
  --subnet=192.168.2.0/24 --gateway=192.168.2.1 \
  -o parent=eth0 \
  multi-subnet-macvlan

# VLAN tagging
docker network create -d macvlan \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  -o parent=eth0.100 \
  vlan-macvlan
```

### Running Containers with Macvlan

```bash
# Container gets IP from physical network
docker run -d --name web --network my-macvlan nginx

# Container accessible directly from physical network
# No port mapping needed!
curl 192.168.1.100  # Directly accessible
```

## Network Configuration Examples

### Example 1: Web Application Stack

```bash
# Create networks for different tiers
docker network create frontend
docker network create backend

# Database (backend only)
docker run -d --name db --network backend postgres

# API server (both networks)
docker run -d --name api --network backend nginx
docker network connect frontend api

# Web server (frontend only)
docker run -d --name web --network frontend nginx

# Load balancer (frontend + external access)
docker run -d --name lb --network frontend -p 80:80 nginx
```

### Example 2: Microservices with Service Discovery

```bash
# Create application network
docker network create microservices

# Start services
docker run -d --name user-service --network microservices user-api
docker run -d --name order-service --network microservices order-api
docker run -d --name gateway --network microservices -p 8080:80 api-gateway

# Services can communicate by name
# order-service can call http://user-service/api/users
```

### Example 3: Development Environment

```bash
# Create development network
docker network create dev-env

# Database with persistent storage
docker run -d --name dev-db --network dev-env \
  -v dev-db-data:/var/lib/postgresql/data \
  postgres

# Application with code volume
docker run -d --name dev-app --network dev-env \
  -v $(pwd):/app \
  -p 3000:3000 \
  node:alpine

# Test container for running tests
docker run --rm --network dev-env \
  -v $(pwd):/app \
  node:alpine npm test
```

## Real-World Use Cases

### 1. **Legacy Application Migration**

```bash
# Legacy app needs specific IP addresses
docker network create -d macvlan \
  --subnet=10.0.0.0/24 \
  --ip-range=10.0.0.100/28 \
  -o parent=eth0 \
  legacy-network

# Run legacy application
docker run -d --name legacy-app \
  --network legacy-network \
  --ip 10.0.0.101 \
  legacy-image
```

### 2. **Network Security Zones**

```bash
# DMZ for public-facing services
docker network create dmz

# Internal network for backend services
docker network create internal

# Management network for admin tools
docker network create mgmt

# Web servers in DMZ
docker run -d --name web1 --network dmz nginx
docker run -d --name web2 --network dmz nginx

# Database in internal network only
docker run -d --name db --network internal postgres

# Admin tools in management network
docker run -d --name monitoring --network mgmt prometheus
```

### 3. **Development and Testing Isolation**

```bash
# Separate networks for different environments
docker network create dev-frontend
docker network create dev-backend
docker network create test-frontend
docker network create test-backend

# Development environment
docker run -d --name dev-web --network dev-frontend nginx
docker run -d --name dev-api --network dev-backend node

# Testing environment (completely isolated)
docker run -d --name test-web --network test-frontend nginx
docker run -d --name test-api --network test-backend node
```

### 4. **Multi-Tenant Applications**

```bash
# Create tenant-specific networks
docker network create tenant-a
docker network create tenant-b

# Tenant A services
docker run -d --name tenant-a-app --network tenant-a myapp
docker run -d --name tenant-a-db --network tenant-a postgres

# Tenant B services (completely isolated)
docker run -d --name tenant-b-app --network tenant-b myapp
docker run -d --name tenant-b-db --network tenant-b postgres
```

## Troubleshooting Docker Networks

### Common Network Issues

#### 1. **Container Communication Problems**

```bash
# Check if containers are on same network
docker network inspect my-network

# Test connectivity between containers
docker exec container1 ping container2
docker exec container1 nslookup container2

# Check if ports are listening
docker exec container1 netstat -tlnp
```

#### 2. **DNS Resolution Issues**

```bash
# Test DNS resolution
docker exec my-container nslookup google.com
docker exec my-container dig container2

# Check Docker's internal DNS
docker exec my-container cat /etc/resolv.conf
```

#### 3. **Network Conflicts**

```bash
# Check for IP conflicts
docker network ls
docker network inspect bridge

# Check host routing table
ip route show

# Check for subnet overlaps
docker network inspect --format '{{.IPAM.Config}}' my-network
```

#### 4. **Macvlan Specific Issues**

```bash
# Check parent interface exists
ip link show eth0

# Verify subnet doesn't conflict with host
ip addr show eth0

# Check if promiscuous mode is enabled (may be required)
sudo ip link set eth0 promisc on

# Verify container has expected IP
docker exec my-container ip addr show
```

### Debugging Commands

```bash
# Network inspection
docker network ls
docker network inspect <network-name>

# Container network details
docker inspect <container> --format '{{json .NetworkSettings}}'

# Inside container debugging
docker exec -it <container> sh
# Then run: ip addr, ping, netstat, etc.

# Host network debugging
ss -tlnp                    # Check listening ports
ip route show              # Check routing table
iptables -L                # Check firewall rules
```

### Performance Troubleshooting

```bash
# Test network performance between containers
docker run --rm --network my-network alpine ping -c 10 target-container

# Bandwidth testing
docker run --rm --network my-network networkstatic/iperf3 -c target-container

# Check network usage
docker stats

# Monitor network traffic
sudo tcpdump -i docker0
```

## Challenge 42 Solution

Based on the challenge requirements, here's the step-by-step solution:

### Understanding the Requirements

- **Network name**: `media`
- **Driver**: `macvlan`
- **Subnet**: `172.28.0.0/24`
- **IP Range**: `172.28.0.0/24`

### Step-by-Step Solution

```bash
# Create the macvlan network named 'media'
docker network create -d macvlan \
  --subnet=172.28.0.0/24 \
  --ip-range=172.28.0.0/24 \
  -o parent=eth0 \
  media
```

### Detailed Command Breakdown

```bash
docker network create \
  -d macvlan \                    # Use macvlan driver
  --subnet=172.28.0.0/24 \       # Define subnet range
  --ip-range=172.28.0.0/24 \     # IP addresses available for containers
  -o parent=eth0 \               # Parent interface (may need adjustment)
  media                          # Network name
```

### Alternative Commands (if eth0 doesn't exist)

```bash
# Check available interfaces first
ip link show

# If using different interface (e.g., ens33, enp0s3)
docker network create -d macvlan \
  --subnet=172.28.0.0/24 \
  --ip-range=172.28.0.0/24 \
  -o parent=ens33 \
  media

# Or find the active interface
ip route | grep default  # Shows default route interface
```

### Verification Commands

```bash
# Verify network was created
docker network ls | grep media

# Inspect network details
docker network inspect media

# Check network configuration
docker network inspect media --format '{{json .IPAM.Config}}'
```

### Expected Output

```bash
# docker network ls
NETWORK ID     NAME    DRIVER    SCOPE
abc123def456   media   macvlan   local

# docker network inspect media (key parts)
{
    "Name": "media",
    "Driver": "macvlan",
    "IPAM": {
        "Config": [
            {
                "Subnet": "172.28.0.0/24",
                "IPRange": "172.28.0.0/24"
            }
        ]
    },
    "Options": {
        "parent": "eth0"
    }
}
```

### Testing the Network

```bash
# Run a container using the media network
docker run -d --name test-container --network media alpine sleep 3600

# Check if container got IP from our range
docker inspect test-container --format '{{.NetworkSettings.Networks.media.IPAddress}}'

# Should show IP like 172.28.0.1, 172.28.0.2, etc.
```

### Troubleshooting for Challenge 42

If you encounter issues:

```bash
# 1. Check if parent interface exists
ip link show | grep -E "(eth0|ens|enp)"

# 2. Use the correct parent interface
docker network create -d macvlan \
  --subnet=172.28.0.0/24 \
  --ip-range=172.28.0.0/24 \
  -o parent=<your-interface> \
  media

# 3. If interface doesn't support macvlan, try bridge mode
docker network create -d macvlan \
  --subnet=172.28.0.0/24 \
  --ip-range=172.28.0.0/24 \
  -o parent=eth0 \
  -o macvlan_mode=bridge \
  media
```

## Best Practices

### 1. **Network Planning**

```bash
# Use non-overlapping subnets
# Host: 192.168.1.0/24
# Docker: 172.17.0.0/16
# Custom: 10.0.0.0/8

# Plan IP ranges for different purposes
docker network create --subnet=10.1.0.0/24 frontend    # Web tier
docker network create --subnet=10.2.0.0/24 backend     # App tier
docker network create --subnet=10.3.0.0/24 database    # DB tier
```

### 2. **Security Considerations**

```bash
# Principle of least access
# Only connect containers to networks they need

# Database should only be on backend network
docker run -d --name db --network backend postgres

# Web server only on frontend
docker run -d --name web --network frontend nginx

# API server connects both (but planned)
docker run -d --name api --network backend myapi
docker network connect frontend api
```

### 3. **Naming Conventions**

```bash
# Use descriptive names
docker network create myapp-frontend
docker network create myapp-backend
docker network create myapp-cache

# Include environment
docker network create prod-frontend
docker network create dev-frontend
docker network create test-frontend
```

### 4. **Documentation**

```bash
# Use labels for documentation
docker network create \
  --label purpose="Frontend web servers" \
  --label environment="production" \
  --label owner="devops-team" \
  frontend
```

### 5. **Cleanup and Maintenance**

```bash
# Regular cleanup of unused networks
docker network prune

# Remove specific network
docker network rm old-network

# Check for conflicts before creating networks
docker network ls
ip route show
```

---

## Summary

Docker networks provide:

- **Isolation**: Separate network segments for different purposes
- **Communication**: Containers can find each other by name
- **Security**: Control which services can communicate
- **Flexibility**: Different network types for different use cases
- **Scalability**: Support for multi-host deployments

**For Challenge 42**: The macvlan network type allows containers to appear as physical devices on your network, which is useful for legacy applications or when you need containers to be directly accessible from the physical network without port mapping.

The key is understanding which network driver suits your specific use case and configuring it properly for your infrastructure needs.