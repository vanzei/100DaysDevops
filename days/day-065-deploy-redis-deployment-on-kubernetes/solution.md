# Day 065: Deploy Redis Deployment on Kubernetes

## Challenge Objective
Deploy a Redis caching service on Kubernetes using ConfigMaps for configuration management, demonstrating advanced resource management, volume mounting strategies, and configuration externalization patterns.

## Solution Overview

This solution demonstrates **ConfigMap-driven configuration management** with:
- **ConfigMap**: External configuration for Redis memory limits
- **Deployment**: Single-replica Redis instance with resource requests
- **Volume Management**: EmptyDir for data and ConfigMap for configuration
- **Resource Planning**: CPU requests for guaranteed performance

## Step-by-Step Implementation

### Step 1: Deploy Redis with ConfigMap
```bash
# Apply the complete Redis deployment
kubectl apply -f redis-deployment.yaml
```

### Step 2: Verify ConfigMap Creation
```bash
# Check ConfigMap exists
kubectl get configmap my-redis-config

# View ConfigMap contents
kubectl describe configmap my-redis-config

# Expected output:
# Name:         my-redis-config
# Data
# ====
# redis-config:
# ----
# maxmemory 2mb
```

### Step 3: Verify Deployment Status
```bash
# Check deployment
kubectl get deployment redis-deployment

# Expected output:
# NAME               READY   UP-TO-DATE   AVAILABLE   AGE
# redis-deployment   1/1     1            1           <age>

# Check deployment details
kubectl describe deployment redis-deployment
```

### Step 4: Verify Pod Configuration
```bash
# Check pod status
kubectl get pods -l app=redis

# Expected output:
# NAME                               READY   STATUS    RESTARTS   AGE
# redis-deployment-xxxx              1/1     Running   0          <age>

# Check pod details including resource requests
kubectl describe pod -l app=redis
```

### Step 5: Verify Volume Mounts
```bash
# Get pod name
REDIS_POD=$(kubectl get pods -l app=redis -o jsonpath='{.items[0].metadata.name}')

# Check data volume mount
kubectl exec $REDIS_POD -- ls -la /redis-master-data

# Check config volume mount
kubectl exec $REDIS_POD -- ls -la /redis-master

# Verify config file contents
kubectl exec $REDIS_POD -- cat /redis-master/redis-config
```

### Step 6: Test Redis Functionality
```bash
# Connect to Redis and test
kubectl exec -it $REDIS_POD -- redis-cli

# Inside Redis CLI, test basic operations:
# > set test-key "Hello ConfigMap"
# > get test-key
# > info memory
# > config get maxmemory
# > exit
```

### Step 7: Verify Resource Allocation
```bash
# Check resource requests and limits
kubectl describe pod -l app=redis | grep -A 5 "Requests:"

# Check actual resource usage (if metrics-server is available)
kubectl top pod -l app=redis
```

### Step 8: Test Configuration Management
```bash
# Update ConfigMap
kubectl patch configmap my-redis-config --type merge -p '{"data":{"redis-config":"maxmemory 4mb\nmaxmemory-policy allkeys-lru"}}'

# Restart deployment to pick up new config
kubectl rollout restart deployment redis-deployment

# Verify config update
kubectl exec $REDIS_POD -- cat /redis-master/redis-config
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. ConfigMap Not Found
```bash
# Check if ConfigMap exists
kubectl get configmap

# If missing, apply just the ConfigMap
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-redis-config
data:
  redis-config: |
    maxmemory 2mb
EOF
```

#### 2. Pod Not Starting
```bash
# Check pod events
kubectl describe pod -l app=redis

# Check logs
kubectl logs -l app=redis

# Common issues:
# - Image pull errors
# - Resource constraints
# - Volume mount failures
```

#### 3. Volume Mount Issues
```bash
# Check volume mounts in pod spec
kubectl get pod -l app=redis -o yaml | grep -A 10 volumeMounts

# Verify volume definitions
kubectl get pod -l app=redis -o yaml | grep -A 10 volumes

# Test mount accessibility
kubectl exec $REDIS_POD -- df -h
```

#### 4. Resource Request Issues
```bash
# Check node resources
kubectl describe nodes

# Check resource requests vs available
kubectl describe deployment redis-deployment | grep -A 5 "Requests:"

# If scheduling issues, reduce CPU request
kubectl patch deployment redis-deployment -p '{"spec":{"template":{"spec":{"containers":[{"name":"redis-container","resources":{"requests":{"cpu":"500m"}}}]}}}}'
```

#### 5. Redis Configuration Problems
```bash
# Check Redis is using config
kubectl exec $REDIS_POD -- redis-cli config get maxmemory

# Check Redis logs
kubectl logs $REDIS_POD

# Manually load config (if needed)
kubectl exec $REDIS_POD -- redis-cli config set maxmemory 2mb
```

## Validation Commands

### Complete System Check
```bash
# 1. Verify ConfigMap
kubectl get configmap my-redis-config -o yaml

# 2. Verify deployment
kubectl get deployment redis-deployment

