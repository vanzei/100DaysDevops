# Day 051: Execute Rolling Updates in Kubernetes - Complete Resource Guide

## 🎯 Challenge Overview

**Objective:** Execute a rolling update for an existing nginx deployment, upgrading from current version to nginx:1.19 while ensuring zero downtime and operational continuity.

**Key Requirements:**
- Existing deployment: `nginx-deployment`
- Target image: `nginx:1.19`
- Ensure all pods operational post-update
- Maintain service availability during update

## 🔄 Rolling Updates: Strategic Foundation

### **What is a Rolling Update?**
A rolling update is a deployment strategy that gradually replaces instances of the previous version with the new version, ensuring:
- **Zero Downtime:** Service remains available throughout the update
- **Gradual Transition:** Pods are updated incrementally, not all at once
- **Rollback Capability:** Can revert to previous version if issues arise
- **Health Validation:** New pods must pass readiness checks before old ones are terminated

### **Why Rolling Updates Matter:**
- **Production Safety:** Minimizes risk of service disruption
- **User Experience:** No service interruption for end users
- **Operational Confidence:** Safe deployment practices in live environments
- **Business Continuity:** Critical for mission-critical applications

## 📊 Rolling Update Process Flow

### **Phase 1: Pre-Update Assessment**
```bash
# Check current deployment status
kubectl get deployment nginx-deployment
kubectl describe deployment nginx-deployment
kubectl get pods -l app=nginx-deployment
kubectl get replicasets
```

**Key Metrics to Capture:**
- Current image version
- Number of replicas
- Pod readiness status
- Resource utilization
- Service endpoints

### **Phase 2: Update Execution**
```bash
# Method 1: Set image directly (Recommended for this challenge)
kubectl set image deployment/nginx-deployment nginx=nginx:1.19

# Method 2: Edit deployment manifest
kubectl edit deployment nginx-deployment

# Method 3: Apply updated YAML
kubectl apply -f updated-deployment.yaml
```

### **Phase 3: Update Monitoring**
```bash
# Watch rollout progress in real-time
kubectl rollout status deployment/nginx-deployment

# Monitor pod lifecycle during update
kubectl get pods -l app=nginx-deployment -w

# Check rollout history
kubectl rollout history deployment/nginx-deployment
```

### **Phase 4: Post-Update Validation**
```bash
# Verify all pods are running new version
kubectl get pods -o wide
kubectl describe pods -l app=nginx-deployment

# Check deployment status
kubectl get deployment nginx-deployment
kubectl describe deployment nginx-deployment

# Validate service connectivity
kubectl get services
# Test application functionality if accessible
```

## 🔍 Critical Monitoring Points

### **During Rolling Update - Watch for:**

#### **1. Pod Lifecycle Transitions**
```bash
# Monitor pod status changes
kubectl get pods -l app=nginx-deployment -w

# Expected sequence per pod:
# Old Pod: Running → Terminating → (deleted)
# New Pod: Pending → ContainerCreating → Running → Ready
```

#### **2. Readiness and Health Checks**
```bash
# Verify new pods pass readiness checks
kubectl describe pods -l app=nginx-deployment

# Check for readiness probe failures
kubectl get events --sort-by=.lastTimestamp
```

#### **3. Service Availability**
```bash
# Ensure service endpoints are updated
kubectl describe service nginx-service  # if service exists
kubectl get endpoints

# Test connectivity (if load balancer/ingress configured)
curl -I http://service-endpoint/
```

#### **4. Resource Utilization**
```bash
# Monitor resource usage during transition
kubectl top pods -l app=nginx-deployment
kubectl top nodes
```

## ⚠️ Common Issues & Troubleshooting

### **Issue 1: Rollout Stuck or Hanging**

**Symptoms:**
- `kubectl rollout status` shows "Waiting for rollout to finish"
- New pods stuck in ContainerCreating or Pending state
- Old pods not terminating

**Diagnostic Commands:**
```bash
kubectl describe deployment nginx-deployment
kubectl describe pods -l app=nginx-deployment
kubectl get events --sort-by=.lastTimestamp
```

