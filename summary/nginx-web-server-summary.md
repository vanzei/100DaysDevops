# Nginx Web Server - 100 Days DevOps Challenge

## Overview

Nginx web server configuration was covered in Days 15, 16, and 20 of the challenge, focusing on web server setup, load balancing, SSL/TLS configuration, and reverse proxy functionality. This module provided essential web infrastructure skills for serving applications and managing traffic.

## What We Practiced

### Basic Web Server Setup
- **Nginx installation** and service management
- **Virtual host configuration** for multiple sites
- **Static file serving** and directory configuration
- **Basic security hardening** and access controls

### Load Balancing & Proxying
- **Load balancer configuration** for application scaling
- **Reverse proxy setup** for backend applications
- **Upstream server management** and health checks
- **Session persistence** and sticky sessions

### SSL/TLS Configuration
- **SSL certificate installation** and management
- **HTTPS redirection** and security headers
- **SSL/TLS optimization** and cipher suites
- **Certificate renewal** automation

### Advanced Features
- **Rate limiting** and DDoS protection
- **Caching strategies** for performance optimization
- **Compression** and content optimization
- **Logging and monitoring** configuration

## Key Commands Practiced

### Nginx Installation & Setup
```bash
# Install Nginx
sudo yum install nginx

# Start and enable service
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx

# Verify installation
nginx -v
curl http://localhost
```

### Configuration Management
```bash
# Edit main configuration
sudo vi /etc/nginx/nginx.conf

# Test configuration syntax
sudo nginx -t

# Reload configuration
sudo nginx -s reload

# Restart service
sudo systemctl restart nginx

# View error logs
sudo tail -f /var/log/nginx/error.log

# View access logs
sudo tail -f /var/log/nginx/access.log
```

### SSL Certificate Setup
```bash
# Create SSL directory
sudo mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate self-signed certificate (development only)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt

# Set proper permissions
sudo chmod 600 /etc/ssl/private/selfsigned.key
sudo chmod 644 /etc/ssl/certs/selfsigned.crt
```

### Basic Security Configuration
```bash
# Hide Nginx version
sudo sed -i 's/# server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf

# Disable unwanted HTTP methods
# Add to server block: if ($request_method !~ ^(GET|HEAD|POST)$ ) { return 405; }

# Configure fail2ban for Nginx
sudo yum install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Technical Topics Covered

### Nginx Architecture
```text
Nginx Master Process
├── Worker Processes (CPU cores)
│   ├── Event Loop (epoll/kqueue)
│   ├── Connection Handling
│   └── Request Processing
└── Cache Manager Process

