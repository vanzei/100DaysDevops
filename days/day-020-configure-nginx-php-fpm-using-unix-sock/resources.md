# Day 20: Configure Nginx + PHP-FPM Using Unix Socket - Implementation Guide

## Overview

This challenge involves setting up a PHP web application stack using Nginx as the web server and PHP-FPM (FastCGI Process Manager) as the PHP processor on **app server 2**. The key requirement is to configure them to communicate via Unix sockets rather than TCP sockets for better performance and security.

## Architecture Understanding

**Why Unix Sockets vs TCP Sockets?**

- **Performance**: Unix sockets are faster for local communication (no network stack overhead)
- **Security**: More secure as they use filesystem permissions instead of network ports
- **Resource Usage**: Lower resource consumption compared to TCP connections
- **Production Standard**: Commonly used in production environments for PHP applications

## Implementation Plan

### Step 1: Install Nginx Web Server on App Server 2

**Command:**
```bash
sudo yum install nginx -y
# or for Ubuntu/Debian:
# sudo apt update && sudo apt install nginx -y
```

**Why this step is required:**

- Nginx will serve as the web server to handle HTTP requests on app server 2
- It will act as a reverse proxy to PHP-FPM for PHP file processing
- Installation includes all necessary modules for FastCGI communication
- Nginx is lightweight and efficient for serving static content and proxying dynamic content

### Step 2: Configure Nginx Custom Port and Document Root

**Configuration File:** `/etc/nginx/nginx.conf` or `/etc/nginx/conf.d/default.conf`

**Complete server block configuration:**
```nginx
server {
    listen       8095;
    listen       [::]:8095;
    server_name  localhost stapp03;
    root         /var/www/html;
    index        index.php index.html index.htm;

    # Handle static files
    location / {
        try_files $uri $uri/ =404;
    }

    # Handle PHP files through PHP-FPM
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php-fpm/default.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Security: Deny access to .htaccess files
    location ~ /\.ht {
        deny all;
    }
}
```


**Why this step is required:**

- **Port 8095**: Custom port as specified in requirements (avoids conflicts with standard port 80)
- **Document Root**: `/var/www/html` ensures Nginx serves files from the correct location
- **PHP Location Block**: Essential for processing PHP files through PHP-FPM
- **Unix Socket Path**: Configured to match the PHP-FPM socket location
- **FastCGI Parameters**: Required for proper PHP script execution

### Step 3: Install PHP-FPM Version 8.1

**CRITICAL: Must install PHP-FPM 8.1 specifically as required by the challenge**

**First, determine your OS version:**
```bash
# Check your OS version
cat /etc/os-release
cat /etc/redhat-release 2>/dev/null || echo "Not RHEL/CentOS"
```

**FOR CENTOS STREAM 9 (YOUR SYSTEM) - USE THESE COMMANDS:**
```bash
# Install EPEL repository
sudo dnf install epel-release -y

# Install Remi repository for CentOS Stream 9
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

# Enable PHP 8.1 module from Remi repository
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.1 -y

# Install PHP-FPM 8.1 and essential packages
sudo dnf install php-fpm php-cli php-common php-opcache -y

# Verify PHP version installed
php --version
php-fpm --version
```


**Why this step is required:**

- **PHP-FPM**: FastCGI Process Manager provides better performance than mod_php
- **Version 8.1**: Specific version requirement ensures compatibility
- **Process Management**: PHP-FPM manages PHP processes efficiently
- **Resource Control**: Better memory and CPU management compared to traditional PHP modules

### Step 4: Create PHP-FPM Socket Directory

**Commands:**
```bash
sudo mkdir -p /var/run/php-fpm
sudo chown nginx:nginx /var/run/php-fpm
# or for Ubuntu: sudo chown www-data:www-data /var/run/php-fpm
```

**Why this step is required:**

- **Directory Creation**: Parent directory must exist for socket file creation
- **Proper Ownership**: Nginx user needs access to the socket file
- **Permissions**: Correct ownership prevents communication failures
- **System Integration**: Follows standard Unix socket conventions

