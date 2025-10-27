# Day 065: Deploy Redis Deployment on Kubernetes - ConfigMaps & Resource Management Deep Dive

## Project Overview: Advanced Resource Management with ConfigMaps

This challenge demonstrates **advanced Kubernetes resource management** using ConfigMaps for application configuration, combined with proper volume mounting, resource requests, and deployment strategies. Understanding these patterns is crucial for managing stateful applications and configuration-driven deployments in production environments.

## ConfigMaps: The Foundation of Configuration Management

### What are ConfigMaps?

**ConfigMaps** are Kubernetes API objects that store **non-confidential configuration data** in key-value pairs. They decouple configuration from application code, enabling the same container image to run in different environments.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-redis-config
data:
  redis-config: |
    maxmemory 2mb
```

### Why ConfigMaps Matter

#### **1. Configuration Decoupling**
- **Separation of Concerns**: Configuration separate from application code
- **Environment Portability**: Same image, different configs per environment
- **Runtime Updates**: Change configuration without rebuilding containers
- **Version Control**: Track configuration changes separately

#### **2. Deployment Flexibility**
```yaml
# Development Environment
data:
  redis-config: |
    maxmemory 2mb
    save 900 1

# Production Environment  
data:
  redis-config: |
    maxmemory 512mb
    save 60 1000
```

#### **3. Security Benefits**
- **Non-Secret Data**: ConfigMaps for public configuration
- **Secrets Separation**: Use Secrets for sensitive data
- **Access Control**: RBAC controls who can modify configurations

## Redis Configuration Strategy Deep Dive

### **Memory Management with `maxmemory`**

#### **Why `maxmemory 2mb`?**
```yaml
data:
  redis-config: |
    maxmemory 2mb
```

**Technical Reasoning:**
- **Memory Protection**: Prevents Redis from consuming unlimited memory
- **Container Limits**: Works with Kubernetes resource limits
- **Eviction Policies**: Triggers memory management when limit reached
- **Testing Environment**: Small limit appropriate for development/testing

#### **Production Considerations**
```yaml
# Production Redis Config
data:
  redis-config: |
    maxmemory 1gb
    maxmemory-policy allkeys-lru
    save 900 1
    save 300 10
    save 60 10000
```

**Memory Policy Options:**
- **`allkeys-lru`**: Remove least recently used keys
- **`volatile-lru`**: Remove LRU keys with expire set
- **`allkeys-random`**: Remove random keys
- **`volatile-ttl`**: Remove keys with shortest TTL

### **Configuration File Structure**

#### **Redis Configuration Format**
```yaml
data:
  redis-config: |
    # Memory Management
    maxmemory 2mb
    maxmemory-policy allkeys-lru
    
    # Persistence (for production)
    save 900 1
    save 300 10
    save 60 10000
    
    # Security (for production)
    requirepass mypassword
    
    # Networking
    bind 0.0.0.0
    port 6379
```

## Volume Architecture & Strategy

### **Volume 1: Data Volume (`/redis-master-data`)**

#### **EmptyDir Volume for Data Storage**
```yaml
volumeMounts:
- name: data
  mountPath: /redis-master-data
volumes:
- name: data
  emptyDir: {}
```

**Why This Path?**
- **Redis Data Directory**: Standard location for Redis data files
- **Persistence Layer**: Where RDB snapshots and AOF files are stored
- **Performance**: Fast local storage for caching operations

**Why EmptyDir?**
- **Testing Environment**: Simplified storage for development
- **Temporary Data**: Cache data doesn't need persistence
- **Performance**: Node-local storage with no network overhead

**Production Alternative:**
```yaml
volumes:
- name: data
  persistentVolumeClaim:
    claimName: redis-data-pvc
```

### **Volume 2: Configuration Volume (`/redis-master`)**

#### **ConfigMap Volume for Configuration**
```yaml
volumeMounts:
- name: redis-config
  mountPath: /redis-master
volumes:
- name: redis-config
  configMap:
    name: my-redis-config
```

**Why This Path?**
- **Configuration Directory**: Separate from data for organization
- **Mount Strategy**: ConfigMap files mounted as directory
- **File Access**: Redis can read config file from this location

**Configuration File Mounting:**
```yaml
# After mounting, config available at:
# /redis-master/redis-config
```

**Advanced Configuration Mounting:**
```yaml
volumes:
- name: redis-config
  configMap:
    name: my-redis-config
    items:
    - key: redis-config
      path: redis.conf
      mode: 0644
