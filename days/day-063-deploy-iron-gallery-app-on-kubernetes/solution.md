# Day 063: Deploy Iron Gallery App on Kubernetes

## Challenge Objective
Deploy a multi-tier Iron Gallery web application on Kubernetes with MariaDB database backend, implementing proper resource isolation, volume management, and service networking.

## Solution Overview

This solution demonstrates a **3-tier web application architecture** with:
- **Frontend**: Iron Gallery (Nginx-based web server)
- **Database**: MariaDB (MySQL-compatible database)
- **Networking**: Service discovery and external access
- **Storage**: Volume mounting for application data

## Step-by-Step Implementation

### Step 1: Deploy All Resources
```bash
# Apply the complete deployment
kubectl apply -f iron-gallery-deployment.yaml
```

### Step 2: Verify Namespace Creation
```bash
# Check namespace
kubectl get namespaces | grep iron-namespace-xfusion

# Expected output:
# iron-namespace-xfusion   Active   <age>
```

### Step 3: Verify Deployments
```bash
# Check all resources in the namespace
kubectl get all -n iron-namespace-xfusion

# Check deployment status
kubectl get deployments -n iron-namespace-xfusion

# Expected output:
# NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
# iron-db-deployment-xfusion      1/1     1            1           <age>
# iron-gallery-deployment-xfusion 1/1     1            1           <age>
```

### Step 4: Verify Pods
```bash
# Check pod status
kubectl get pods -n iron-namespace-xfusion

# Expected output:
# NAME                                             READY   STATUS    RESTARTS   AGE
# iron-db-deployment-xfusion-xxxx                 1/1     Running   0          <age>
# iron-gallery-deployment-xfusion-xxxx            1/1     Running   0          <age>

# Check pod details
kubectl describe pods -n iron-namespace-xfusion
```

### Step 5: Verify Services
```bash
# Check services
kubectl get services -n iron-namespace-xfusion

# Expected output:
# NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# iron-db-service-xfusion      ClusterIP   10.x.x.x        <none>        3306/TCP       <age>
# iron-gallery-service-xfusion NodePort    10.x.x.x        <none>        80:32678/TCP   <age>
```

### Step 6: Test Application Access
```bash
# Get node information
kubectl get nodes -o wide

# Test access (replace NODE_IP with actual node IP)
curl http://NODE_IP:32678

# Or if running locally:
curl http://localhost:32678
```

### Step 7: Verify Volume Mounts
```bash
# Check volume mounts for gallery app
kubectl exec -n iron-namespace-xfusion deployment/iron-gallery-deployment-xfusion -- ls -la /usr/share/nginx/html/

# Check database volumes
kubectl exec -n iron-namespace-xfusion deployment/iron-db-deployment-xfusion -- ls -la /var/lib/mysql/
```

### Step 8: Verify Database Configuration
```bash
# Check database environment variables
kubectl exec -n iron-namespace-xfusion deployment/iron-db-deployment-xfusion -- printenv | grep MYSQL

# Test database connection (from within database pod)
kubectl exec -n iron-namespace-xfusion deployment/iron-db-deployment-xfusion -- mysql -u gallery_user -p'YourComplexUserPassword123!' -e "SHOW DATABASES;"
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Pods Not Starting
```bash
# Check pod events
kubectl describe pods -n iron-namespace-xfusion

# Check logs
kubectl logs -n iron-namespace-xfusion deployment/iron-gallery-deployment-xfusion
kubectl logs -n iron-namespace-xfusion deployment/iron-db-deployment-xfusion
```

#### 2. Service Connection Issues
```bash
# Test service endpoints
kubectl get endpoints -n iron-namespace-xfusion

# Test internal connectivity
kubectl exec -n iron-namespace-xfusion deployment/iron-gallery-deployment-xfusion -- nslookup iron-db-service-xfusion
```

#### 3. Resource Limit Issues
```bash
# Check resource usage
kubectl top pods -n iron-namespace-xfusion

# Check resource limits
kubectl describe pods -n iron-namespace-xfusion | grep -A 5 "Limits:"
```

#### 4. Volume Mount Issues
```bash
# Check volume status
kubectl describe pods -n iron-namespace-xfusion | grep -A 10 "Volumes:"

# Verify mount points
kubectl exec -n iron-namespace-xfusion deployment/iron-gallery-deployment-xfusion -- df -h
```

## Validation Commands

### Complete System Check
```bash
# 1. Verify namespace
kubectl get ns iron-namespace-xfusion

# 2. Verify deployments
kubectl get deployments -n iron-namespace-xfusion

# 3. Verify pods are running
kubectl get pods -n iron-namespace-xfusion --no-headers | awk '{print $3}' | grep -v Running && echo "Some pods not running!" || echo "All pods running!"

# 4. Verify services
kubectl get svc -n iron-namespace-xfusion

# 5. Test NodePort access
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -o /dev/null -w "%{http_code}" http://$NODE_IP:32678

# 6. Verify resource limits
kubectl describe deployment iron-gallery-deployment-xfusion -n iron-namespace-xfusion | grep -A 3 "Limits:"
```

## Architecture Components

### Resource Specifications

#### Iron Gallery (Frontend)
- **Image**: `kodekloud/irongallery:2.0`
- **Resources**: 100Mi memory, 50m CPU
- **Volumes**: 2 emptyDir volumes for config and uploads
- **Service**: NodePort on 32678

#### Iron DB (Database)  
- **Image**: `kodekloud/irondb:2.0`
- **Environment**: MySQL database with custom user
- **Volume**: emptyDir for database files
- **Service**: ClusterIP for internal access only

### Security Considerations
- Database not exposed externally (ClusterIP)
- Separate user account for application database access
- Resource limits to prevent resource exhaustion
- Namespace isolation for multi-tenancy

## Production Readiness Notes

**Current Configuration**: Suitable for development/testing
**Production Changes Needed**:
1. Replace emptyDir with PersistentVolumes
2. Use Kubernetes Secrets for passwords
3. Implement proper health checks
4. Add monitoring and logging
5. Use Ingress instead of NodePort
6. Configure StatefulSet for database
7. Implement backup strategies

## Success Criteria
✅ Namespace `iron-namespace-xfusion` created  
✅ Two deployments running (iron-gallery, iron-db)  
✅ Two services configured (NodePort and ClusterIP)  
✅ Resource limits applied to gallery app  
✅ Volumes mounted correctly  
✅ Application accessible via NodePort 32678  
✅ Database configured with proper environment variables