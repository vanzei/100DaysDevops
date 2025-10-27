# Day 067: Deploy Guest Book App on Kubernetes

## Challenge Objective
Deploy a complete 3-tier Guestbook application on Kubernetes with Redis master-slave backend and PHP frontend, implementing proper scaling, resource management, and service discovery.

## Solution Overview

This solution demonstrates **3-tier web application architecture** including:
- **Backend Tier**: Redis master (writes) and Redis slaves (reads) 
- **Frontend Tier**: PHP web application with horizontal scaling
- **Service Layer**: Internal ClusterIP and external NodePort services
- **Resource Management**: CPU and memory requests for all components

## Architecture Components

### **Backend Tier (Redis)**
- **Redis Master**: Single instance for write consistency
- **Redis Slaves**: 2 replicas for read scalability  
- **Service Discovery**: DNS-based inter-service communication

### **Frontend Tier (PHP)**
- **Web Application**: PHP application serving guestbook interface
- **Horizontal Scaling**: 3 replicas for high availability
- **Load Balancing**: Kubernetes service distributes traffic

## Step-by-Step Implementation

### Step 1: Deploy the Complete Guestbook Application
```bash
# Apply all resources at once
kubectl apply -f guestbook-deployment.yaml
```

### Step 2: Verify Backend Deployments
```bash
# Check Redis master deployment
kubectl get deployment redis-master

# Expected output:
# NAME           READY   UP-TO-DATE   AVAILABLE   AGE
# redis-master   1/1     1            1           <age>

# Check Redis slave deployment  
kubectl get deployment redis-slave

# Expected output:
# NAME          READY   UP-TO-DATE   AVAILABLE   AGE
# redis-slave   2/2     2            2           <age>
```

### Step 3: Verify Frontend Deployment
```bash
# Check frontend deployment
kubectl get deployment frontend

# Expected output:
# NAME       READY   UP-TO-DATE   AVAILABLE   AGE
# frontend   3/3     3            3           <age>

# Check all deployments together
kubectl get deployments
```

### Step 4: Verify All Pods Are Running
```bash
# Check pod status
kubectl get pods

# Expected pods:
# redis-master-xxxxx     1/1     Running   0          <age>
# redis-slave-xxxxx      1/1     Running   0          <age>  
# redis-slave-yyyyy      1/1     Running   0          <age>
# frontend-xxxxx         1/1     Running   0          <age>
# frontend-yyyyy         1/1     Running   0          <age>
# frontend-zzzzz         1/1     Running   0          <age>

# Check pod details with labels
kubectl get pods --show-labels
```

### Step 5: Verify Services Configuration
```bash
# Check all services
kubectl get services

# Expected services:
# NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# redis-master   ClusterIP   10.96.x.x       <none>        6379/TCP       <age>
# redis-slave    ClusterIP   10.96.x.x       <none>        6379/TCP       <age>
# frontend       NodePort    10.96.x.x       <none>        80:30009/TCP   <age>

# Verify NodePort configuration
kubectl get service frontend -o yaml | grep nodePort
```

### Step 6: Test Service Discovery
```bash
# Test DNS resolution from frontend pod
FRONTEND_POD=$(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}')

# Test redis-master service discovery
kubectl exec $FRONTEND_POD -- nslookup redis-master

# Test redis-slave service discovery  
kubectl exec $FRONTEND_POD -- nslookup redis-slave
```

### Step 7: Verify Resource Allocation
```bash
# Check resource requests for all deployments
kubectl describe deployment redis-master | grep -A 3 "Requests:"
kubectl describe deployment redis-slave | grep -A 3 "Requests:"
kubectl describe deployment frontend | grep -A 3 "Requests:"

# Check actual resource usage
kubectl top pods
```

### Step 8: Test Application Functionality
```bash
# Get node IP for external access
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Test application access
curl -s http://$NODE_IP:30009 | grep -i guestbook

# Or open in browser
echo "Access the application at: http://$NODE_IP:30009"
```

### Step 9: Test Redis Connectivity
```bash
# Test Redis master connectivity
kubectl exec $FRONTEND_POD -- nc -zv redis-master 6379

# Test Redis slave connectivity
kubectl exec $FRONTEND_POD -- nc -zv redis-slave 6379

# Check Redis info from master
REDIS_MASTER_POD=$(kubectl get pod -l app=redis-master -o jsonpath='{.items[0].metadata.name}')
kubectl exec $REDIS_MASTER_POD -- redis-cli info replication
```

### Step 10: Test Application Write/Read Operations
```bash
# Access the application and verify functionality
# 1. Open http://NODE_IP:30009 in browser
# 2. Submit a guestbook entry
# 3. Verify the entry appears in the list
# 4. Refresh page to test read operations

# Test with curl (basic functionality)
curl -X POST -d "content=Test Entry from kubectl" http://$NODE_IP:30009/
curl -s http://$NODE_IP:30009 | grep "Test Entry"
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Pods Not Starting
```bash
# Check pod events for issues
kubectl describe pods

# Common issues:
# - Image pull errors
# - Resource constraints  
# - Configuration errors

# Check pod logs
kubectl logs -l app=redis-master
kubectl logs -l app=redis-slave
kubectl logs -l app=frontend
```

#### 2. Service Discovery Issues
```bash
# Verify service endpoints
kubectl get endpoints