### Step 5: Configure PHP-FPM Pool

**Configuration File:** `/etc/php-fpm.d/www.conf` (RHEL/CentOS) or `/etc/php/8.1/fpm/pool.d/www.conf` (Ubuntu)

**Required Changes:**
```ini
[www]
user = nginx
group = nginx
; or for Ubuntu:
; user = www-data
; group = www-data

listen = /var/run/php-fpm/default.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
; or for Ubuntu:
; listen.owner = www-data
; listen.group = www-data

pm = dynamic
pm.max_children = 50
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

**Why this step is required:**

- **User/Group**: Must match Nginx user for proper file access
- **Socket Path**: Specifies the Unix socket location as required
- **Socket Permissions**: Ensures Nginx can read/write to the socket
- **Process Management**: Configures how PHP-FPM manages worker processes
- **Performance Tuning**: Optimizes resource usage based on server capacity

### Step 6: Configure PHP-FPM Main Configuration

**Configuration File:** `/etc/php-fpm.conf`

**Verify/Update Settings:**
```ini
[global]
pid = /var/run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

**Why this step is required:**

- **PID File**: Allows system service management
- **Error Logging**: Essential for troubleshooting
- **Daemon Mode**: Runs PHP-FPM as a background service
- **Global Settings**: Provides system-wide PHP-FPM configuration

### Step 7: Set Up Document Root and Permissions

**Commands:**
```bash
sudo mkdir -p /var/www/html
sudo chown -R nginx:nginx /var/www/html
# or for Ubuntu: sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

**Why this step is required:**

- **Directory Structure**: Ensures document root exists
- **Web Server Access**: Nginx must be able to read files
- **Security**: Proper permissions prevent unauthorized access
- **File Serving**: Enables Nginx to serve both static and PHP files

### Step 8: Configure SELinux (if enabled)

**Commands:**
```bash
# Check if SELinux is enabled
sestatus

# If enabled, configure policies
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_execmem 1
sudo restorecon -R /var/www/html
sudo restorecon -R /var/run/php-fpm

# Set SELinux context for socket
sudo semanage fcontext -a -t httpd_var_run_t "/var/run/php-fpm(/.*)?"
sudo restorecon -R /var/run/php-fpm
```

**Why this step is required:**

- **Security Policy**: SELinux may block Nginx-PHP-FPM communication
- **Socket Access**: Allows Nginx to access Unix socket
- **File Context**: Ensures proper SELinux labels on files
- **Network Access**: May be required for some PHP applications

### Step 9: Configure Firewall

**Commands:**
```bash
sudo firewall-cmd --permanent --add-port=8095/tcp
sudo firewall-cmd --reload

# Verify port is open
sudo firewall-cmd --list-ports
```

**Why this step is required:**

- **Port Access**: Opens custom port 8095 for external access
- **Security**: Maintains firewall protection while allowing required traffic
- **Testing**: Enables curl testing from jump host
- **Production Readiness**: Proper firewall configuration is essential

### Step 10: Start and Enable Services

**Commands:**
```bash
# Start and enable PHP-FPM
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl status php-fpm

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

**Why this step is required:**

- **Service Activation**: Makes both services operational
- **Boot Persistence**: Services will start automatically after reboot
- **Status Verification**: Confirms services are running properly
- **Dependency Order**: PHP-FPM should be started before Nginx

### Step 11: Verify Socket Communication

**Commands:**
```bash
# Check if socket file exists
ls -la /var/run/php-fpm/default.sock

# Verify socket permissions
sudo netstat -ap | grep php-fpm

# Test PHP-FPM status
sudo systemctl status php-fpm

# Check Nginx configuration syntax
sudo nginx -t
```

**Why this step is required:**

- **Socket Verification**: Confirms Unix socket is created and accessible
- **Communication Check**: Ensures PHP-FPM is listening on the socket
- **Configuration Validation**: Verifies Nginx configuration is correct
- **Troubleshooting**: Identifies issues before testing

