# Day 19: Install and Configure Web Application - Implementation Plan

## Overview
This challenge involves setting up Apache HTTP server on app server 2 to host two static websites (blog and apps) with custom port configuration and directory aliases. This is a common real-world scenario for hosting multiple applications on a single server.

## Implementation Plan

### Step 1: Install Apache HTTP Server Package
**Command:** `sudo yum install httpd -y` (RHEL/CentOS) or `sudo apt install apache2 -y` (Ubuntu/Debian)

**Why this step is required:**
- Apache (httpd) is the web server software that will serve our static websites
- Installing with dependencies ensures all required libraries and modules are available
- The `-y` flag automatically confirms installation prompts for automation
- This establishes the foundation for hosting web content

### Step 2: Configure Apache to Listen on Port 3002
**Configuration:** Modify `/etc/httpd/conf/httpd.conf` (RHEL/CentOS) or `/etc/apache2/ports.conf` (Ubuntu)

**Why this step is required:**
- Default Apache port is 80, but the requirement specifies port 3002
- Custom ports are often used in enterprise environments to avoid conflicts with other services
- Port configuration must be changed before starting the service to prevent binding errors
- Security consideration: Non-standard ports can provide some obscurity from automated attacks

**Configuration changes needed:**
```apache
Listen 3002
```

### Step 3: Create Virtual Host Configuration
**Configuration:** Create/modify virtual host configuration file

**Why this step is required:**
- Virtual hosts allow multiple websites to be served from the same Apache instance
- Alias directives map URL paths to filesystem directories
- This enables the URLs `/blog/` and `/apps/` to serve content from different directories
- Proper virtual host configuration ensures requests are routed correctly

**Configuration example:**
```apache
<VirtualHost *:3002>
    DocumentRoot /var/www/html
    
    Alias /blog/ /var/www/html/blog/
    <Directory "/var/www/html/blog/">
        AllowOverride None
        Require all granted
    </Directory>
    
    Alias /apps/ /var/www/html/apps/
    <Directory "/var/www/html/apps/">
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
```

### Step 4: Transfer Website Content from Jump Host
**Commands:**
```bash
# Copy from jump_host to app server 2
scp -r /home/thor/blog user@appserver2:/tmp/
scp -r /home/thor/apps user@appserver2:/tmp/
```

**Why this step is required:**
- The website content currently exists on the jump host but needs to be on the app server
- SCP (Secure Copy Protocol) provides secure file transfer between servers
- Recursive copy (-r) ensures all subdirectories and files are transferred
- Using /tmp as intermediate location allows for proper permissions setup

### Step 5: Set Up Website Directories
**Commands:**
```bash
sudo mkdir -p /var/www/html/blog
sudo mkdir -p /var/www/html/apps
sudo cp -r /tmp/blog/* /var/www/html/blog/
sudo cp -r /tmp/apps/* /var/www/html/apps/
```

**Why this step is required:**
- Apache's default document root is `/var/www/html/`
- Creating subdirectories maintains the URL structure requirement
- Copying content to proper locations ensures Apache can serve the files
- Using sudo ensures proper ownership and permissions for web server access

### Step 6: Set Proper File Permissions and Ownership
**Commands:**
```bash
sudo chown -R apache:apache /var/www/html/blog/ /var/www/html/apps/
sudo chmod -R 755 /var/www/html/blog/ /var/www/html/apps/
```

**Why this step is required:**
- Apache process runs under the 'apache' user (or 'www-data' on Ubuntu)
- Proper ownership ensures Apache can read the files
- 755 permissions allow owner (apache) full access, others read/execute
- Security best practice: Web files should not be world-writable
- Prevents "403 Forbidden" errors when accessing the websites

### Step 7: Configure SELinux (if enabled)
**Commands:**
```bash
sudo setsebool -P httpd_can_network_connect 1
sudo restorecon -R /var/www/html/
```

**Why this step is required:**
- SELinux (Security-Enhanced Linux) may be enabled and blocking Apache
- Setting the boolean allows Apache to make network connections
- Restoring context ensures files have proper SELinux labels
- Without this, Apache may fail to serve content even with correct permissions

### Step 8: Configure Firewall
**Commands:**
```bash
sudo firewall-cmd --permanent --add-port=3002/tcp
sudo firewall-cmd --reload
```

**Why this step is required:**
- Firewall may be blocking the custom port 3002
- Adding the port to firewall rules allows external access
- Permanent flag ensures the rule persists after reboot
- Reload applies the new rules immediately

### Step 9: Start and Enable Apache Service
**Commands:**
```bash
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd
```

**Why this step is required:**
- Starting the service makes Apache begin serving web content
- Enabling ensures Apache starts automatically after system reboot
- Status check confirms the service is running properly
- Service management is crucial for maintaining availability

### Step 10: Validate Configuration
**Commands:**
```bash
curl http://localhost:3002/blog/
curl http://localhost:3002/apps/
sudo netstat -tulpn | grep :3002
```

**Why this step is required:**
- Testing ensures the configuration works as expected
- Curl tests verify both websites are accessible via their respective URLs
- Network status check confirms Apache is listening on the correct port
- Validation prevents issues in production and confirms requirements are met

## Troubleshooting Tips

### Common Issues and Solutions:

1. **Port already in use:**
   - Check what's using the port: `sudo netstat -tulpn | grep :3002`
   - Kill the process or choose a different port

2. **Permission denied errors:**
   - Verify file ownership and permissions
   - Check SELinux context and booleans

3. **404 Not Found errors:**
   - Verify Alias directives in virtual host configuration
   - Ensure files exist in the specified directories

4. **Service won't start:**
   - Check configuration syntax: `sudo httpd -t` or `sudo apache2ctl configtest`
   - Review error logs: `sudo journalctl -u httpd` or `/var/log/apache2/error.log`

## Expected Outcomes

After successful implementation:
- Apache HTTP server running on port 3002
- Blog website accessible at `http://localhost:3002/blog/`
- Apps website accessible at `http://localhost:3002/apps/`
- Both curl commands return website content
- Service configured to start automatically on boot

## Security Considerations

- File permissions set to minimum required levels
- Apache running under dedicated user account
- Custom port provides some security through obscurity
- SELinux properly configured if enabled
- Firewall rules restrict access to only required port

This implementation follows best practices for web server configuration while meeting all specified requirements.
