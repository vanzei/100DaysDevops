# Kubernetes Orchestration - 100 Days DevOps Challenge

## Overview

Kubernetes orchestration was covered in Days 48-67 of the challenge, focusing on container orchestration, cluster management, deployments, services, and production-grade Kubernetes operations. This module advanced from single containers to managing complex distributed applications at scale.

## What We Practiced

### Cluster Fundamentals
- **Kubernetes cluster setup** and node management
- **Pod lifecycle** and container orchestration
- **Deployment management** and rolling updates
- **Service discovery** and load balancing

### Resource Management
- **Resource limits** and requests configuration
- **Horizontal Pod Autoscaling** (HPA)
- **ConfigMaps and Secrets** for configuration management
- **Persistent Volumes** and storage management

### Networking & Security
- **Service types** (ClusterIP, NodePort, LoadBalancer)
- **Ingress controllers** for external access
- **Network policies** for traffic control
- **RBAC** (Role-Based Access Control)

### Advanced Operations
- **StatefulSets** for stateful applications
- **Jobs and CronJobs** for batch processing
- **DaemonSets** for node-level operations
- **Operators** and custom resource management

## Key Commands Practiced

### Cluster Management
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces

# Node operations
kubectl describe node node-name
kubectl get node node-name -o yaml

# Cluster configuration
kubectl config view
kubectl config current-context
kubectl config use-context cluster-name
```

### Pod Operations
```bash
# Create pod from YAML
kubectl apply -f pod.yaml

# List pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --all-namespaces

# Pod details
kubectl describe pod pod-name
kubectl logs pod-name
kubectl logs -f pod-name  # Follow logs

# Execute commands in pod
kubectl exec -it pod-name -- /bin/bash
kubectl exec pod-name -- ps aux

# Delete pod
kubectl delete pod pod-name
kubectl delete -f pod.yaml
```

### Deployment Management
```bash
# Create deployment
kubectl create deployment nginx --image=nginx:latest
kubectl apply -f deployment.yaml

# List deployments
kubectl get deployments
kubectl get deployments -o wide

# Scale deployment
kubectl scale deployment nginx --replicas=3

# Rolling update
kubectl set image deployment/nginx nginx=nginx:1.21
kubectl rollout status deployment/nginx

# Rollback deployment
kubectl rollout undo deployment/nginx
kubectl rollout history deployment/nginx
```

### Service Management
```bash
# Create service
kubectl expose deployment nginx --port=80 --type=ClusterIP
kubectl apply -f service.yaml

# List services
kubectl get services
kubectl get services -o wide

# Service details
kubectl describe service service-name

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it -- wget -O- http://service-name
```

### Configuration Management
```bash
# Create ConfigMap
kubectl create configmap app-config --from-literal=APP_ENV=production
kubectl create configmap app-config --from-file=config.properties

# Create Secret
kubectl create secret generic app-secret --from-literal=DB_PASSWORD=password
kubectl create secret tls tls-secret --cert=cert.pem --key=key.pem

# List ConfigMaps and Secrets
kubectl get configmaps
kubectl get secrets

# Use in pod
kubectl apply -f pod-with-config.yaml
```

## Technical Topics Covered

### Kubernetes Architecture
```text
Kubernetes Control Plane
├── API Server (kube-apiserver)
├── etcd (Cluster Store)
├── Controller Manager
│   ├── Node Controller
│   ├── Replication Controller
│   └── Endpoint Controller
└── Scheduler (kube-scheduler)

Worker Nodes
├── Kubelet (Node Agent)
├── Kube Proxy (Network Proxy)
└── Container Runtime (Docker/containerd)
```

### Pod Lifecycle
```text
Pod States:
Pending ────► Running ────► Succeeded/Failed
     │            │
     │            └─► Terminating (Graceful shutdown)
     │
     └─► Failed (Scheduling issues, resource constraints)
```

### Service Types
```text
ClusterIP (Default):
┌─────────────┐     ┌─────────────┐
│   Service   │────▶│   Pods      │
│ 10.0.0.1:80 │     │             │
└─────────────┘     └─────────────┘

