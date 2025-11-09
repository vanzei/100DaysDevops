# Linux Systems Administration - 100 Days DevOps Challenge

## Overview

Linux formed the foundation of the 100 Days DevOps Challenge, covering Days 1-20. This module focused on essential system administration skills, user management, security hardening, networking, and automation through shell scripting.

## What We Practiced

### User Management & Permissions
- **Non-interactive user creation** with predefined passwords
- **Temporary user accounts** with automatic expiry dates
- **SSH key-based authentication** for secure remote access
- **Sudo privileges** and permission management
- **User group management** and access controls

### Security Hardening
- **SSH configuration** (disabling root login, key-only authentication)
- **SELinux policy management** and troubleshooting
- **Firewall configuration** with iptables
- **File permissions** and ownership management
- **Script execution permissions** and security considerations

### System Services & Automation
- **Cron job scheduling** for automated tasks
- **Service management** (start/stop/restart/status)
- **Process monitoring** and troubleshooting
- **System logging** and log analysis
- **Package management** and software installation

### Networking & Services
- **Network interface configuration**
- **DNS resolution** and hostname management
- **SSL/TLS certificate** installation and configuration
- **Load balancing** with Nginx
- **Database server** setup and configuration

## Key Commands Practiced

### User Management
```bash
# Create user with home directory
useradd -m username

# Set user password
passwd username

# Create user with expiry date
useradd -m -e 2025-12-31 tempuser

# Add user to sudo group
usermod -aG sudo username

# Delete user and home directory
userdel -r username
```

### SSH Configuration
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "user@example.com"

# Copy public key to server
ssh-copy-id user@server

# SSH configuration file
sudo vi /etc/ssh/sshd_config
# Key settings:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes

# Restart SSH service
sudo systemctl restart sshd
```

### File Permissions
```bash
# Change file ownership
chown user:group filename

# Change permissions (read/write/execute)
chmod 755 script.sh
chmod u+rwx,g+rx,o+r filename

# Set script as executable
chmod +x script.sh

# Check permissions
ls -la filename
```

### Process Management
```bash
# List all processes
ps aux

# Kill process by PID
kill 1234
kill -9 1234  # Force kill

# Monitor processes in real-time
top
htop

# Background process management
jobs
fg %1
bg %1
```

### Cron Jobs
```bash
# Edit crontab
crontab -e

# Cron syntax: minute hour day month weekday command
# Examples:
# Run every day at 2 AM
0 2 * * * /path/to/backup.sh

# Run every Monday at 9 AM
0 9 * * 1 /path/to/weekly-report.sh

# Run every 30 minutes
*/30 * * * * /path/to/check-service.sh

# List cron jobs
crontab -l
```

### Package Management
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install package-name
sudo apt remove package-name
sudo apt search package-name

# CentOS/RHEL
sudo yum install package-name
sudo dnf install package-name  # CentOS 8+
sudo yum remove package-name
```

## Technical Topics Covered

### System Architecture
```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Space    │    │   Kernel Space  │    │   Hardware      │
│                 │    │                 │    │                 │
│ • Applications  │◄──►│ • System Calls  │◄──►│ • CPU           │
│ • Libraries     │    │ • Process Mgmt  │    │ • Memory        │
│ • Shell         │    │ • Memory Mgmt   │    │ • Storage       │
│ • Utilities     │    │ • Device Drivers│    │ • Network       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### SSH Authentication Flow
```text
Client                     Server
  │                          │
  │ 1. SSH Key Generation    │
  │ ssh-keygen               │
  │                          │
  │ 2. Public Key Copy       │
  │ ssh-copy-id user@server  │
  │ ───────────────────────► │
  │                          │
  │ 3. Authentication        │
  │ ssh user@server          │
  │ ◄──────────────────────► │
  │                          │
  │ 4. Secure Connection     │
  │ Established              │
  └──────────────────────────┘
```

### SELinux Security Context
```text
File/Process Context: user:role:type:level

Example: system_u:object_r:httpd_sys_content_t:s0

Components:
- User: system_u (system processes)
- Role: object_r (files/objects)
- Type: httpd_sys_content_t (web content)
- Level: s0 (security level)
```

## Production Environment Considerations

### Security Best Practices
- **Principle of Least Privilege**: Users should only have necessary permissions
- **Regular Security Audits**: Monitor system logs and access patterns
- **Automated Security Updates**: Use tools like unattended-upgrades
- **Network Segmentation**: Isolate sensitive systems
- **Backup Security**: Encrypt backups and test restoration

### High Availability
- **Redundant Systems**: Multiple servers for critical services
- **Load Balancing**: Distribute traffic across multiple servers
- **Automated Failover**: Scripts to detect and recover from failures
- **Monitoring**: Comprehensive system monitoring (CPU, memory, disk, network)

### Performance Optimization
- **Resource Monitoring**: Track system resource usage
- **Log Rotation**: Prevent log files from consuming all disk space
- **Service Optimization**: Tune service configurations for performance
- **Caching**: Implement caching where appropriate

### Backup & Recovery
- **Regular Backups**: Automated daily/weekly backups
- **Backup Testing**: Regularly test backup restoration
- **Offsite Storage**: Store backups in multiple locations
- **Backup Encryption**: Protect sensitive data in backups

### Compliance & Auditing
- **Access Logging**: Log all user access and privileged commands
- **Change Management**: Document all system changes
- **Security Policies**: Implement and enforce security policies
- **Regular Audits**: Periodic security and compliance audits

## Real-World Applications

### Web Server Administration
```bash
# Install and configure Nginx
sudo apt install nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# SSL certificate with Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d example.com
```

### Database Server Setup
```bash
# Install MySQL/MariaDB
sudo apt install mysql-server
sudo mysql_secure_installation

# Create database and user
mysql -u root -p
CREATE DATABASE myapp;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON myapp.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
```

### Monitoring Setup
```bash
# Install monitoring tools
sudo apt install htop iotop ncdu

# System resource monitoring
uptime
free -h
df -h
du -sh /var/log/*
```

## Troubleshooting Common Issues

### Permission Denied Errors
```bash
# Check file permissions
ls -la filename

# Check if user is in correct group
groups username

# Check SELinux context
ls -Z filename
```

### Service Startup Issues
```bash
# Check service status
sudo systemctl status servicename

# View service logs
sudo journalctl -u servicename

# Check configuration syntax
sudo nginx -t  # For nginx
sudo apachectl configtest  # For apache
```

### Network Connectivity
```bash
# Test network connectivity
ping google.com
traceroute google.com

# Check DNS resolution
nslookup google.com
dig google.com

# Check open ports
netstat -tlnp
ss -tlnp
```

## Key Takeaways

1. **Security First**: Always prioritize security in system configuration
2. **Automation**: Use scripts and cron jobs to automate repetitive tasks
3. **Monitoring**: Regular monitoring is crucial for maintaining system health
4. **Documentation**: Document all changes and configurations
5. **Backup Strategy**: Implement comprehensive backup and recovery procedures

## Next Steps

- **Advanced Security**: Learn about intrusion detection systems (IDS/IPS)
- **Container Orchestration**: Move from individual servers to containerized deployments
- **Infrastructure as Code**: Automate server provisioning with tools like Terraform
- **Monitoring Solutions**: Implement comprehensive monitoring with Prometheus/Grafana
- **Cloud Platforms**: Learn cloud-specific administration (AWS, Azure, GCP)

This Linux foundation provides the essential skills needed for all subsequent DevOps practices, from containerization to infrastructure automation.