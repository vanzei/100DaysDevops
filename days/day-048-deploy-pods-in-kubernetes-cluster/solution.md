# Strategic considerations for pod.yaml structure:
apiVersion: v1          # Core API for basic resources
kind: Pod              # Fundamental workload unit
metadata:
  name: pod-httpd      # Unique identifier within namespace
  labels:
    app: httpd_app     # Selector label for future services
spec:
  containers:
  - name: httpd-container    # Container identifier
    image: httpd:latest      # Explicit tag specification
    # Consider: resource limits, ports, health checks


kubectl apply -f <filename>