Configuration Hierarchy
├── Main Context (nginx.conf)
├── HTTP Context
│   ├── Server Blocks (Virtual Hosts)
│   └── Location Blocks (URL Routing)
└── Upstream Blocks (Load Balancing)
```

### Virtual Host Configuration
```nginx
# /etc/nginx/conf.d/example.com.conf
server {
    listen 80;
    server_name example.com www.example.com;

    # Root directory
    root /var/www/example.com/html;
    index index.html index.htm;

    # Access and error logs
    access_log /var/log/nginx/example.com.access.log;
    error_log /var/log/nginx/example.com.error.log;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # Location blocks
    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

### Load Balancing Configuration
```nginx
# Upstream backend servers
upstream backend {
    least_conn;  # Load balancing method
    server backend1.example.com:8080 weight=3;
    server backend2.example.com:8080 weight=2;
    server backend3.example.com:8080 weight=1 backup;

    # Health checks
    health_check interval=5s fails=3 passes=2;
}

server {
    listen 80;
    server_name loadbalancer.example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Session persistence
        sticky cookie srv_id expires=1h domain=.example.com path=/;

        # Timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
}
```

### SSL/TLS Server Configuration
```nginx
# SSL Configuration
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;

    # SSL Certificate
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;

    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # SSL Session caching
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # HSTS (HTTP Strict Transport Security)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Redirect HTTP to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$server_name$request_uri;
}
```

## Production Environment Considerations

### Performance Optimization
- **Worker processes**: Match CPU core count
- **Worker connections**: Optimize for concurrent connections
- **Buffer sizes**: Tune for application requirements
- **Caching**: Static file and proxy caching

### Security Hardening
- **SSL/TLS**: Latest protocols and cipher suites
- **Rate limiting**: DDoS protection and abuse prevention
- **Access controls**: IP whitelisting and authentication
- **Security headers**: OWASP recommended headers

### High Availability
- **Load balancing**: Multiple backend servers
- **Health checks**: Automatic failure detection
- **Session affinity**: Sticky sessions for stateful apps
- **Failover**: Backup servers and graceful degradation

### Monitoring & Logging
- **Access logs**: Request tracking and analytics
- **Error logs**: Debugging and troubleshooting
- **Metrics collection**: Performance monitoring
- **Log rotation**: Storage management and retention

## Real-World Applications

### Complete Web Application Stack
```nginx
# Frontend application server
server {
    listen 80;
    server_name app.example.com;

    # SSL redirection
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.example.com;

    # SSL configuration
    ssl_certificate /etc/ssl/certs/app.example.com.crt;
    ssl_certificate_key /etc/ssl/private/app.example.com.key;

    # Root directory
    root /var/www/app.example.com/dist;
    index index.html;

    # API proxy
    location /api/ {
        proxy_pass http://backend_upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static assets with caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }
}

# Backend API server
server {
    listen 80;
    server_name api.example.com;

    # Rate limiting
    limit_req zone=api burst=10 nodelay;

    location / {
        proxy_pass http://api_upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS headers
        add_header 'Access-Control-Allow-Origin' 'https://app.example.com' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type' always;

        if ($request_method = 'OPTIONS') {
            return 204;
        }
    }
}

# Upstream configurations
upstream backend_upstream {
    least_conn;
    server backend1.internal:3000;
    server backend2.internal:3000;
    server backend3.internal:3000;
}

upstream api_upstream {
    ip_hash;  # Session affinity
    server api1.internal:8080;
    server api2.internal:8080;
}
```

### Microservices API Gateway
```nginx
# API Gateway configuration
upstream auth_service {
    server auth.internal:8081;
}

upstream user_service {
    server user.internal:8082;
}

upstream product_service {
    server product.internal:8083;
}

upstream order_service {
    server order.internal:8084;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    # SSL configuration
    ssl_certificate /etc/ssl/certs/api.example.com.crt;
    ssl_certificate_key /etc/ssl/private/api.example.com.key;

    # Rate limiting
    limit_req zone=api burst=20 nodelay;
    limit_req_status 429;

    # Authentication service
    location /auth/ {
        proxy_pass http://auth_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # User service
    location /users/ {
        auth_request /auth/verify;
        proxy_pass http://user_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-User-ID $auth_user_id;
    }

    # Product service
    location /products/ {
        auth_request /auth/verify;
        proxy_pass http://product_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-User-ID $auth_user_id;
    }

    # Order service
    location /orders/ {
        auth_request /auth/verify;
        proxy_pass http://order_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-User-ID $auth_user_id;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### High-Performance Media Server
```nginx
# Video streaming server
server {
    listen 443 ssl http2;
    server_name video.example.com;

    # SSL configuration
    ssl_certificate /etc/ssl/certs/video.example.com.crt;
    ssl_certificate_key /etc/ssl/private/video.example.com.key;

    # Root directory for video files
    root /var/www/video;

    # Security: Only allow GET and HEAD methods
    if ($request_method !~ ^(GET|HEAD)$) {
        return 405;
    }

    # HLS streaming
    location ~ \.m3u8$ {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods GET;
        add_header Cache-Control no-cache;
        types {
            application/vnd.apple.mpegurl m3u8;
        }
    }

    # Video segments
    location ~ \.ts$ {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods GET;
        add_header Cache-Control "public, max-age=31536000";
        expires 1y;
        types {
            video/mp2t ts;
        }
    }

    # MP4 pseudo-streaming
    location ~ \.mp4$ {
        mp4;
        mp4_buffer_size 1m;
        mp4_max_buffer_size 5m;
        add_header Cache-Control "public, max-age=31536000";
        expires 1y;
    }

    # DASH streaming
    location ~ \.mpd$ {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods GET;
        add_header Cache-Control no-cache;
        types {
            application/dash+xml mpd;
        }
    }
}
```

### Let's Encrypt SSL Automation
```bash
#!/bin/bash
# SSL certificate renewal script

DOMAIN="example.com"
EMAIL="admin@example.com"

# Install certbot
sudo yum install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --email $EMAIL --agree-tos --non-interactive

# Test renewal
sudo certbot renew --dry-run

# Setup cron job for renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -

# Reload Nginx after renewal (certbot does this automatically)
```

## Troubleshooting Common Issues

### Configuration Issues
```bash
# Test configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/error.log

# Validate server blocks
sudo nginx -T | grep -A 20 "server {"

# Check for syntax errors
sudo nginx -c /etc/nginx/nginx.conf
```

### Performance Issues
```bash
# Check worker processes
ps aux | grep nginx

# Monitor connections
sudo ss -tlnp | grep :80
sudo ss -tlnp | grep :443

# Check resource usage
top -p $(pgrep nginx | tr '\n' ',' | sed 's/,$//')

# Analyze access logs
sudo goaccess /var/log/nginx/access.log -o /var/www/html/report.html --log-format=COMBINED
```

### SSL/TLS Issues
```bash
# Test SSL certificate
openssl s_client -connect example.com:443 -servername example.com

# Check certificate validity
openssl x509 -in /etc/ssl/certs/example.com.crt -text -noout | grep -A 2 "Validity"

# Test SSL configuration
openssl s_client -connect example.com:443 -tls1_2 -cipher ECDHE-RSA-AES256-GCM-SHA384

# SSL Labs test
curl -s "https://www.ssllabs.com/ssltest/analyze.html?d=example.com" | grep -o '<title>.*</title>'
```

### Load Balancing Issues
```bash
# Check upstream server status
curl -H "Host: example.com" http://localhost/upstream_status

# Test individual backend servers
curl http://backend1.example.com:8080/health
curl http://backend2.example.com:8080/health

# Monitor load balancer statistics
curl http://localhost/nginx_status
```

## Key Takeaways

1. **Reverse Proxy**: Nginx excels as a reverse proxy and load balancer
2. **Performance**: Asynchronous, event-driven architecture handles high concurrency
3. **Flexibility**: Extensive module ecosystem for various use cases
4. **Security**: Strong SSL/TLS support and security features
5. **Monitoring**: Comprehensive logging and status monitoring

## Next Steps

- **NGINX Plus**: Enterprise features and support
- **Kubernetes Ingress**: Container orchestration integration
- **Service Mesh**: Advanced traffic management with Istio
- **API Gateway**: Advanced API management features
- **Web Application Firewall**: ModSecurity integration

Nginx has become the backbone of modern web infrastructure, powering everything from simple websites to complex microservices architectures with its high performance and flexibility.