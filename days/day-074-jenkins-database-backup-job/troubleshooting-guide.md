# Jenkins Troubleshooting Guide

## Plugin Installation Issues

### Issue: Plugin Installation Required
Some Jenkins jobs require additional plugins to function properly.

**Common plugins needed for database backup jobs:**
- SSH Build Agents plugin
- Publish Over SSH plugin
- Build Timeout plugin
- Timestamper plugin

**Solution:**
1. Go to "Manage Jenkins" → "Manage Plugins"
2. Click on "Available" tab
3. Search for required plugins
4. Check the plugins you want to install
5. Click "Install without restart" or "Download now and install after restart"

### Issue: Plugin Installation Stuck
**Symptoms:** Plugin installation appears to hang or freeze

**Solution:**
1. Wait for at least 5-10 minutes (plugins can take time)
2. If still stuck, refresh the browser page
3. Check "Installed" tab to see if plugin was actually installed
4. If not installed, try again with "Download now and install after restart"

## Jenkins Service Restart Issues

### Issue: Need to Restart Jenkins After Plugin Installation
**When this happens:**
- Installing or updating plugins
- Changing system configuration
- After certain plugin installations

**How to restart:**

#### Method 1: From Jenkins UI
1. Go to "Manage Jenkins"
2. Click "Restart Jenkins when installation is complete and no jobs are running"
3. Wait for current jobs to finish
4. Jenkins will restart automatically

#### Method 2: Safe Restart URL
1. Navigate to: `http://your-jenkins-url/safeRestart`
2. This will restart Jenkins safely after current jobs complete

#### Method 3: Command Line (if you have server access)
```bash
# For systemd systems
sudo systemctl restart jenkins

# For service-based systems
sudo service jenkins restart

# For Docker containers
docker restart jenkins-container-name
```

### Issue: Jenkins UI Stuck After Restart
**Symptoms:**
- Jenkins UI appears frozen or unresponsive
- Pages don't load properly
- Getting connection errors

**Solutions:**

#### Solution 1: Browser Refresh
1. Hard refresh the browser (Ctrl+F5 or Cmd+Shift+R)
2. Clear browser cache and cookies for the Jenkins site
3. Try in an incognito/private browsing window

#### Solution 2: Wait and Retry
1. Wait 2-3 minutes for Jenkins to fully start
2. Jenkins service may be starting but not fully ready
3. Try accessing the URL again

#### Solution 3: Check Jenkins Service Status
```bash
# Check if Jenkins is running
sudo systemctl status jenkins

# If not running, start it
sudo systemctl start jenkins

# Check Jenkins logs for errors
sudo journalctl -u jenkins -f
```

## Database Connection Issues

### Issue: mysqldump command not found
**Error message:**
```
mysqldump: command not found
```

**Root cause:** MySQL client tools are not installed on the Jenkins server.

**Solution:**
```bash
# On Jenkins server - Install MySQL client tools

# For Ubuntu/Debian systems:
sudo apt update
sudo apt install mysql-client -y

# For CentOS/RHEL 7:
sudo yum install mysql -y

# For CentOS/RHEL 8/9 or Fedora:
sudo dnf install mysql -y

# For Amazon Linux:
sudo yum install mysql -y

# Verify installation:
mysqldump --version
mysql --version
```

**Alternative approach using Docker (if MySQL client installation is restricted):**
```bash
# Use MySQL container to create dump
docker run --rm mysql:8.0 mysqldump \
  -h database-server \
  -u kodekloud_roy \
  -pasdfgdsd \
  kodekloud_db01 > db_$(date +%F).sql
```

### Issue: Database Connection Failed
**Error messages:**
- "Access denied for user"
- "Can't connect to MySQL server"
- "Connection timeout"

**Solutions:**

#### Check Database Credentials
```bash
# Test connection manually
mysql -h database-server -u kodekloud_roy -pasdfgdsd kodekloud_db01 -e "SHOW TABLES;"
```

#### Verify Network Connectivity
```bash
# Test network connectivity
ping database-server
telnet database-server 3306
```

#### Check MySQL Configuration
1. Ensure MySQL allows remote connections
2. Check bind-address in MySQL config
3. Verify firewall rules allow connection on port 3306

## SSH and File Transfer Issues

### Issue: SSH Connection Failed
**Error messages:**
- "Permission denied (publickey)"
- "Connection refused"
- "Host key verification failed"

**Solutions:**

#### Set up SSH Keys
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_backup

# Copy public key to backup server
ssh-copy-id -i ~/.ssh/jenkins_backup.pub clint@backup-server

# Test SSH connection
ssh -i ~/.ssh/jenkins_backup clint@backup-server
```

#### Configure SSH in Jenkins
1. Go to "Manage Jenkins" → "Configure System"
2. Find "SSH remote hosts" section
3. Add hostname and credentials
4. Test connection

### Issue: SCP/File Transfer Failed
**Solutions:**

#### Verify Target Directory Exists
```bash
# On backup server, create directory
mkdir -p /home/clint/db_backups
chmod 755 /home/clint/db_backups
```

#### Check File Permissions
```bash
# Ensure clint user owns the directory
sudo chown -R clint:clint /home/clint/db_backups
```

## Job Execution Issues

### Issue: Job Fails Intermittently
**Possible causes:**
- Network connectivity issues
- Database locks
- Insufficient disk space
- Resource constraints

**Solutions:**

#### Add Retry Logic
```bash
# In your backup script, add retry mechanism
for i in {1..3}; do
    if mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} > ${DUMP_FILE}; then
        echo "Backup successful on attempt $i"
        break
    else
        echo "Backup failed on attempt $i, retrying..."
        sleep 30
    fi
done
```

#### Monitor Resources
```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check running processes
ps aux | grep mysql
```

### Issue: Job Takes Too Long
**Solutions:**

#### Set Build Timeout
1. In job configuration, check "Abort the build if it's stuck"
2. Set appropriate timeout (e.g., 30 minutes)

#### Optimize Database Dump
```bash
# Use compression to reduce file size
mysqldump --single-transaction --routines --triggers \
  -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} | gzip > ${DUMP_FILE}.gz
```

## Monitoring and Alerts

### Set Up Build Notifications
1. In job configuration, go to "Post-build Actions"
2. Add "E-mail Notification"
3. Configure for build failures
4. Add team email addresses

### Enable Console Logging
1. Add timestamps to build logs
2. Install "Timestamper" plugin
3. Check "Add timestamps to the Console Output" in job configuration

### Monitor Job History
1. Regularly check build history for patterns
2. Look for recurring failures
3. Monitor execution times for performance degradation

## General Best Practices

### Backup Strategy
1. Keep multiple backup copies
2. Test backup restoration regularly
3. Monitor backup file sizes for anomalies
4. Implement backup rotation policy

### Security Considerations
1. Use dedicated service accounts
2. Implement least privilege access
3. Regularly rotate passwords and keys
4. Monitor access logs

### Performance Optimization
1. Schedule backups during low-usage periods
2. Use database-specific backup tools
3. Implement compression for large databases
4. Consider incremental backups for large datasets