### Step 12: Verify PHP Files Exist and Test Configuration

**First, verify the PHP files exist:**
```bash
# Check if the required PHP files exist
ls -la /var/www/html/
ls -la /var/www/html/index.php
ls -la /var/www/html/info.php

# If files don't exist, create them (though challenge says they should be pre-copied)
# Create index.php if missing
sudo tee /var/www/html/index.php > /dev/null <<EOF
<?php
echo "<h1>Welcome to the PHP Application</h1>";
echo "<p>Server: " . \$_SERVER['SERVER_NAME'] . "</p>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Current Time: " . date('Y-m-d H:i:s') . "</p>";
?>
EOF

# Create info.php if missing
sudo tee /var/www/html/info.php > /dev/null <<EOF
<?php
phpinfo();
?>
EOF

# Set proper ownership and permissions
sudo chown nginx:nginx /var/www/html/*.php
sudo chmod 644 /var/www/html/*.php
```

**Then test the configuration:**
```bash
# First, verify Nginx is running and listening on port 8095
sudo systemctl status nginx
sudo netstat -tulpn | grep :8095
sudo ss -tulpn | grep :8095

# Check Nginx configuration syntax
sudo nginx -t

# Test basic connectivity to the port
curl -I http://localhost:8095/

# Test with verbose output to see what's happening
curl -v http://localhost:8095/index.php

# Check Nginx access and error logs for clues
sudo tail -f /var/log/nginx/access.log &
sudo tail -f /var/log/nginx/error.log &

# Now test the actual endpoints
curl http://localhost:8095/index.php
curl http://localhost:8095/info.php

# Test from jump host (as specified in requirements)
curl http://stapp03:8095/index.php

# Stop the log tailing
pkill -f "tail -f /var/log/nginx"
```

**Why this step is required:**

- **File Verification**: Ensures the required PHP files exist in the document root
- **Content Creation**: Creates basic PHP files if they're missing from the setup
- **Functionality Verification**: Confirms PHP files are processed correctly
- **End-to-End Testing**: Validates the entire stack works as expected
- **Requirement Compliance**: Meets the specified testing criteria
- **Production Readiness**: Ensures the setup is ready for application deployment

## Troubleshooting Guide

### Common Issues and Solutions:

1. **Wrong PHP Version Installed (e.g., PHP 8.0 instead of 8.1):**
   - **Cause**: Default system PHP or wrong repository version installed
   - **Current Status**: You have PHP 8.0.30, but need PHP 8.1
   - **Solution (Standard Method)**: 
     ```bash
     # Stop current PHP-FPM service
     sudo systemctl stop php-fpm
     
     # Remove existing PHP packages
     sudo yum remove php-fpm php-cli php-common php-opcache -y
     
     # Ensure correct repository and module are enabled
     sudo yum module reset php -y
     sudo yum module enable php:remi-8.1 -y
     
     # Install PHP 8.1 specifically
     sudo yum install php-fpm php-cli php-common php-opcache -y
     
     # Verify correct version
     php --version
     php-fpm --version
     ```
   
   - **If Standard Method Fails (Version Still Wrong)**:
     ```bash
     # Check what modules are available and enabled
     sudo yum module list php
     
     # Force disable all PHP modules first
     sudo yum module disable php -y
     
     # Clean yum cache
     sudo yum clean all
     
     # Remove ALL PHP-related packages more aggressively
     sudo yum remove php* -y
     
     # Reinstall EPEL and Remi repositories
     sudo yum install epel-release -y
     sudo yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
     
     # Enable PHP 8.1 module specifically
     sudo yum module enable php:remi-8.1 -y
     
     # Install PHP 8.1 packages
     sudo yum install php81-php-fpm php81-php-cli php81-php-common php81-php-opcache -y
     
     # Create symlinks if needed (for RHEL/CentOS systems)
     sudo ln -sf /opt/remi/php81/root/usr/bin/php /usr/bin/php
     sudo ln -sf /opt/remi/php81/root/usr/sbin/php-fpm /usr/sbin/php-fpm
     
     # Verify version again
     php --version
     /opt/remi/php81/root/usr/sbin/php-fpm --version
     
     # Start the PHP 8.1 FPM service specifically
     sudo systemctl enable php81-php-fpm
     sudo systemctl start php81-php-fpm
     sudo systemctl status php81-php-fpm
     ```
   
   - **Alternative: Direct RPM Installation**:
     ```bash
     # If modules still don't work, install directly from Remi
     sudo yum install php81-php-fpm php81-php-cli php81-php-common -y
     
     # The service name will be php81-php-fpm instead of php-fpm
     sudo systemctl enable php81-php-fpm
     sudo systemctl start php81-php-fpm
     
     # Update your PHP-FPM pool config at:
     # /etc/opt/remi/php81/php-fpm.d/www.conf
     ```