**Common Causes & Solutions:**
- **Image Pull Issues:** Verify image exists and is accessible
- **Resource Constraints:** Check node capacity and pod resource requests
- **Readiness Probe Failures:** Review probe configuration and application startup
- **Network Policies:** Ensure pod networking is configured correctly

### **Issue 2: New Pods Failing Health Checks**

**Symptoms:**
- New pods show "0/1 Ready"
- CrashLoopBackOff or ImagePullBackOff status
- Readiness probe failures in events

**Diagnostic Commands:**
```bash
kubectl logs deployment/nginx-deployment
kubectl describe pods -l app=nginx-deployment
kubectl get events --field-selector involvedObject.kind=Pod
```

**Investigation Steps:**
1. Check application logs for startup errors
2. Verify image compatibility and configuration
3. Review resource limits and requests
4. Test readiness/liveness probe endpoints

### **Issue 3: Service Disruption During Update**

**Symptoms:**
- Service temporarily unavailable
- Connection errors from clients
- Inconsistent responses between versions

**Prevention & Mitigation:**
- Ensure adequate replica count (minimum 2 for availability)
- Configure proper readiness probes
- Set appropriate `maxUnavailable` and `maxSurge` values
- Test update process in staging environment first

## 🔧 Advanced Rolling Update Configuration

### **Deployment Strategy Customization**
```yaml
# deployment.yaml - Advanced rolling update configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1        # Maximum pods that can be unavailable
      maxSurge: 1             # Maximum extra pods during update
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        readinessProbe:         # Critical for zero-downtime updates
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
```

### **Strategy Parameters Explained:**

| Parameter | Description | Strategic Impact |
|-----------|-------------|------------------|
| `maxUnavailable` | Max pods that can be down during update | Controls availability during update |
| `maxSurge` | Max extra pods created during update | Controls resource usage and speed |
| `readinessProbe` | Health check before routing traffic | Ensures only healthy pods receive traffic |
| `livenessProbe` | Health check for pod restart | Automatically recovers from failures |

### **Conservative vs Aggressive Update Strategies:**

#### **Conservative (High Availability)**
```yaml
strategy:
  rollingUpdate:
    maxUnavailable: 0    # No downtime allowed
    maxSurge: 1         # One extra pod at a time
```

#### **Aggressive (Faster Updates)**
```yaml
strategy:
  rollingUpdate:
    maxUnavailable: 50%  # Half of pods can be down
    maxSurge: 50%       # Create 50% extra pods
```

## 🚀 Version Comparison & Validation

### **Pre-Update Baseline Capture**
```bash
# Document current state
kubectl get deployment nginx-deployment -o yaml > pre-update-deployment.yaml
kubectl get pods -l app=nginx-deployment -o wide > pre-update-pods.txt
kubectl describe deployment nginx-deployment > pre-update-description.txt

# Test current functionality
curl -I http://service-endpoint/ > pre-update-response.txt
```

### **Post-Update Validation Checklist**

#### **1. Deployment Status Verification**
```bash
# Verify deployment is fully updated
kubectl get deployment nginx-deployment
# Expected: READY should equal DESIRED, UP-TO-DATE should equal DESIRED

# Check deployment conditions
kubectl describe deployment nginx-deployment | grep -A 10 Conditions
# Look for: Progressing=True, Available=True
```

#### **2. Pod Version Verification**
```bash
# Verify all pods are running new image
kubectl get pods -l app=nginx-deployment -o jsonpath='{.items[*].spec.containers[*].image}'
# Should show: nginx:1.19 for all pods

# Check pod ages (new pods should have recent creation times)
kubectl get pods -l app=nginx-deployment -o wide
```

#### **3. ReplicaSet Analysis**
```bash
# Verify old ReplicaSet is scaled down to 0
kubectl get replicasets -l app=nginx-deployment
# Old RS should show 0 desired/current/ready
# New RS should show full replica count
```

#### **4. Functional Testing**
```bash
# Test application functionality
kubectl port-forward deployment/nginx-deployment 8080:80 &
curl -I http://localhost:8080/
curl http://localhost:8080/ | head -n 20

# Compare nginx version in response headers
curl -I http://localhost:8080/ | grep Server
# Should show nginx/1.19.x
```