# Check if pods match service selectors
kubectl get pods -l app=redis-master --show-labels
kubectl get service redis-master -o yaml | grep selector

# Test DNS from within cluster
kubectl run test-pod --image=busybox -it --rm --restart=Never -- nslookup redis-master
```

#### 3. NodePort Access Issues
```bash
# Verify NodePort service configuration
kubectl get service frontend -o jsonpath='{.spec.ports[0].nodePort}'

# Check if port 30009 is accessible
kubectl get service frontend -o wide

# Test from within cluster first
kubectl exec $FRONTEND_POD -- curl localhost:80
```

#### 4. Redis Connection Issues
```bash
# Check Redis master logs
kubectl logs deployment/redis-master

# Test Redis master from slave
REDIS_SLAVE_POD=$(kubectl get pod -l app=redis-slave -o jsonpath='{.items[0].metadata.name}')
kubectl exec $REDIS_SLAVE_POD -- redis-cli -h redis-master ping

# Verify environment variables
kubectl exec $REDIS_SLAVE_POD -- printenv GET_HOSTS_FROM
```

#### 5. Resource Limit Issues
```bash
# Check resource usage vs requests
kubectl top pods

# Check if pods are being evicted
kubectl get events --sort-by=.metadata.creationTimestamp

# Describe nodes for resource availability
kubectl describe nodes
```

## Validation Commands

### Complete System Check
```bash
#!/bin/bash
echo "=== Guestbook Application Health Check ==="

# 1. Check deployments
echo "Checking deployments..."
kubectl get deployments | grep -E "(redis-master|redis-slave|frontend)"

# 2. Check all pods are running
echo "Checking pod status..."
TOTAL_PODS=$(kubectl get pods --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods --no-headers | grep Running | wc -l)
echo "Pods: $RUNNING_PODS/$TOTAL_PODS running"

# 3. Check services
echo "Checking services..."
kubectl get services | grep -E "(redis-master|redis-slave|frontend)"

# 4. Test NodePort
echo "Testing NodePort access..."
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$NODE_IP:30009)
echo "Frontend HTTP response: $HTTP_CODE"

# 5. Test service discovery
echo "Testing service discovery..."
FRONTEND_POD=$(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec $FRONTEND_POD -- nslookup redis-master > /dev/null && echo "✓ redis-master DNS works"
kubectl exec $FRONTEND_POD -- nslookup redis-slave > /dev/null && echo "✓ redis-slave DNS works"

echo "=== Health Check Complete ==="
```

### Resource Verification Script
```bash
#!/bin/bash
echo "=== Resource Allocation Verification ==="

DEPLOYMENTS=("redis-master" "redis-slave" "frontend")

for deploy in "${DEPLOYMENTS[@]}"; do
    echo "Checking $deploy resources..."
    CPU_REQUEST=$(kubectl get deployment $deploy -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
    MEM_REQUEST=$(kubectl get deployment $deploy -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
    echo "  CPU Request: $CPU_REQUEST"
    echo "  Memory Request: $MEM_REQUEST"
done
```

## Production Considerations

### Current Configuration Analysis
- **High Availability**: Frontend has 3 replicas for redundancy
- **Scalability**: Redis slaves provide read scalability  
- **Resource Management**: All containers have resource requests
- **Service Discovery**: DNS-based communication between tiers
- **External Access**: NodePort for development/testing

### Production Improvements Needed
1. **Persistent Storage**: Add PersistentVolumes for Redis data
2. **Security**: Implement Redis authentication and network policies
3. **Monitoring**: Add Prometheus metrics and health checks
4. **Load Balancing**: Replace NodePort with LoadBalancer/Ingress
5. **Auto-scaling**: Configure HPA based on CPU/memory metrics
6. **Backup Strategy**: Implement Redis backup and recovery

### Scaling Strategies

#### Horizontal Scaling
```bash
# Scale frontend for more capacity
kubectl scale deployment frontend --replicas=5

# Scale Redis slaves for more read capacity
kubectl scale deployment redis-slave --replicas=4
```

#### Vertical Scaling
```bash
# Increase resources (requires pod restart)
kubectl patch deployment frontend -p '{"spec":{"template":{"spec":{"containers":[{"name":"php-redis-devops","resources":{"requests":{"cpu":"200m","memory":"200Mi"}}}]}}}}'
```

## Success Criteria
✅ Redis master deployment with 1 replica  
✅ Redis slave deployment with 2 replicas  
✅ Frontend deployment with 3 replicas  
✅ All pods running and healthy  
✅ Services configured with correct ports  
✅ NodePort 30009 accessible externally  
✅ Service discovery working between tiers  
✅ Resource requests applied to all containers  
✅ Application functional (can add/view entries)  

## Application Access Information
- **External URL**: `http://NODE_IP:30009`
- **Internal Frontend**: `frontend.default.svc.cluster.local:80`
- **Redis Master**: `redis-master.default.svc.cluster.local:6379`
- **Redis Slaves**: `redis-slave.default.svc.cluster.local:6379`

## Architecture Benefits Demonstrated
1. **Tier Separation**: Clear separation between frontend and backend
2. **Load Distribution**: Multiple frontend replicas handle user traffic
3. **Read Scaling**: Redis slaves distribute read operations
4. **Service Discovery**: Automatic service resolution via DNS
5. **Resource Management**: Controlled resource allocation
6. **High Availability**: Application remains available if individual pods fail