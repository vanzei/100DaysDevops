# Day 058: Deploy Grafana on Kubernetes Cluster - Solution Guide

## Quick Solution

### Step 1: Deploy Grafana Application
```bash
kubectl apply -f grafana-deployment.yaml
```

### Step 2: Create NodePort Service
```bash
kubectl apply -f grafana-service.yaml
```

### Step 3: Verify Deployment
```bash
# Check deployment status
kubectl get deployments

# Check pods
kubectl get pods -l app=grafana

# Check service
kubectl get svc grafana-service
```

### Step 4: Access Grafana
```bash
# Get node IP
kubectl get nodes -o wide

# Access Grafana at: http://NODE_IP:32000
# Default credentials: admin/admin
```

## Detailed Implementation Steps

### Deployment Configuration
- **Name**: `grafana-deployment-devops` (as required)
- **Image**: `grafana/grafana:latest` (official Grafana image)
- **Replicas**: 1 (sufficient for demo/development)
- **Port**: 3000 (Grafana default port)
- **Admin Password**: Set to "admin" for initial access

### Service Configuration
- **Type**: NodePort (as required)
- **NodePort**: 32000 (as specified)
- **Target Port**: 3000 (Grafana container port)
- **Selector**: Matches deployment labels

## Expected Results

### Deployment Status
```bash
kubectl get deployments
# NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
# grafana-deployment-devops   1/1     1            1           1m
```

### Service Status
```bash
kubectl get svc grafana-service
# NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
# grafana-service   NodePort   10.96.xxx.xxx   <none>        3000:32000/TCP   1m
```

### Pod Status
```bash
kubectl get pods -l app=grafana
# NAME                                     READY   STATUS    RESTARTS   AGE
# grafana-deployment-devops-xxxxxxxxx-xxxxx   1/1     Running   0          1m
```

## Accessing Grafana

1. **Get Node IP**:
   ```bash
   kubectl get nodes -o wide
   ```

2. **Access URL**: `http://NODE_IP:32000`

3. **Login Credentials**:
   - Username: `admin`
   - Password: `admin`

4. **Expected Result**: Grafana login page should be accessible

## Troubleshooting

### Pod Not Running
```bash
# Check pod details
kubectl describe pod -l app=grafana

# Check logs
kubectl logs -l app=grafana
```

### Service Not Accessible
```bash
# Verify service endpoints
kubectl get endpoints grafana-service

# Check if nodePort is properly configured
kubectl describe service grafana-service
```

### Image Pull Issues
```bash
# Check pod events
kubectl describe pod -l app=grafana

# Verify image availability
docker pull grafana/grafana:latest
```

## Cleanup
```bash
kubectl delete -f grafana-service.yaml
kubectl delete -f grafana-deployment.yaml
```

This solution provides a basic Grafana deployment suitable for development and testing purposes.