```

## Resource Management Strategy

### **CPU Resource Requests**

#### **Why Request 1 CPU?**
```yaml
resources:
  requests:
    cpu: "1"
```

**Technical Analysis:**
- **Guaranteed Resources**: Kubernetes guarantees this CPU allocation
- **Scheduling**: Only schedules on nodes with available CPU
- **Performance**: Redis benefits from dedicated CPU for operations
- **Quality of Service**: Creates "Burstable" QoS class

#### **Resource Request vs Limits**
```yaml
# Complete resource specification
resources:
  requests:
    cpu: "1"          # Guaranteed minimum
    memory: "512Mi"   # Guaranteed minimum
  limits:
    cpu: "2"          # Maximum allowed
    memory: "1Gi"     # Maximum allowed (should exceed maxmemory)
```

**Why This Matters:**
- **Requests**: Kubernetes scheduling decisions
- **Limits**: Container runtime enforcement
- **Memory Alignment**: Limits should exceed Redis maxmemory setting

### **Quality of Service Classes**

#### **Current Configuration Creates "Burstable" QoS:**
```yaml
# With only CPU requests (no limits):
resources:
  requests:
    cpu: "1"
# Results in: QoS Class = Burstable
```

**QoS Class Implications:**
- **Guaranteed**: requests = limits for all resources
- **Burstable**: Some requests set, limits may be higher
- **BestEffort**: No requests or limits set

**Production Recommendation:**
```yaml
# Guaranteed QoS for production Redis
resources:
  requests:
    cpu: "1"
    memory: "1Gi"
  limits:
    cpu: "1"
    memory: "1Gi"
```

## Container Networking & Port Exposure

### **Port 6379: Redis Standard**

#### **Why Port 6379?**
```yaml
ports:
- containerPort: 6379
  protocol: TCP
```

**Technical Reasoning:**
- **Redis Default**: Standard Redis server port
- **IANA Assignment**: Officially assigned to Redis
- **Client Expectations**: All Redis clients expect this port
- **Service Discovery**: Services can target this known port

#### **Container Port vs Service Port**
```yaml
# Container exposes port
spec:
  containers:
  - ports:
    - containerPort: 6379

# Service can map to different port
apiVersion: v1
kind: Service
spec:
  ports:
  - port: 6379        # Service port
    targetPort: 6379  # Container port
    nodePort: 30379   # External port (if NodePort)
```

## Deployment Architecture Patterns

### **Single Replica Strategy**

#### **Why 1 Replica for Testing?**
```yaml
spec:
  replicas: 1
```

**Testing Justification:**
- **Simplified Deployment**: Single instance for testing
- **Resource Efficiency**: Minimal resource consumption
- **State Management**: No clustering complexity
- **Data Consistency**: No replication concerns

#### **Production Scaling Considerations**
```yaml
# Redis Sentinel for HA
spec:
  replicas: 3  # Master + 2 replicas
  
# Or Redis Cluster
spec:
  replicas: 6  # 3 masters, 3 replicas
```

### **Redis Deployment vs StatefulSet**

#### **Why Deployment for This Challenge?**
```yaml
kind: Deployment  # Not StatefulSet
```

**Deployment Characteristics:**
- **Stateless Assumptions**: Pods are replaceable
- **EmptyDir Storage**: Data doesn't persist beyond pod lifecycle
- **Testing Focus**: Emphasizes configuration, not persistence

**When to Use StatefulSet:**
```yaml
kind: StatefulSet
metadata:
  name: redis-statefulset
spec:
  serviceName: redis-service
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

**StatefulSet Benefits:**
- **Stable Pod Names**: redis-0, redis-1, etc.
- **Persistent Storage**: Automatic PVC creation
- **Ordered Operations**: Sequential start/stop
- **Stable Network Identity**: Consistent DNS names

## Configuration Management Patterns

### **ConfigMap Creation Strategies**

#### **1. Literal Values**
```bash
kubectl create configmap my-redis-config \
  --from-literal=maxmemory="2mb"
```

#### **2. File-Based Configuration**
```bash
# Create redis.conf file
echo "maxmemory 2mb" > redis.conf
kubectl create configmap my-redis-config \
  --from-file=redis-config=redis.conf
```

#### **3. YAML Declaration**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-redis-config
data:
  redis-config: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru
