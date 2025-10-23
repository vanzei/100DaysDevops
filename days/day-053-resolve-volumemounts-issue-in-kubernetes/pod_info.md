thor@jumphost ~$ kubectl describe pod/nginx-phpfpm 
Name:             nginx-phpfpm
Namespace:        default
Priority:         0
Service Account:  default
Node:             kodekloud-control-plane/172.17.0.2
Start Time:       Thu, 23 Oct 2025 21:32:31 +0000
Labels:           app=php-app
Annotations:      <none>
Status:           Running
IP:               10.244.0.5
IPs:
  IP:  10.244.0.5
Containers:
  php-fpm-container:
    Container ID:   containerd://6dc687f125dafe1a11fd3dc2aa96901134cdfc4e8200d5ba71497273ae56e4bf
    Image:          php:7.2-fpm-alpine
    Image ID:       docker.io/library/php@sha256:2e2d92415f3fc552e9a62548d1235f852c864fcdc94bcf2905805d92baefc87f
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 23 Oct 2025 21:32:34 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /usr/share/nginx/html from shared-files (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-54622 (ro)
  nginx-container:
    Container ID:   containerd://4d55fc9011b67fbc3dbd212cd4ce36f87d2e5fcb1857a96afe4ac2ed320ac41f
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:029d4461bd98f124e531380505ceea2072418fdf28752aa73b7b273ba3048903
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 23 Oct 2025 21:32:41 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/nginx/nginx.conf from nginx-config-volume (rw,path="nginx.conf")
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-54622 (ro)
      /var/www/html from shared-files (rw)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  shared-files:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  nginx-config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      nginx-config
    Optional:  false
  kube-api-access-54622:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m10s  default-scheduler  Successfully assigned default/nginx-phpfpm to kodekloud-control-plane
  Normal  Pulling    2m10s  kubelet            Pulling image "php:7.2-fpm-alpine"
  Normal  Pulled     2m7s   kubelet            Successfully pulled image "php:7.2-fpm-alpine" in 2.83513635s (2.835153569s including waiting)
  Normal  Created    2m7s   kubelet            Created container php-fpm-container
  Normal  Started    2m7s   kubelet            Started container php-fpm-container
  Normal  Pulling    2m7s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     2m1s   kubelet            Successfully pulled image "nginx:latest" in 5.991534329s (5.99155017s including waiting)
  Normal  Created    2m1s   kubelet            Created container nginx-container
  Normal  Started    2m     kubelet            Started container nginx-container
thor@jumphost ~$ 
thor@jumphost ~$ kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      3m13s
thor@jumphost ~$ kubectl describe configmap nginx-config
Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
events {
}
http {
  server {
    listen 8099 default_server;
    listen [::]:8099 default_server;

    # Set nginx to serve files from the shared volume!
    root /var/www/html;
    index  index.html index.htm index.php;
    server_name _;
    location / {
      try_files $uri $uri/ =404;
    }
    location ~ \.php$ {
      include fastcgi_params;
      fastcgi_param REQUEST_METHOD $request_method;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_pass 127.0.0.1:9000;
    }
  }
}


BinaryData
====

Events:  <none>
thor@jumphost ~$ 