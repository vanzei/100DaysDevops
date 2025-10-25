# Day 060: Persistent Volumes in Kubernetes - Resources & Strategy

## Challenge Overview
This challenge demonstrates implementing persistent storage in Kubernetes using PersistentVolumes (PV) and PersistentVolumeClaims (PVC) to provide durable storage for containerized applications.

## Strategic Approach

### Why Persistent Volumes in Kubernetes?

1. **Data Persistence**: Survive pod restarts and rescheduling
2. **Storage Abstraction**: Decouple storage from pod lifecycle
3. **Dynamic Provisioning**: Automatic storage allocation based on claims
4. **Multi-Access Patterns**: Support different access modes (RWO, RWX, ROX)
5. **Storage Classes**: Different performance and availability tiers

## Kubernetes Storage Architecture

### Storage Components Hierarchy
```
Storage Architecture
├── PersistentVolume (PV)
│   ├── Physical Storage (hostPath, NFS, AWS EBS, etc.)
│   ├── Storage Class (manual, fast-ssd, etc.)
│   ├── Capacity & Access Modes
│   └── Reclaim Policies
├── PersistentVolumeClaim (PVC)
│   ├── Storage Request (size, access mode)
│   ├── Storage Class Reference
│   └── Selector Labels
└── Pod Volume Mount
    ├── Volume Reference (PVC name)
    ├── Mount Path in Container
    └── Read/Write Permissions
```

### Challenge Implementation Flow
```
Implementation Flow
├── 1. PersistentVolume (pv-nautilus)
│   ├── 4Gi hostPath storage at /mnt/data
│   ├── manual storage class
│   └── ReadWriteOnce access mode
├── 2. PersistentVolumeClaim (pvc-nautilus)
│   ├── Request 3Gi storage
│   ├── manual storage class
│   └── ReadWriteOnce access mode
├── 3. Pod (pod-nautilus)
│   ├── nginx:latest container
│   ├── Mount PVC at /usr/share/nginx/html
│   └── Label: app=web-nautilus
└── 4. Service (web-nautilus)
    ├── NodePort type
    ├── Port 30008
    └── Target pod-nautilus
```

## Implementation Strategy

### Step 1: PersistentVolume Creation
**Objective**: Create physical storage resource with hostPath backend

**Why necessary**:
- Defines actual storage allocation on cluster nodes
- Sets capacity limits and access patterns
- Establishes storage class for claim matching
- Provides abstraction layer over physical storage

**Key Configuration**:
```yaml
spec:
  storageClassName: manual      # Matches PVC requirement
  capacity:
    storage: 4Gi               # Total available storage
  accessModes:
    - ReadWriteOnce           # Single pod read-write access
  hostPath:
    path: "/mnt/data"         # Node filesystem path
```

### Step 2: PersistentVolumeClaim Creation
**Objective**: Create storage request that binds to available PV

**Why necessary**:
- Abstracts storage requirements from pod specifications
- Enables dynamic binding to compatible PVs
- Provides namespace-scoped storage access
- Allows storage requests without knowing physical details

**Key Configuration**:
```yaml
spec:
  storageClassName: manual      # Must match PV storage class
  accessModes:
    - ReadWriteOnce           # Must be compatible with PV
  resources:
    requests:
      storage: 3Gi            # Must be <= PV capacity
```

### Step 3: Pod with Volume Mount
**Objective**: Deploy nginx with persistent storage for web content

**Why necessary**:
- Provides persistent storage for web server content
- Enables content to survive pod restarts
- Mounts at nginx document root for direct serving
- Demonstrates PVC consumption in pods

**Key Configuration**:
```yaml
spec:
  containers:
  - name: container-nautilus
    image: nginx:latest
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html  # Nginx document root
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc-nautilus
```

### Step 4: Service Exposure
**Objective**: Make web application accessible externally

**Why necessary**:
- Provides external access to nginx web server
- Uses NodePort for direct node access
- Enables testing of persistent storage functionality
- Completes the web application deployment

## Technical Deep Dive

### Access Modes Explained

| Access Mode | Description | Use Cases |
|-------------|-------------|-----------|
| `ReadWriteOnce` (RWO) | Single pod read-write | Databases, single-instance apps |
| `ReadOnlyMany` (ROX) | Multiple pods read-only | Static content, configuration |
| `ReadWriteMany` (RWX) | Multiple pods read-write | Shared filesystems, collaboration |

**For this challenge**: RWO is appropriate because:
- Single nginx pod needs write access
- Content typically served by one instance
- Simpler to implement and troubleshoot

### Storage Classes

#### Manual Storage Class
```yaml
storageClassName: manual
```
**Characteristics**:
- Pre-provisioned storage (no dynamic allocation)
- Administrator manually creates PVs
- Explicit binding between PV and PVC
- No automatic cleanup

#### Dynamic Storage Classes Examples
```yaml
# Fast SSD storage
storageClassName: fast-ssd

# Standard HDD storage
storageClassName: standard

# Network-attached storage
storageClassName: nfs-storage
```

### Volume Types Comparison

| Volume Type | Persistence | Scope | Use Cases |
|-------------|-------------|-------|-----------|
| `emptyDir` | Pod lifetime | Single pod | Temporary storage, cache |
| `hostPath` | Node lifetime | Node-bound | Local development, testing |
| `nfs` | External system | Multi-node | Shared persistent storage |
| `awsElasticBlockStore` | External system | Single-zone | AWS persistent disks |
| `gcePersistentDisk` | External system | Single-zone | GCP persistent disks |