# 3. Verify pod is running
kubectl get pods -l app=redis | grep Running

# 4. Verify resource requests
kubectl describe deployment redis-deployment | grep -A 3 "Requests:"

# 5. Verify volume mounts
REDIS_POD=$(kubectl get pods -l app=redis -o jsonpath='{.items[0].metadata.name}')
kubectl exec $REDIS_POD -- ls -la /redis-master-data /redis-master

# 6. Test Redis functionality
kubectl exec $REDIS_POD -- redis-cli ping

# 7. Verify configuration
kubectl exec $REDIS_POD -- redis-cli config get maxmemory
```

### Advanced Validation Script
```bash
#!/bin/bash
echo "=== Redis Deployment Validation ==="

# Check ConfigMap
echo "1. ConfigMap Status:"
kubectl get configmap my-redis-config || echo "❌ ConfigMap missing"

# Check Deployment
echo "2. Deployment Status:"
READY=$(kubectl get deployment redis-deployment -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [ "$READY" = "1" ]; then
    echo "✅ Deployment ready"
else
    echo "❌ Deployment not ready"
fi

# Check Pod
echo "3. Pod Status:"
POD_STATUS=$(kubectl get pods -l app=redis -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
if [ "$POD_STATUS" = "Running" ]; then
    echo "✅ Pod running"
else
    echo "❌ Pod not running: $POD_STATUS"
fi

# Check Volumes
echo "4. Volume Mounts:"
REDIS_POD=$(kubectl get pods -l app=redis -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$REDIS_POD" ]; then
    kubectl exec $REDIS_POD -- ls /redis-master-data >/dev/null 2>&1 && echo "✅ Data volume mounted" || echo "❌ Data volume missing"
    kubectl exec $REDIS_POD -- ls /redis-master >/dev/null 2>&1 && echo "✅ Config volume mounted" || echo "❌ Config volume missing"
fi

# Test Redis
echo "5. Redis Functionality:"
if [ -n "$REDIS_POD" ]; then
    PING_RESULT=$(kubectl exec $REDIS_POD -- redis-cli ping 2>/dev/null || echo "FAILED")
    if [ "$PING_RESULT" = "PONG" ]; then
        echo "✅ Redis responding"
    else
        echo "❌ Redis not responding"
    fi
fi

echo "=== Validation Complete ==="
```

## Configuration Management Examples

### Basic ConfigMap Operations
```bash
# Create ConfigMap from literal
kubectl create configmap redis-config-literal --from-literal=maxmemory=2mb

# Create ConfigMap from file
echo "maxmemory 2mb" > redis.conf
kubectl create configmap redis-config-file --from-file=redis-config=redis.conf

# Update ConfigMap
kubectl patch configmap my-redis-config --type merge -p '{"data":{"redis-config":"maxmemory 4mb"}}'

# View ConfigMap as YAML
kubectl get configmap my-redis-config -o yaml
```

### Advanced Configuration Patterns
```bash
# Multi-key ConfigMap
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-advanced-config
data:
  redis.conf: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru
    save 900 1
  redis-sentinel.conf: |
    port 26379
    sentinel monitor mymaster redis-master 6379 2
EOF
```

## Production Considerations

### Enhanced Configuration for Production
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-production-config
data:
  redis-config: |
    # Memory Management
    maxmemory 1gb
    maxmemory-policy allkeys-lru
    
    # Persistence
    save 900 1
    save 300 10
    save 60 10000
    
    # Security
    requirepass ${REDIS_PASSWORD}
    
    # Performance
    tcp-keepalive 60
    timeout 0
    
    # Logging
    loglevel notice
```

### StatefulSet for Production
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-statefulset
spec:
  serviceName: redis-service
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis-container
        image: redis:alpine
        resources:
          requests:
            cpu: "1"
            memory: "1Gi"
          limits:
            cpu: "2"
            memory: "2Gi"
        volumeMounts:
        - name: redis-data
          mountPath: /data
        - name: redis-config
          mountPath: /usr/local/etc/redis
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

## Success Criteria

✅ ConfigMap `my-redis-config` created with `maxmemory 2mb`  
✅ Deployment `redis-deployment` running with 1 replica  
✅ Container named `redis-container` using `redis:alpine` image  
✅ CPU request of 1 CPU configured  
✅ Data volume mounted at `/redis-master-data`  
✅ Config volume mounted at `/redis-master`  
✅ Container exposing port 6379  
✅ Redis deployment in running state  
✅ Configuration accessible from mounted ConfigMap  

## Key Learning Points

1. **ConfigMap Usage**: External configuration management separate from container images
2. **Resource Requests**: Guaranteed CPU allocation for application performance
3. **Volume Types**: Different volume types for different use cases (emptyDir vs configMap)
4. **Container Design**: Proper port exposure and resource management
5. **Configuration Mounting**: How ConfigMaps become available as files in containers

This solution demonstrates production-ready patterns for configuration management while providing a solid foundation for scaling Redis deployments in Kubernetes environments.