#### **5. Performance Comparison**
```bash
# Compare resource usage
kubectl top pods -l app=nginx-deployment
kubectl describe deployment nginx-deployment | grep -A 5 "Pod Template"

# Check for any performance regressions
# Monitor response times, error rates, resource consumption
```

## 🔄 Rollback Strategies

### **When to Rollback:**
- New version shows critical bugs or performance issues
- Health checks consistently failing
- Service disruption detected
- Business-critical functionality broken

### **Rollback Commands:**
```bash
# Quick rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to specific revision
kubectl rollout history deployment/nginx-deployment
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Monitor rollback progress
kubectl rollout status deployment/nginx-deployment
```

### **Post-Rollback Validation:**
```bash
# Verify rollback success
kubectl get deployment nginx-deployment
kubectl get pods -l app=nginx-deployment -o jsonpath='{.items[*].spec.containers[*].image}'

# Test functionality
curl -I http://service-endpoint/
```

## 📈 Best Practices for Production Rolling Updates

### **Pre-Update Preparation:**
1. **Test in Staging:** Always test the exact update process in a staging environment
2. **Monitor Baseline:** Establish current performance and error rate baselines
3. **Backup Strategy:** Ensure rollback plan is tested and ready
4. **Communication:** Notify stakeholders of planned update window
5. **Health Checks:** Verify readiness and liveness probes are properly configured

### **During Update Execution:**
1. **Monitor Continuously:** Watch pod transitions and service availability
2. **Validate Incrementally:** Test functionality as new pods become ready
3. **Be Ready to Rollback:** Have rollback commands ready if issues arise
4. **Document Issues:** Log any unexpected behavior for analysis

### **Post-Update Verification:**
1. **Comprehensive Testing:** Verify all critical functionality works
2. **Performance Monitoring:** Watch for performance regressions
3. **Error Rate Analysis:** Monitor logs for increased error rates
4. **User Feedback:** Check for user-reported issues
5. **Documentation:** Update deployment records and lessons learned

## 🛠️ Monitoring and Observability

### **Essential Monitoring During Updates:**
```bash
# Real-time pod monitoring
watch kubectl get pods -l app=nginx-deployment

# Event monitoring
kubectl get events --sort-by=.lastTimestamp -w

# Service endpoint monitoring
watch kubectl get endpoints

# Resource utilization monitoring
watch kubectl top pods -l app=nginx-deployment
```

### **Logging Strategy:**
```bash
# Application logs
kubectl logs -f deployment/nginx-deployment

# Previous version logs (for comparison)
kubectl logs deployment/nginx-deployment --previous

# Deployment events
kubectl describe deployment nginx-deployment | grep Events -A 20
```

## 🔗 Integration with CI/CD

### **Automated Rolling Update Pipeline:**
```yaml
# Example GitLab CI/CD stage
deploy_production:
  stage: deploy
  script:
    - kubectl set image deployment/nginx-deployment nginx=nginx:${CI_COMMIT_SHA}
    - kubectl rollout status deployment/nginx-deployment --timeout=300s
    - ./run-smoke-tests.sh
  only:
    - main
  when: manual
```

### **Canary Deployment Consideration:**
For critical applications, consider canary deployments:
- Deploy new version to small percentage of pods
- Monitor metrics and user feedback
- Gradually increase traffic to new version
- Full rollout only after validation

## 📚 Learning Progression Context

### **Kubernetes Deployment Evolution:**
- **Day 48:** Basic pod deployment (single instance)
- **Day 49:** Deployment controllers (replica management)
- **Day 50:** Resource governance (performance optimization)
- **Day 51:** Rolling updates (zero-downtime deployments) ← **Current**
- **Future:** Blue-green deployments, canary releases, GitOps

### **Strategic Skills Developed:**
1. **Zero-Downtime Deployment:** Essential production skill
2. **Risk Management:** Safe deployment practices
3. **Monitoring & Observability:** Real-time system health assessment
4. **Incident Response:** Rollback procedures and troubleshooting
5. **Production Operations:** Live system management

---

**Key Takeaway:** Rolling updates are fundamental to maintaining high-availability services in production Kubernetes environments. Master this pattern to ensure safe, reliable application deployments with zero downtime and quick recovery options.