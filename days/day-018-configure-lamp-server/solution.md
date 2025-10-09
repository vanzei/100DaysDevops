# Day 018: Configure LAMP Server - Complete Solution Guide

## Overview
This challenge involves setting up a complete LAMP stack (Linux, Apache, MySQL/MariaDB, PHP) across multiple servers to host a WordPress website.

## Architecture Understanding
- **App Servers**: Will run Apache + PHP (web tier)
- **DB Server**: Will run MariaDB (database tier)  
- **Load Balancer**: Will distribute traffic to app servers
- **Shared Storage**: `/var/www/html` is shared across app servers

## Required Steps and Explanations

### Step A: Install LAMP Components on App Servers

**What to install:**
```bash
# On each app server (stapp01, stapp02, stapp03)
sudo yum update -y
sudo yum install -y httpd php php-mysqlnd php-cli php-common php-curl php-mbstring php-gd php-xml
```

**Alternative package names (try if php-mysqlnd doesn't work):**
```bash
# For RHEL/CentOS 7/8
sudo yum install -y httpd php php-mysqlnd php-cli php-common php-curl php-mbstring php-gd php-xml

# For older systems or different repos
sudo yum install -y httpd php php-mysqli php-cli php-common php-curl php-mbstring php-gd php-xml

# For Ubuntu/Debian systems
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php php-mysql php-cli php-curl php-mbstring php-gd php-xml
```

**Why these components:**
- **httpd**: Apache web server to serve web pages
- **php**: PHP interpreter for dynamic content
- **php-mysql**: PHP extension to connect to MySQL/MariaDB
- **php-cli**: PHP command line interface
- **php-common**: Common PHP files and functions
- **php-curl**: For HTTP requests (WordPress needs this)
- **php-mbstring**: Multibyte string handling (WordPress requirement)
- **php-gd**: Image processing library (for WordPress media)
- **php-xml**: XML processing (WordPress requirement)

### Step B: Configure Apache Port 5000

**Why port 5000:**
- Custom port requirement (not default 80)
- Allows multiple services on same servers
- Security through obscurity

**Configuration steps:**
```bash
# Edit Apache main configuration
sudo vi /etc/httpd/conf/httpd.conf

# Change Listen directive from 80 to 5000
Listen 5000

# Update virtual host configuration
<VirtualHost *:5000>
    DocumentRoot /var/www/html
    ServerName localhost
</VirtualHost>
```

**Why this configuration:**
- `Listen 5000`: Tells Apache to listen on port 5000
- `VirtualHost *:5000`: Configures virtual host for the custom port
- `DocumentRoot /var/www/html`: Points to shared storage directory

### Step C: Install MariaDB on DB Server

**Installation commands:**
```bash
# On DB server
sudo yum update -y
sudo yum install -y mariadb-server mariadb
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
```

**Why MariaDB:**
- Drop-in replacement for MySQL
- Better performance and features
- WordPress fully compatible
- Open source and widely supported

**Security configuration:**
- Remove anonymous users (security)
- Disable remote root login (security)
- Remove test database (security)
- Set root password (authentication)

### Step D: Create Database and User

**Database creation:**
```bash
sudo mysql -u root -p
```

```sql
-- Create the database
CREATE DATABASE kodekloud_db10;

-- Create the user with password
CREATE USER 'kodekloud_top'@'%' IDENTIFIED BY 'BruCStnMT5';

-- Grant all privileges on the specific database
GRANT ALL PRIVILEGES ON kodekloud_db10.* TO 'kodekloud_top'@'%';

-- Apply the changes
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

**Why these specific settings:**
- **`kodekloud_db10`**: Specific database name as required
- **`kodekloud_top`**: Database user for the application
- **`@'%'`**: Allows connections from any host (app servers)
- **`ALL PRIVILEGES`**: Full database operations (SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, etc.)
- **`FLUSH PRIVILEGES`**: Applies permission changes immediately

### Step E: Configure Database Connectivity

**MariaDB configuration for remote access:**
```bash
# Edit MariaDB configuration
sudo vi /etc/my.cnf

# Add or modify these lines
[mysqld]
bind-address = 0.0.0.0
```

**Firewall configuration:**
```bash
# Allow MySQL port through firewall
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

## Complete Implementation Steps

### On App Servers (stapp01, stapp02, stapp03):

```bash
# 1. Install packages
sudo yum update -y
sudo yum install -y httpd php php-mysqlnd php-cli php-common php-curl php-mbstring php-gd php-xml

# 2. Configure Apache port
sudo sed -i 's/Listen 80/Listen 5000/' /etc/httpd/conf/httpd.conf

# 3. Configure virtual host
sudo tee /etc/httpd/conf.d/custom.conf > /dev/null <<EOF
<VirtualHost *:5000>
    DocumentRoot /var/www/html
    ServerName localhost
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# 4. Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# 5. Configure firewall
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# 6. Create PHP test file (optional)
sudo tee /var/www/html/info.php > /dev/null <<EOF
<?php
phpinfo();
?>
EOF
```

### On DB Server:

```bash
# 1. Install MariaDB
sudo yum update -y
sudo yum install -y mariadb-server mariadb
sudo systemctl start mariadb
sudo systemctl enable mariadb

# 2. Secure installation
sudo mysql_secure_installation
# Follow prompts: set root password, remove anonymous users, etc.

# 3. Configure for remote access
sudo tee -a /etc/my.cnf > /dev/null <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF

# 4. Restart MariaDB
sudo systemctl restart mariadb

# 5. Create database and user
# First, try without password (common in fresh installations)
sudo mysql -u root <<EOF
CREATE DATABASE kodekloud_db10;
CREATE USER 'kodekloud_top'@'%' IDENTIFIED BY 'BruCStnMT5';
GRANT ALL PRIVILEGES ON kodekloud_db10.* TO 'kodekloud_top'@'%';
FLUSH PRIVILEGES;
EOF

# If the above fails because root has a password, use:
# sudo mysql -u root -p <<EOF
# CREATE DATABASE kodekloud_db10;
# CREATE USER 'kodekloud_top'@'%' IDENTIFIED BY 'BruCStnMT5';
# GRANT ALL PRIVILEGES ON kodekloud_db10.* TO 'kodekloud_top'@'%';
# FLUSH PRIVILEGES;
# EOF

# 6. Configure firewall
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

## Testing and Verification

### Test Apache on App Servers:
```bash
# Check Apache status
sudo systemctl status httpd

# Test port 5000
curl -I http://localhost:5000/

# Check if PHP is working
curl http://localhost:5000/info.php
```

### Test Database Connectivity:
```bash
# From app server, test database connection
mysql -h <db-server-ip> -u kodekloud_top -p kodekloud_db10
# Enter password: BruCStnMT5
```

### Test Application:
```bash
# Create a PHP database test script
sudo tee /var/www/html/db_test.php > /dev/null <<EOF
<?php
\$host = '<db-server-ip>';
\$username = 'kodekloud_top';
\$password = 'BruCStnMT5';
\$database = 'kodekloud_db10';

try {
    \$pdo = new PDO("mysql:host=\$host;dbname=\$database", \$username, \$password);
    echo "App is able to connect to the database using user kodekloud_top";
} catch(PDOException \$e) {
    echo "Connection failed: " . \$e->getMessage();
}
?>
EOF
```

## Troubleshooting Common Issues

### 1. Apache not starting:
```bash
# Check configuration
sudo httpd -t

# Check logs
sudo tail -f /var/log/httpd/error_log
```

### 2. Database connection issues:
```bash
# Check MariaDB status
sudo systemctl status mariadb

# Check if port is open
sudo netstat -tlnp | grep :3306

# Test user permissions
mysql -u kodekloud_top -p -h <db-server-ip>
```

### 3. Firewall issues:
```bash
# Check firewall status
sudo firewall-cmd --list-all

# Add missing ports
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

## Why This Architecture Works

1. **Separation of Concerns**: Web servers handle HTTP requests, DB server handles data
2. **Scalability**: Multiple app servers can serve requests
3. **Shared Storage**: Common content across all app servers
4. **Load Balancing**: Traffic distributed across app servers
5. **Security**: Database isolated on separate server
6. **Flexibility**: Custom port allows for complex networking setups

This LAMP stack configuration provides a robust, scalable web application infrastructure suitable for hosting WordPress or similar PHP applications.