# Day 016: Nginx Load Balancer Configuration

## Step B: Configure Load Balancing

You need to modify `/etc/nginx/nginx.conf` to add load balancing configuration. Here's what you need to add:

### 1. Add upstream block in the http context

Add this upstream block inside the `http` section of your nginx.conf:

```nginx
upstream app_servers {
    server stapp01:8080;
    server stapp02:8080;
    server stapp03:8080;
}
```

### 2. Configure the server block

Add or modify the server block to proxy requests to the upstream:

```nginx
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://app_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Complete Configuration Example

Here's how your `/etc/nginx/nginx.conf` should look (key sections):

```nginx
# nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Load balancer upstream configuration
    upstream app_servers {
        server stapp01:8080;
        server stapp02:8080;
        server stapp03:8080;
    }

    # Default server configuration
    server {
        listen 80;
        server_name _;
        
        location / {
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## Commands to Execute

1. **Backup the original configuration:**
```bash
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
```

2. **Edit the configuration:**
```bash
sudo nano /etc/nginx/nginx.conf
# or
sudo vi /etc/nginx/nginx.conf
```

3. **Test the configuration:**
```bash
sudo nginx -t
```

4. **Reload nginx:**
```bash
sudo systemctl reload nginx
```

## Step C: Verify Apache Services

Check that Apache is running on all app servers (you may need to SSH to each):

```bash
# Check Apache status on each app server
ssh user@stapp01 'sudo systemctl status httpd'
ssh user@stapp02 'sudo systemctl status httpd'
ssh user@stapp03 'sudo systemctl status httpd'

# Check Apache is listening on port 8080
ssh user@stapp01 'sudo netstat -tlnp | grep :8080'
ssh user@stapp02 'sudo netstat -tlnp | grep :8080'
ssh user@stapp03 'sudo netstat -tlnp | grep :8080'
```

## Step D: Test the Configuration

After configuring nginx, test the load balancer:

```bash
# Test from the load balancer server
curl -I http://localhost/

# Check nginx status
sudo systemctl status nginx

# Monitor nginx access logs
sudo tail -f /var/log/nginx/access.log
```

## Troubleshooting

If you encounter issues:

1. **Check nginx error logs:**
```bash
sudo tail -f /var/log/nginx/error.log
```

2. **Verify upstream servers are reachable:**
```bash
curl -I http://stapp01:8080/
curl -I http://stapp02:8080/
curl -I http://stapp03:8080/
```

3. **Check firewall rules:**
```bash
sudo firewall-cmd --list-all
```