2. **404 Not Found Error (curl returns "not found"):**
   - **Cause A**: PHP files don't exist in `/var/www/html/`
   - **Cause B**: Nginx not listening on port 8095 or configuration issues
   - **Solution**: 
     ```bash
     # Check if files exist
     ls -la /var/www/html/index.php /var/www/html/info.php
     
     # If files exist but still get 404, check Nginx status and port
     sudo systemctl status nginx
     sudo netstat -tulpn | grep :8095
     
     # Verify Nginx configuration
     sudo nginx -t
     grep -r "listen.*8095" /etc/nginx/
     grep -r "root.*var/www/html" /etc/nginx/
     
     # Check if default Nginx config is interfering
     sudo nginx -T | grep -A 10 -B 5 "listen\|server_name\|root"
     
     # Restart Nginx if configuration looks correct
     sudo systemctl restart nginx
     ```

2. **502 Bad Gateway Error:**
   - Check PHP-FPM service status: `sudo systemctl status php-fpm`
   - Verify socket file exists and has correct permissions
   - Check Nginx error logs: `sudo tail -f /var/log/nginx/error.log`

3. **Permission Denied on Socket:**
   - Verify socket ownership and permissions
   - Ensure Nginx and PHP-FPM users match
   - Check SELinux policies if enabled

4. **PHP Files Download Instead of Execute:**
   - Verify PHP location block in Nginx configuration
   - Check FastCGI parameters are correctly set
   - Ensure PHP-FPM is running and socket is accessible

5. **Service Won't Start:**
   - Check configuration syntax: `sudo nginx -t` and `sudo php-fpm -t`
   - Review service logs: `sudo journalctl -u nginx` or `sudo journalctl -u php-fpm`
   - Verify all directories exist with proper permissions

### Log Files to Monitor:

- Nginx Access: `/var/log/nginx/access.log`
- Nginx Error: `/var/log/nginx/error.log`
- PHP-FPM Error: `/var/log/php-fpm/error.log`
- System Journal: `journalctl -u nginx` and `journalctl -u php-fpm`

## Expected Outcomes

After successful implementation:

- ✅ Nginx running on port 8095
- ✅ PHP-FPM 8.1 installed and configured
- ✅ Unix socket communication established at `/var/run/php-fpm/default.sock`
- ✅ Document root set to `/var/www/html`
- ✅ PHP files execute properly (not download)
- ✅ `curl http://stapp03:8095/index.php` returns PHP output
- ✅ Services start automatically on boot

## Security Best Practices

1. **File Permissions**: Minimal required permissions (755 for directories, 644 for files)
2. **User Isolation**: Separate users for different services where possible
3. **Socket Security**: Unix sockets more secure than TCP for local communication
4. **Firewall Configuration**: Only required ports open
5. **Regular Updates**: Keep PHP and Nginx updated for security patches

## Performance Considerations

1. **Process Management**: Tune PHP-FPM pool settings based on server resources
2. **Socket vs TCP**: Unix sockets provide better performance for local communication
3. **Caching**: Consider implementing PHP OPcache for better performance
4. **Resource Limits**: Monitor and adjust PHP memory limits as needed

This implementation provides a robust, secure, and performant PHP web application stack using modern best practices.