NodePort:
┌─────────────┐     ┌─────────────┐
│   Node      │────▶│   Service   │
│ 192.168.1.1 │     │             │
│    :30080   │     └─────────────┘
└─────────────┘            │
                           ▼
                    ┌─────────────┐
                    │   Pods      │
                    └─────────────┘

LoadBalancer:
┌─────────────┐     ┌─────────────┐
│   Cloud LB  │────▶│   Service   │
│ 203.0.113.1 │     │             │
└─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   Nodes     │
                    └─────────────┘
```

### Deployment Strategy
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Production Environment Considerations

### High Availability
- **Multi-master setup**: Multiple control plane nodes
- **Pod anti-affinity**: Distribute pods across nodes
- **Cluster autoscaling**: Automatic node scaling
- **Backup and recovery**: etcd backups and disaster recovery

### Security & Compliance
- **RBAC**: Role-based access control for users and services
- **Network policies**: Traffic segmentation and isolation
- **Pod security standards**: Security contexts and policies
- **Image security**: Vulnerability scanning and trusted registries

### Resource Optimization
- **Resource requests/limits**: Guaranteed and burstable QoS
- **Horizontal Pod Autoscaler**: Automatic scaling based on metrics
- **Cluster Autoscaler**: Node pool scaling
- **Resource quotas**: Namespace-level resource limits

### Monitoring & Observability
- **Metrics collection**: Prometheus and custom metrics
- **Logging aggregation**: Centralized logging with ELK stack
- **Distributed tracing**: Jaeger for request tracing
- **Alerting**: Prometheus Alertmanager for notifications

### Storage Management
- **Persistent Volumes**: Dynamic provisioning and lifecycle
- **Storage classes**: Different storage tiers and performance
- **Backup strategies**: Volume snapshots and disaster recovery
- **Stateful applications**: StatefulSets for databases and stateful apps

## Real-World Applications

### Complete Web Application Stack
```yaml
# web-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: myapp:latest
        ports:
        - containerPort: 3000
        env:
        - name: DB_HOST
          value: "postgres-service"
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"

---
# web-app-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP

---
# web-app-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

### Database with StatefulSet
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "myapp"
        - name: POSTGRES_USER
          value: "appuser"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Network Policy for Security
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-app-network-policy
spec:
  podSelector:
    matchLabels:
      app: web-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
  - to: []  # Allow external DNS
    ports:
    - protocol: UDP
      port: 53
```

## Troubleshooting Common Issues

### Pod Issues
```bash
# Check pod status
kubectl get pods
kubectl describe pod pod-name

# Check pod logs
kubectl logs pod-name --previous  # Previous container logs

# Debug pod
kubectl exec -it pod-name -- /bin/bash

# Check resource usage
kubectl top pods
kubectl top nodes
```

### Service Issues
```bash
# Check service endpoints
kubectl get endpoints service-name

# Test service DNS
kubectl run test-pod --image=busybox --rm -it -- nslookup service-name

# Check service configuration
kubectl describe service service-name
```

### Deployment Issues
```bash
# Check rollout status
kubectl rollout status deployment/deployment-name

# Check deployment events
kubectl describe deployment deployment-name

# Debug failed pods
kubectl get pods | grep Error
kubectl logs pod-name
```

### Network Issues
```bash
# Check network policies
kubectl get networkpolicies

# Test pod connectivity
kubectl run test-pod --image=busybox --rm -it -- ping pod-ip

# Check DNS resolution
kubectl run test-pod --image=busybox --rm -it -- nslookup kubernetes.default
```

## Key Takeaways

1. **Declarative Configuration**: Define desired state, let Kubernetes manage it
2. **Resource Management**: Always set requests and limits for predictable behavior
3. **Security First**: Implement RBAC, network policies, and secure configurations
4. **Monitoring**: Comprehensive observability for troubleshooting and optimization
5. **Scalability**: Design for horizontal scaling and high availability

## Next Steps

- **Service Mesh**: Istio for advanced traffic management
- **GitOps**: ArgoCD for declarative deployments
- **Custom Operators**: Extend Kubernetes with custom controllers
- **Multi-cluster**: Federation and cross-cluster management
- **Edge Computing**: Kubernetes at the edge

Kubernetes has become the de facto standard for container orchestration, enabling organizations to run complex, scalable applications with confidence and reliability.