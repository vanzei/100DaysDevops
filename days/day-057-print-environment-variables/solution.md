# Day 057: Print Environment Variables - Solution Guide

## Quick Solution

### Deploy the Pod
```bash
kubectl apply -f pod-envars.yaml
```

### Verify the Output
```bash
kubectl logs print-envars-greeting
```

**Expected Output:**
```
Welcome to xFusionCorp Group
```

## Step-by-Step Implementation

### Step 1: Create Pod YAML
The pod specification includes:
- Pod name: `print-envars-greeting`
- Container name: `print-env-container`
- Image: `bash:latest`
- Three environment variables with specified values
- Command that echoes the environment variables
- Restart policy set to `Never`

### Step 2: Apply Configuration
```bash
kubectl apply -f pod-envars.yaml
```

### Step 3: Monitor Pod Status
```bash
kubectl get pod print-envars-greeting
```

Expected status progression:
1. `Pending` → `Running` → `Completed`

### Step 4: View Output
```bash
kubectl logs print-envars-greeting
```

## Verification Commands

```bash
# Check pod details
kubectl describe pod print-envars-greeting

# View environment variables (if pod is still running)
kubectl exec print-envars-greeting -- env | grep -E "(GREETING|COMPANY|GROUP)"

# Check pod events
kubectl get events --field-selector involvedObject.name=print-envars-greeting
```

## Key Implementation Points

1. **Environment Variables**: Defined in the `env` section of the container spec
2. **Command Execution**: Uses shell parameter expansion `$(VARIABLE)` syntax
3. **Restart Policy**: Set to `Never` to prevent continuous restarts
4. **Image Choice**: `bash:latest` provides the necessary shell environment

## Cleanup
```bash
kubectl delete pod print-envars-greeting
```

This solution demonstrates fundamental Kubernetes environment variable management and pod lifecycle concepts.