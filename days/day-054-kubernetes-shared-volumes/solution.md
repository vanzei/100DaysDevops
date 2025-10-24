# Day 054: Kubernetes Shared Volumes - Implementation Guide

## Solution Overview

This challenge demonstrates creating a Kubernetes pod with two containers sharing an `emptyDir` volume, showcasing how containers can share temporary storage within a pod.

## Step-by-Step Implementation

### Step 1: Create the Pod Manifest

Create a file named `pod-shared-volume.yaml` with the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-share-xfusion
  labels:
    app: shared-volume-demo
spec:
  containers:
  - name: volume-container-xfusion-1
    image: fedora:latest
    command: ["sleep"]
    args: ["3600"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/news
  - name: volume-container-xfusion-2
    image: fedora:latest
    command: ["sleep"]
    args: ["3600"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/games
  volumes:
  - name: volume-share
    emptyDir: {}
```

**Why this step is necessary:**
- Defines the pod specification with exact naming requirements
- Configures two containers sharing the same volume at different mount points
- Uses `sleep` commands to keep containers running for testing

### Step 2: Deploy the Pod

```bash
kubectl apply -f pod-shared-volume.yaml
```

**Why this step is necessary:**
- Creates the pod and its containers in the Kubernetes cluster
- Initializes the shared `emptyDir` volume
- Starts both containers with the volume mounted

### Step 3: Verify Pod Creation

```bash
kubectl get pods
kubectl describe pod volume-share-xfusion
```

**Why this step is necessary:**
- Confirms the pod is running successfully
- Verifies both containers are in `Running` state
- Checks that volumes are mounted correctly

### Step 4: Test File Creation in Container 1

```bash
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-1 -- bash
echo "This is a test file from container 1" > /tmp/news/news.txt
echo "Creating news.txt in /tmp/news directory"
ls -la /tmp/news/
exit
```

**Why this step is necessary:**
- Creates a test file in the first container's mount path
- Demonstrates write access to the shared volume
- Provides content to verify sharing functionality

### Step 5: Verify File Access in Container 2

```bash
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-2 -- bash
ls -la /tmp/games/
cat /tmp/games/news.txt
echo "File successfully shared between containers!"
exit
```

**Why this step is necessary:**
- Confirms the file created in container 1 is accessible in container 2
- Validates that the same volume is mounted in both containers
- Proves the shared volume functionality works correctly

### Step 6: Additional Verification (Optional)

```bash
# Create a file from container 2 and verify in container 1
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-2 -- bash -c "echo 'From container 2' > /tmp/games/games.txt"

kubectl exec -it volume-share-xfusion -c volume-container-xfusion-1 -- bash -c "cat /tmp/news/games.txt"
```

**Why this step is necessary:**
- Demonstrates bidirectional file sharing
- Further validates the shared volume concept
- Shows both containers can read and write to the shared space

## Key Concepts Demonstrated

### 1. EmptyDir Volume Lifecycle
- Created when pod starts
- Shared among all containers in the pod
- Deleted when pod terminates
- Stored on the node's local storage

### 2. Volume Mount Flexibility
- Same volume mounted at different paths in different containers
- Each container sees the shared data through its own logical path
- Enables application-specific directory structures

### 3. Container Communication
- Containers can exchange data through the filesystem
- No network communication required for data sharing
- Useful for sidecar patterns and data pipelines

## Expected Results

After completing all steps, you should observe:

1. **Pod Status**: Pod `volume-share-xfusion` running with 2/2 containers ready
2. **File Sharing**: File `news.txt` created in container 1 visible in container 2
3. **Different Paths**: Same file accessible at `/tmp/news/news.txt` (container 1) and `/tmp/games/news.txt` (container 2)
4. **Bidirectional Access**: Both containers can read and write to the shared volume

## Cleanup

To remove the pod after testing:

```bash
kubectl delete pod volume-share-xfusion
```

## Troubleshooting

**Pod Won't Start:**
- Check resource availability: `kubectl describe pod volume-share-xfusion`
- Verify image availability: Ensure `fedora:latest` can be pulled

**Volume Not Shared:**
- Confirm volume names match between definition and mounts
- Check mount paths in container specifications
- Verify containers are in the same pod

**File Not Found:**
- Ensure you're in the correct container when creating/reading files
- Check file permissions and ownership
- Verify the correct mount path

This implementation demonstrates the fundamental concepts of Kubernetes shared volumes and provides a foundation for more complex volume sharing scenarios.