**For this challenge**: hostPath is used because:
- Simple local development setup
- No external storage dependencies
- Direct access to node filesystem
- Quick setup and testing

### PV/PVC Binding Process

#### Binding Criteria
1. **Storage Class**: Must match exactly
2. **Access Mode**: PVC mode must be supported by PV
3. **Capacity**: PVC request must be <= PV capacity
4. **Selector**: Optional label-based selection
5. **Node Affinity**: Optional node-specific binding

#### Binding States
```
PV States: Available → Bound → Released → Failed
PVC States: Pending → Bound → Lost
```

## Advanced Configuration Options

### Node Affinity for hostPath
```yaml
spec:
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node-1
```

### Resource Requests and Limits
```yaml
spec:
  containers:
  - name: container-nautilus
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "500m"
```

### Volume Expansion
```yaml
spec:
  storageClassName: expandable-storage
  resources:
    requests:
      storage: 5Gi  # Expanded from 3Gi
```

### Multiple Volume Mounts
```yaml
spec:
  containers:
  - name: container-nautilus
    volumeMounts:
    - name: web-content
      mountPath: /usr/share/nginx/html
    - name: config-volume
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: web-content
    persistentVolumeClaim:
      claimName: pvc-nautilus
  - name: config-volume
    configMap:
      name: nginx-config
```

## Security Considerations

### File System Permissions
```yaml
spec:
  securityContext:
    runAsUser: 101        # nginx user
    runAsGroup: 101       # nginx group
    fsGroup: 101          # Volume ownership
```

### Read-Only Mounts
```yaml
volumeMounts:
- name: storage
  mountPath: /usr/share/nginx/html
  readOnly: true
```

### Pod Security Standards
```yaml
spec:
  securityContext:
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
```

## Monitoring and Troubleshooting

### Storage Monitoring Commands
```bash
# Check PV status
kubectl get pv

# Check PVC status
kubectl get pvc

# Describe PV details
kubectl describe pv pv-nautilus

# Describe PVC details
kubectl describe pvc pvc-nautilus

# Check pod volume mounts
kubectl describe pod pod-nautilus

# Check available storage on nodes
kubectl top nodes
```

### Common Issues and Solutions

#### 1. PVC Stuck in Pending
**Symptoms**: PVC remains in Pending state
**Causes**: 
- No matching PV available
- Storage class mismatch
- Insufficient capacity
- Access mode incompatibility

**Solutions**:
```bash
kubectl describe pvc pvc-nautilus
kubectl get pv
kubectl get storageclass
```

#### 2. Pod Stuck in Pending (Volume Issues)
**Symptoms**: Pod cannot start due to volume issues
**Causes**:
- PVC not bound
- Node affinity constraints
- Volume mount permission issues

**Solutions**:
```bash
kubectl describe pod pod-nautilus
kubectl get events --sort-by=.metadata.creationTimestamp
```

#### 3. Permission Denied on Volume Mount
**Symptoms**: Container cannot write to mounted volume
**Causes**:
- File system permissions
- Security context mismatch
- SELinux policies

**Solutions**:
```yaml
spec:
  securityContext:
    fsGroup: 101
```

#### 4. Data Not Persisting
**Symptoms**: Data lost after pod restart
**Causes**:
- Using emptyDir instead of PVC
- PV reclaim policy set to Delete
- Incorrect mount path

**Solutions**:
- Verify PVC is properly mounted
- Check PV reclaim policy
- Test with simple file creation

## Best Practices

### Production Considerations

#### 1. Storage Classes
- Use dynamic provisioning in production
- Define appropriate storage tiers (fast, standard, backup)
- Set reasonable default storage class

#### 2. Backup and Recovery
```yaml
# Backup PVC data
kubectl exec pod-nautilus -- tar -czf /backup/data.tar.gz /usr/share/nginx/html

# Schedule regular backups with CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-web-content
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
```

#### 3. Volume Expansion
```yaml
allowVolumeExpansion: true  # In StorageClass
```

#### 4. Resource Monitoring
```yaml
resources:
  requests:
    storage: 3Gi
  limits:
    storage: 10Gi
```

#### 5. Multi-Zone Deployment
```yaml
spec:
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
          - us-west-2a
          - us-west-2b
```

## Real-World Applications

### Use Cases for Persistent Volumes

#### 1. Database Storage
```yaml
# PostgreSQL with persistent storage
volumeMounts:
- name: postgres-data
  mountPath: /var/lib/postgresql/data
```

#### 2. Application Logs
```yaml
# Centralized log storage
volumeMounts:
- name: log-storage
  mountPath: /var/log/app
```

#### 3. Static Website Content
```yaml
# CMS content storage
volumeMounts:
- name: content-storage
  mountPath: /var/www/html
```

#### 4. Configuration Files
```yaml
# Persistent configuration
volumeMounts:
- name: config-storage
  mountPath: /etc/app/config
```

#### 5. Media File Storage
```yaml
# User uploads and media
volumeMounts:
- name: media-storage
  mountPath: /app/media
```

### Industry Applications
- **E-commerce**: Product images, user uploads, order data
- **Content Management**: Articles, media files, templates
- **Development**: Source code, build artifacts, test data
- **Analytics**: Log files, metrics data, reports
- **Backup Solutions**: Database backups, configuration snapshots

This challenge provides essential knowledge for implementing persistent storage in Kubernetes, fundamental for stateful applications and data persistence requirements.