```

### **Configuration Hot-Reloading**

#### **ConfigMap Updates**
```yaml
# Update ConfigMap
kubectl patch configmap my-redis-config --type merge -p '{"data":{"redis-config":"maxmemory 4mb"}}'

# Restart deployment to pick up changes
kubectl rollout restart deployment redis-deployment
```

**Automatic Reloading (Advanced):**
```yaml
# Use init containers or sidecar patterns
spec:
  containers:
  - name: config-reloader
    image: configmap-reload:latest
    volumeMounts:
    - name: redis-config
      mountPath: /config
```

## Production Migration Strategy

### **What Changes for Production?**

#### **1. Persistent Storage**
```yaml
volumes:
- name: data
  persistentVolumeClaim:
    claimName: redis-data-pvc
```

#### **2. Enhanced Configuration**
```yaml
data:
  redis-config: |
    # Memory
    maxmemory 1gb
    maxmemory-policy allkeys-lru
    
    # Persistence
    save 900 1
    save 300 10
    save 60 10000
    
    # Security
    requirepass ${REDIS_PASSWORD}
    
    # Logging
    loglevel notice
    logfile /var/log/redis/redis-server.log
```

#### **3. Security Implementation**
```yaml
# Use Secrets for passwords
env:
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: redis-secrets
      key: password
```

#### **4. High Availability**
```yaml
# Redis Sentinel configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-sentinel-config
data:
  sentinel.conf: |
    port 26379
    sentinel monitor mymaster redis-master 6379 2
    sentinel down-after-milliseconds mymaster 5000
    sentinel parallel-syncs mymaster 1
    sentinel failover-timeout mymaster 10000
```

#### **5. Monitoring & Observability**
```yaml
# Add monitoring containers
spec:
  containers:
  - name: redis-exporter
    image: oliver006/redis_exporter
    ports:
    - containerPort: 9121
```

## ConfigMap Best Practices

### **1. Naming Conventions**
```yaml
# Good naming patterns
metadata:
  name: redis-config-prod
  name: app-config-v1.2.3
  name: database-config-staging
```

### **2. Configuration Validation**
```yaml
# Use JSON Schema or validation webhooks
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-redis-config
  annotations:
    config.kubernetes.io/schema: "redis-config-schema"
data:
  redis-config: |
    maxmemory 2mb
```

### **3. Environment-Specific Configs**
```yaml
# Base configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config-base
data:
  redis-config: |
    port 6379
    timeout 0

---
# Environment overlay
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config-prod
data:
  redis-config: |
    maxmemory 1gb
    maxmemory-policy allkeys-lru
```

### **4. Configuration Immutability**
```yaml
# Mark ConfigMaps as immutable for performance
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-redis-config
immutable: true
data:
  redis-config: |
    maxmemory 2mb
```

## Troubleshooting ConfigMap Issues

### **Common Problems & Solutions**

#### **1. Configuration Not Loading**
```bash
# Check ConfigMap exists
kubectl get configmap my-redis-config

# Verify mount path
kubectl exec redis-pod -- ls -la /redis-master/

# Check file contents
kubectl exec redis-pod -- cat /redis-master/redis-config
```

#### **2. Permission Issues**
```yaml
# Set proper file permissions
volumes:
- name: redis-config
  configMap:
    name: my-redis-config
    defaultMode: 0644
```

#### **3. Configuration Updates Not Applied**
```bash
# Force pod restart after ConfigMap update
kubectl rollout restart deployment redis-deployment

# Or delete pods to force recreation
kubectl delete pods -l app=redis
```

## Technical Decision Summary

### **Architecture Patterns Demonstrated**
1. **Configuration Management**: External configuration via ConfigMaps
2. **Resource Planning**: CPU requests for guaranteed performance  
3. **Volume Strategy**: Different volume types for different use cases
4. **Container Design**: Single-purpose container with proper port exposure
5. **Deployment Patterns**: Simple deployment for testing, StatefulSet for production

### **Production Readiness Considerations**
- **Data Persistence**: EmptyDir vs PersistentVolumes
- **Security**: ConfigMaps vs Secrets for sensitive data
- **High Availability**: Single replica vs Redis Cluster/Sentinel
- **Monitoring**: Basic deployment vs comprehensive observability
- **Configuration Management**: Static config vs dynamic configuration updates

This architecture provides a solid foundation for understanding how ConfigMaps enable flexible, maintainable application deployments while demonstrating proper resource management and volume mounting strategies essential for production Kubernetes workloads.