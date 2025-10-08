# Day 015: Setup SSL for Nginx - Solution

## Overview

This solution covers the complete setup of SSL-enabled Nginx on App Server 2, including certificate configuration and testing.

## Prerequisites

- Access to App Server 2
- SSL certificate and key files present at `/tmp/nautilus.crt` and `/tmp/nautilus.key`
- Root or sudo privileges

## Step-by-Step Solution
The system admins team of xFusionCorp Industries needs to deploy a new application on App Server 2 in Stratos Datacenter. They have some pre-requites to get ready that server for application deployment. Prepare the server as per requirements shared below:



1. Install and configure nginx on App Server 2.


2. On App Server 2 there is a self signed SSL certificate and key present at location /tmp/nautilus.crt and /tmp/nautilus.key. Move them to some appropriate location and deploy the same in Nginx.


3. Create an index.html file with content Welcome! under Nginx document root.


4. For final testing try to access the App Server 2 link (either hostname or IP) from jump host using curl command. For example curl -Ik https://<app-server-ip>/.
### Step 1: Install Nginx on App Server 2

First, connect to App Server 2 and install nginx:

```bash
# Update package repository
sudo yum update -y

# Install nginx
sudo yum install -y nginx

# Verify installation
nginx -v
```

For Ubuntu/Debian systems:
```bash
# Update package repository
sudo apt update

# Install nginx
sudo apt install -y nginx

# Verify installation
nginx -v
```

### Step 2: Configure SSL Certificates

Move the SSL certificates to the appropriate nginx directory:

```bash
# Create SSL directory for nginx (if it doesn't exist)
sudo mkdir -p /etc/nginx/ssl

# Copy SSL certificate and key to nginx SSL directory
sudo cp /tmp/nautilus.crt /etc/nginx/ssl/
sudo cp /tmp/nautilus.key /etc/nginx/ssl/

# Set appropriate permissions
sudo chmod 644 /etc/nginx/ssl/nautilus.crt
sudo chmod 600 /etc/nginx/ssl/nautilus.key
sudo chown root:root /etc/nginx/ssl/nautilus.*

# Verify files are in place
ls -la /etc/nginx/ssl/
```

### Step 3: Create Nginx SSL Configuration

Create or modify the nginx configuration to enable SSL:

```bash
# Backup original configuration
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
```
# Edit nginx confit to add
# SSL Configuration
    ssl_certificate /etc/nginx/ssl/nautilus.crt;
    ssl_certificate_key /etc/nginx/ssl/nautilus.key;




### Step 4: Create Index.html File

Create the welcome page in nginx document root:

```bash
# Create index.html with required content
sudo tee /usr/share/nginx/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
</head>
<body>
    <h1>Welcome!</h1>
</body>
</html>
EOF

# Set appropriate permissions
sudo chown nginx:nginx /usr/share/nginx/html/index.html
sudo chmod 644 /usr/share/nginx/html/index.html
```

### Step 5: Test Configuration and Start Nginx

Test the nginx configuration and start the service:

```bash
# Test nginx configuration
sudo nginx -t

# If configuration test passes, start/restart nginx
sudo systemctl start nginx

# Enable nginx to start on boot
sudo systemctl enable nginx

# Check nginx status
sudo systemctl status nginx

# Verify nginx is listening on ports 80 and 443
sudo netstat -tlnp | grep nginx
# or
sudo ss -tlnp | grep nginx
```

### Step 6: Configure Firewall (if needed)

If firewall is enabled, allow HTTP and HTTPS traffic:

```bash
# For firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# For ufw (Ubuntu)
sudo ufw allow 'Nginx Full'

# For iptables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### Step 7: Test SSL Configuration

From the jump host, test the SSL configuration:

```bash
# Test HTTPS connection with curl
curl -Ik https://<app-server-2-ip>/

# Expected output should show:
# HTTP/2 200
# server: nginx
# content-type: text/html
# And SSL certificate information

# You can also test with verbose SSL information
curl -Ikv https://<app-server-2-ip>/

# Test HTTP redirect to HTTPS
curl -I http://<app-server-2-ip>/
# Should show 301 redirect to HTTPS
```

## Verification Commands

After completing the setup, verify everything is working:

```bash
# Check nginx is running
sudo systemctl status nginx

# Verify SSL files are in place
ls -la /etc/nginx/ssl/

# Check nginx configuration
sudo nginx -t

# Verify ports are listening
sudo netstat -tlnp | grep :443
sudo netstat -tlnp | grep :80

# Check index.html content
cat /usr/share/nginx/html/index.html

# Test local SSL connection
curl -Ik https://localhost/
```

## Troubleshooting

### Common Issues and Solutions

1. **SSL Certificate Issues**

   ```bash
   # Check certificate details
   openssl x509 -in /etc/nginx/ssl/nautilus.crt -text -noout
   
   # Verify certificate and key match
   openssl x509 -noout -modulus -in /etc/nginx/ssl/nautilus.crt | openssl md5
   openssl rsa -noout -modulus -in /etc/nginx/ssl/nautilus.key | openssl md5
   ```

2. **Nginx Configuration Errors**

   ```bash
   # Check nginx error logs
   sudo tail -f /var/log/nginx/error.log
   
   # Test configuration syntax
   sudo nginx -t
   ```

3. **Permission Issues**

   ```bash
   # Fix SSL file permissions
   sudo chmod 644 /etc/nginx/ssl/nautilus.crt
   sudo chmod 600 /etc/nginx/ssl/nautilus.key
   sudo chown root:root /etc/nginx/ssl/nautilus.*
   ```

4. **SELinux Issues (CentOS/RHEL)**

   ```bash
   # Check SELinux status
   sestatus
   
   # If SELinux is enforcing, set appropriate contexts
   sudo setsebool -P httpd_can_network_connect 1
   sudo restorecon -Rv /etc/nginx/ssl/
   ```

## Summary

This solution provides a complete SSL setup for Nginx on App Server 2, including:

- Nginx installation and configuration
- SSL certificate deployment
- Security headers and best practices
- HTTP to HTTPS redirection
- Welcome page creation
- Comprehensive testing procedures

The configuration ensures secure HTTPS communication while maintaining compatibility and following security best practices.
