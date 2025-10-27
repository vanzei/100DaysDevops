# Day 066: Deploy MySQL on Kubernetes

## Challenge Objective
Deploy a production-ready MySQL database on Kubernetes with persistent storage, secure secret management, and external access configuration.

## Solution Overview

This solution demonstrates **database deployment patterns** including:
- **Persistent Storage**: PersistentVolume and PersistentVolumeClaim management
- **Secret Management**: Secure handling of database credentials
- **Service Configuration**: External database access via NodePort
- **Environment Configuration**: Secure injection of database parameters

## Step-by-Step Implementation

### Step 1: Create MySQL Secrets
```bash
# Create the required secrets first
kubectl create secret generic mysql-root-pass --from-literal=password=YUIidhb667

kubectl create secret generic mysql-user-pass --from-literal=username=kodekloud_top --from-literal=password=8FmzjvFU6S

kubectl create secret generic mysql-db-url --from-literal=database=kodekloud_db1
```

### Step 2: Deploy MySQL Resources
```bash
# Apply the MySQL deployment (PV, PVC, Deployment, Service)
kubectl apply -f mysql-deployment.yaml
```

### Step 3: Verify Secrets Creation
```bash
# Check all secrets
kubectl get secrets

# Expected secrets:
# mysql-root-pass   Opaque   1      <age>
# mysql-user-pass   Opaque   2      <age>
# mysql-db-url      Opaque   1      <age>

# Verify secret contents (base64 decoded)
kubectl get secret mysql-root-pass -o jsonpath='{.data.password}' | base64 -d
kubectl get secret mysql-user-pass -o jsonpath='{.data.username}' | base64 -d
```

### Step 4: Verify Persistent Storage
```bash
# Check PersistentVolume
kubectl get pv mysql-pv

# Expected output:
# NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS
# mysql-pv   250Mi      RWO            Retain           Bound    default/mysql-pv-claim   manual

# Check PersistentVolumeClaim
kubectl get pvc mysql-pv-claim

# Expected output:
# NAME             STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS
# mysql-pv-claim   Bound    mysql-pv   250Mi      RWO            manual
```

### Step 5: Verify Deployment Status
```bash
# Check deployment
kubectl get deployment mysql-deployment

# Expected output:
# NAME               READY   UP-TO-DATE   AVAILABLE   AGE
# mysql-deployment   1/1     1            1           <age>

# Check pod status
kubectl get pods -l app=mysql

# Check deployment details
kubectl describe deployment mysql-deployment
```

### Step 6: Verify Service Configuration
```bash
# Check service
kubectl get service mysql

# Expected output:
# NAME    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
# mysql   NodePort   10.96.x.x       <none>        3306:30007/TCP   <age>

# Verify NodePort is 30007
kubectl get service mysql -o jsonpath='{.spec.ports[0].nodePort}'
```

### Step 7: Test Database Connectivity
```bash
# Get pod name
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# Test root connection
kubectl exec -it $MYSQL_POD -- mysql -u root -pYUIidhb667 -e "SHOW DATABASES;"

# Test application user connection
kubectl exec -it $MYSQL_POD -- mysql -u kodekloud_top -p8FmzjvFU6S -e "USE kodekloud_db1; SHOW TABLES;"

# Verify database creation
kubectl exec -it $MYSQL_POD -- mysql -u root -pYUIidhb667 -e "SHOW DATABASES;" | grep kodekloud_db1
```

### Step 8: Verify Volume Mount
```bash
# Check volume mount inside container
kubectl exec -it $MYSQL_POD -- df -h /var/lib/mysql

# Check MySQL data directory
kubectl exec -it $MYSQL_POD -- ls -la /var/lib/mysql/

# Verify database files exist
kubectl exec -it $MYSQL_POD -- ls -la /var/lib/mysql/kodekloud_db1/
```

### Step 9: Test External Access
```bash
# Get node IP (if using external client)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Test connection from outside cluster (if mysql client available)
# mysql -h $NODE_IP -P 30007 -u kodekloud_top -p8FmzjvFU6S kodekloud_db1

echo "MySQL accessible at: $NODE_IP:30007"
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Pod Not Starting - Volume Issues
```bash
# Check pod events
kubectl describe pod $MYSQL_POD

# Common volume issues:
# - PV not bound to PVC
# - Insufficient permissions on hostPath
# - Storage not available

# Fix volume permissions (if using hostPath)
sudo mkdir -p /tmp/mysql-data
sudo chown -R 999:999 /tmp/mysql-data
```

#### 2. MySQL Initialization Errors
```bash
# Check MySQL logs
kubectl logs $MYSQL_POD

