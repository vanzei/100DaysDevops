# Day 016: Nginx Load Balancer - Technical Resources

## Location Block Configuration Explained

### Core Location Block
```nginx
location / {
    proxy_pass http://app_servers;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Detailed Breakdown

#### 1. `location /`
- **Purpose**: Matches all incoming requests (since `/` is the root path)
- **What it does**: Any request to your load balancer (like `http://loadbalancer/`, `http://loadbalancer/page1`, etc.) will be handled by this block
- **Variations**:
  ```nginx
  location /api/ { }          # Matches /api/* requests
  location /static/ { }       # Matches /static/* requests
  location ~* \.(jpg|png)$ { } # Regex for image files
  ```

#### 2. `proxy_pass http://app_servers;`
- **Purpose**: The core load balancing directive
- **What it does**: Forwards/proxies the request to one of the servers defined in the `app_servers` upstream block
- **Load Balancing**: Nginx automatically distributes requests among backend servers

#### 3. `proxy_set_header Host $host;`
- **Purpose**: Preserves the original Host header
- **What it does**: Sends the original hostname that the client requested to the backend server
- **Example**: If client requests `http://mysite.com`, the backend receives `Host: mysite.com`
- **Why important**: Backend applications often need to know the original hostname for routing, SSL, and URL generation

#### 4. `proxy_set_header X-Real-IP $remote_addr;`
- **Purpose**: Passes the client's real IP address to the backend
- **What it does**: Backend servers can see the actual client IP instead of the load balancer's IP
- **Important for**: Logging, security, geolocation, rate limiting, analytics

#### 5. `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`
- **Purpose**: Maintains a chain of IP addresses through multiple proxies
- **What it does**: Adds client IP to the X-Forwarded-For header (handles proxy chains)
- **Format**: `X-Forwarded-For: client_ip, proxy1_ip, proxy2_ip`
- **Use case**: When multiple proxies/load balancers are in the chain

#### 6. `proxy_set_header X-Forwarded-Proto $scheme;`
- **Purpose**: Tells backend servers the original protocol used (HTTP/HTTPS)
- **What it does**: Backend knows if the original request was secure or not
- **Important for**: SSL redirects, security policies, generating correct URLs

## Upstream Configuration Deep Dive

### Basic Upstream Block
```nginx
upstream app_servers {
    server stapp01:5000;
    server stapp02:5000;
    server stapp03:5000;
}
```

### Upstream Variations and Load Balancing Methods

#### 1. Round Robin (Default)
```nginx
upstream app_servers {
    server stapp01:5000;
    server stapp02:5000;
    server stapp03:5000;
}
```
- **How it works**: Requests are distributed evenly in rotation
- **Use case**: When all servers have similar capacity

#### 2. Weighted Round Robin
```nginx
upstream app_servers {
    server stapp01:5000 weight=3;
    server stapp02:5000 weight=2;
    server stapp03:5000 weight=1;
}
```
- **How it works**: Server with weight=3 gets 3x more requests than weight=1
- **Use case**: When servers have different capacities

#### 3. Least Connections
```nginx
upstream app_servers {
    least_conn;
    server stapp01:5000;
    server stapp02:5000;
    server stapp03:5000;
}
```
- **How it works**: Routes to server with fewest active connections
- **Use case**: When requests have varying processing times

#### 4. IP Hash (Session Persistence)
```nginx
upstream app_servers {
    ip_hash;
    server stapp01:5000;
    server stapp02:5000;
    server stapp03:5000;
}
```
- **How it works**: Same client IP always goes to same server
- **Use case**: When you need session stickiness

#### 5. Hash with Custom Key
```nginx
upstream app_servers {
    hash $request_uri consistent;
    server stapp01:5000;
    server stapp02:5000;
    server stapp03:5000;
}
```
- **How it works**: Uses custom variable for consistent hashing
- **Use case**: Cache optimization, custom distribution logic

### Server Parameters and Health Checks

#### Advanced Server Configuration
```nginx
upstream app_servers {
    server stapp01:5000 weight=2 max_fails=3 fail_timeout=30s;
    server stapp02:5000 weight=2 max_fails=3 fail_timeout=30s;
    server stapp03:5000 weight=1 max_fails=2 fail_timeout=60s backup;
}
```

