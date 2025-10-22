
kubectl get deployment nginx-deployment
kubectl describe deployment nginx-deployment
kubectl get pods -l app=nginx-deployment
kubectl get replicasets

## Check for the container name

kubectl set image deployment/nginx-deployment <container name>=nginx:1.19
kubectl rollout status deployment/nginx-deployment