# Common initialization issues:
# - Invalid passwords in secrets
# - Database initialization errors
# - Insufficient resources

# Verify secret values
kubectl get secret mysql-root-pass -o yaml
```

#### 3. Connection Issues
```bash
# Test internal connectivity
kubectl run mysql-client --image=mysql:8.0 -it --rm --restart=Never -- mysql -h mysql -u kodekloud_top -p8FmzjvFU6S kodekloud_db1

# Check service endpoints
kubectl get endpoints mysql

# Verify service selector matches pod labels
kubectl get pods -l app=mysql --show-labels
```

#### 4. Persistent Volume Issues
```bash
# Check PV status
kubectl describe pv mysql-pv

# Check PVC binding
kubectl describe pvc mysql-pv-claim

# Common PV issues:
# - Access mode mismatch
# - Storage class issues
# - Node selector problems
```

## Validation Commands

### Complete System Check
```bash
# 1. Verify all secrets exist
kubectl get secrets | grep mysql | wc -l | grep -q "3" && echo "✓ All secrets created" || echo "✗ Missing secrets"

# 2. Verify PV and PVC are bound
kubectl get pvc mysql-pv-claim -o jsonpath='{.status.phase}' | grep -q "Bound" && echo "✓ Storage bound" || echo "✗ Storage not bound"

# 3. Verify deployment is ready
kubectl get deployment mysql-deployment -o jsonpath='{.status.readyReplicas}' | grep -q "1" && echo "✓ Deployment ready" || echo "✗ Deployment not ready"

# 4. Verify service has correct nodePort
kubectl get service mysql -o jsonpath='{.spec.ports[0].nodePort}' | grep -q "30007" && echo "✓ NodePort correct" || echo "✗ NodePort incorrect"

# 5. Test database connectivity
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}')
kubectl exec $MYSQL_POD -- mysql -u root -pYUIidhb667 -e "SELECT 1;" &>/dev/null && echo "✓ Database accessible" || echo "✗ Database connection failed"
```

### Health Check Script
```bash
#!/bin/bash
echo "MySQL Deployment Health Check"
echo "=============================="

# Check if pod is running
if kubectl get pod -l app=mysql | grep -q "Running"; then
    echo "✓ MySQL pod is running"
else
    echo "✗ MySQL pod is not running"
    kubectl get pods -l app=mysql
    exit 1
fi

# Check if database is responding
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}')
if kubectl exec $MYSQL_POD -- mysqladmin ping -u root -pYUIidhb667 &>/dev/null; then
    echo "✓ MySQL is responding to ping"
else
    echo "✗ MySQL is not responding"
    exit 1
fi

# Check if application database exists
if kubectl exec $MYSQL_POD -- mysql -u root -pYUIidhb667 -e "USE kodekloud_db1;" &>/dev/null; then
    echo "✓ Application database exists"
else
    echo "✗ Application database missing"
    exit 1
fi

echo "All checks passed!"
```

## Production Considerations

### Current Configuration Analysis
- **Storage**: 250Mi hostPath (suitable for development only)
- **Deployment**: Single replica (no high availability)
- **Security**: Basic secrets (production needs external secret management)
- **Monitoring**: No health monitoring configured
- **Backups**: No backup strategy implemented

### Production Improvements Needed
1. **Use StatefulSet instead of Deployment**
2. **Implement proper persistent storage (not hostPath)**
3. **Add resource limits and requests**
4. **Configure comprehensive monitoring**
5. **Implement automated backup strategy**
6. **Use external secret management**
7. **Configure SSL/TLS encryption**

## Success Criteria
✅ Three secrets created (mysql-root-pass, mysql-user-pass, mysql-db-url)  
✅ PersistentVolume (mysql-pv) created with 250Mi capacity  
✅ PersistentVolumeClaim (mysql-pv-claim) bound to PV  
✅ MySQL deployment running with mounted persistent volume  
✅ NodePort service accessible on port 30007  
✅ Environment variables injected from secrets  
✅ Database and user created successfully  
✅ Volume mounted at /var/lib/mysql  

## Database Configuration Details
- **Root Password**: YUIidhb667 (from mysql-root-pass secret)
- **Application User**: kodekloud_top (from mysql-user-pass secret)
- **Application Password**: 8FmzjvFU6S (from mysql-user-pass secret)
- **Database Name**: kodekloud_db1 (from mysql-db-url secret)
- **External Access**: NodePort 30007
- **Internal Access**: Service name `mysql` on port 3306