**Parameters explained:**
- `weight=2`: Server gets 2x more requests
- `max_fails=3`: Mark server as unavailable after 3 failed attempts
- `fail_timeout=30s`: Wait 30 seconds before trying failed server again
- `backup`: Only use this server when all others are down

#### Health Check Configuration
```nginx
upstream app_servers {
    server stapp01:5000 max_fails=2 fail_timeout=10s;
    server stapp02:5000 max_fails=2 fail_timeout=10s;
    server stapp03:5000 max_fails=2 fail_timeout=10s;
    
    # Health check settings
    keepalive 32;
}
```

## Application-Specific Upstream Configurations

### 1. Web Applications (Node.js, Python, PHP)
```nginx
upstream web_app {
    least_conn;
    server app1:3000 weight=2;
    server app2:3000 weight=2;
    server app3:3000 weight=1;
    keepalive 16;
}

server {
    listen 80;
    location / {
        proxy_pass http://web_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 2. API Services (REST/GraphQL)
```nginx
upstream api_servers {
    least_conn;
    server api1:8080 max_fails=3 fail_timeout=30s;
    server api2:8080 max_fails=3 fail_timeout=30s;
    server api3:8080 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 80;
    location /api/ {
        proxy_pass http://api_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Content-Type application/json;
        
        # API specific timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### 3. WebSocket Applications
```nginx
upstream websocket_servers {
    ip_hash;  # Important for WebSocket persistence
    server ws1:8080;
    server ws2:8080;
    server ws3:8080;
}

server {
    listen 80;
    location /ws/ {
        proxy_pass http://websocket_servers;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket specific timeouts
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
```

### 4. Static Content with CDN Fallback
```nginx
upstream static_servers {
    server cdn1.example.com:80;
    server cdn2.example.com:80;
    server local_static:8080 backup;
}

server {
    listen 80;
    location /static/ {
        proxy_pass http://static_servers;
        proxy_set_header Host $host;
        proxy_cache static_cache;
        proxy_cache_valid 200 1h;
        proxy_cache_valid 404 1m;
    }
}
```

### 5. Database Load Balancing (Read Replicas)
```nginx
upstream db_read_replicas {
    least_conn;
    server db-read1:5432 weight=2;
    server db-read2:5432 weight=2;
    server db-read3:5432 weight=1;
}

upstream db_write_master {
    server db-master:5432;
}

server {
    listen 80;
    
    # Read operations
    location /api/read/ {
        proxy_pass http://db_read_replicas;
        proxy_set_header Host $host;
    }
    
    # Write operations
    location /api/write/ {
        proxy_pass http://db_write_master;
        proxy_set_header Host $host;
    }
}
```

## Advanced Upstream Features

### 1. Dynamic Upstream with DNS Resolution
```nginx
upstream dynamic_servers {
    server app.example.com:80 resolve;
    server backup.example.com:80 backup resolve;
}
```

### 2. Unix Socket Upstream
```nginx
upstream unix_socket_app {
    server unix:/var/run/app.sock;
    server unix:/var/run/app2.sock;
}
```

### 3. Upstream with Custom Variables
```nginx
upstream conditional_servers {
    server app1:8080;
    server app2:8080;
}

map $request_uri $backend_pool {
    ~^/admin/  admin_servers;
    default    conditional_servers;
}

upstream admin_servers {
    server admin1:8080;
    server admin2:8080;
}
```

## Monitoring and Debugging

### 1. Upstream Status Module
```nginx
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}
```

### 2. Custom Logging for Load Balancer
```nginx
log_format upstream_log '$remote_addr - $remote_user [$time_local] '
                       '"$request" $status $body_bytes_sent '
                       '"$http_referer" "$http_user_agent" '
                       'upstream_addr=$upstream_addr '
                       'upstream_status=$upstream_status '
                       'upstream_response_time=$upstream_response_time';

access_log /var/log/nginx/upstream.log upstream_log;
```

## Best Practices

### 1. Security Headers
```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $host;

# Security headers
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
```

### 2. Performance Optimization
```nginx
upstream app_servers {
    server app1:8080;
    server app2:8080;
    keepalive 32;           # Connection pooling
    keepalive_requests 100; # Requests per connection
    keepalive_timeout 60s;  # Connection timeout
}
```

### 3. Error Handling
```nginx
proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
proxy_next_upstream_timeout 5s;
proxy_next_upstream_tries 3;
```

This comprehensive guide covers all aspects of nginx load balancer configuration, from basic setups to advanced application-specific configurations.