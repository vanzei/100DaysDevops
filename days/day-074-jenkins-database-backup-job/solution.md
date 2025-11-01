# Day 074: Jenkins Database Backup Job - Complete Solution

## Challenge Overview

Create a Jenkins job named `database-backup` that:
- Takes a database dump of `kodekloud_db01` database from the Database server
- Uses database credentials: user `kodekloud_roy`, password `asdfgdsd`
- Names the dump file as `db_$(date +%F).sql` format
- Copies the dump to Backup Server at `/home/clint/db_backups`
- Runs periodically every 10 minutes using cron schedule `*/10 * * * *`

## Prerequisites

Before starting, ensure you have:
- Access to Jenkins UI (admin/Adm!n321)
- Database server running MySQL/MariaDB
- Backup server accessible via SSH
- Network connectivity between Jenkins, Database, and Backup servers

## Solution Components

This solution includes the following files:
1. `backup-script.sh` - Shell script for database backup operations
2. `jenkins-job-guide.md` - Step-by-step Jenkins job configuration
3. `cron-schedule-guide.md` - Detailed cron scheduling explanation
4. `troubleshooting-guide.md` - Common issues and solutions

## Implementation Steps

### Step 1: Prepare the Environment

#### Install MySQL Client Tools on Jenkins Server
**CRITICAL**: Jenkins server needs MySQL client tools to create database dumps.

```bash
# On Jenkins server - Install MySQL client tools

# For Ubuntu/Debian systems:
sudo apt update
sudo apt install mysql-client -y

# For CentOS/RHEL 7:
sudo yum install mysql -y

# For CentOS/RHEL 8/9 or Fedora:
sudo dnf install mysql -y

# Verify installation:
mysqldump --version
mysql --version
```

#### Set up SSH Keys (if not already configured)
**IMPORTANT**: Generate SSH keys on Jenkins server, copy public key TO backup server

```bash
# ON JENKINS SERVER (where Jenkins job runs):
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_backup

# Copy PUBLIC key to backup server (target destination)
ssh-copy-id -i ~/.ssh/jenkins_backup.pub clint@backup-server

# Test connection (Jenkins -> Backup server)
ssh -i ~/.ssh/jenkins_backup clint@backup-server

# Verify write permissions to backup directory
ssh -i ~/.ssh/jenkins_backup clint@backup-server "touch /home/clint/db_backups/test.txt && rm /home/clint/db_backups/test.txt"
```

#### Create Backup Directory
```bash
# On backup server
mkdir -p /home/clint/db_backups
chmod 755 /home/clint/db_backups
chown clint:clint /home/clint/db_backups
```

#### Test Database Connection
```bash
# From Jenkins server
mysql -h database-server -u kodekloud_roy -pasdfgdsd kodekloud_db01 -e "SHOW TABLES;"
```

### Step 2: Access Jenkins and Create Job

1. **Access Jenkins UI:**
   - Click Jenkins button in top bar
   - Login with admin/Adm!n321

2. **Create New Job:**
   - Click "New Item"
   - Enter name: `database-backup`
   - Select "Freestyle project"
   - Click "OK"

### Step 3: Configure the Job

#### General Settings
- Add description: "Automated database backup for kodekloud_db01"
- Check "Discard old builds" and set max builds to 10

#### Build Triggers
- Check "Build periodically"
- Enter schedule: `*/10 * * * *`

#### Build Steps
Add "Execute shell" build step with the following script:

```bash
#!/bin/bash

# Database configuration
DB_HOST="stdb01"  # Replace with actual IP/hostname
DB_NAME="kodekloud_db01"
DB_USER="kodekloud_roy"
DB_PASS="asdfgdsd"

# Backup configuration
BACKUP_DATE=$(date +%F)
DUMP_FILE="db_${BACKUP_DATE}.sql"
BACKUP_SERVER="stbkp01"  # Replace with actual IP/hostname
BACKUP_USER="clint"
BACKUP_PATH="/home/clint/db_backups"

# Create database dump
echo "Creating database dump for ${DB_NAME}..."

ssh -i '~/.ssh/jenkins_db' 'peter@'${DB_HOST} "mysqldump -u ${DB_USER} -p${DB_PASS} ${DB_NAME}" > ${DUMP_FILE}
# mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} > ${DUMP_FILE}

# Check if dump was successful
if [ $? -eq 0 ]; then
    echo "Database dump created successfully: ${DUMP_FILE}"
    
    # Copy dump to backup server
    echo "Copying dump to backup server..."
    scp -i '~/.ssh/jenkins_backup' ${DUMP_FILE} ${BACKUP_USER}@${BACKUP_SERVER}:${BACKUP_PATH}/
    
    if [ $? -eq 0 ]; then
        echo "Backup successfully copied to ${BACKUP_SERVER}:${BACKUP_PATH}/${DUMP_FILE}"
        
        # Clean up local dump file
        rm ${DUMP_FILE}
        echo "Local dump file cleaned up"
    else
        echo "Error: Failed to copy backup to server"
        exit 1
    fi
else
    echo "Error: Database dump failed"
    exit 1
fi

echo "Database backup job completed successfully"
```

#### Post-build Actions (Optional but Recommended)
- Add "E-mail Notification" for failures
- Add "Archive the artifacts" if you want to keep local copies

### Step 4: Save and Test

1. Click "Save" to save the job configuration
2. Click "Build Now" to test the job manually
3. Check console output for any errors
4. Verify backup file exists on backup server

### Step 5: Monitor Scheduled Execution

1. Check the job dashboard for next scheduled run
2. Monitor build history for successful executions
3. Set up email notifications for failures

## Verification Checklist

- [ ] Jenkins job named `database-backup` created
- [ ] Job configured with correct database credentials
- [ ] Dump file uses `db_$(date +%F).sql` naming format
- [ ] Backup copied to `/home/clint/db_backups` on backup server
- [ ] Cron schedule set to `*/10 * * * *`
- [ ] Manual test run successful
- [ ] Automatic scheduled runs working
- [ ] Error notifications configured

## Important Notes

### Plugin Requirements
You may need to install these plugins:
- SSH Build Agents plugin
- Publish Over SSH plugin
- Timestamper plugin

### Restart Requirements
- Jenkins may need restart after plugin installation
- Use "Restart Jenkins when installation is complete and no jobs are running"
- Refresh browser if UI becomes unresponsive after restart

### Security Considerations
- Use dedicated service accounts
- Implement SSH key authentication
- Regularly rotate credentials
- Monitor access logs

### Performance Tips
- Schedule during off-peak hours for production
- Use compression for large databases
- Implement backup rotation policy
- Monitor disk space on backup server

## Common Issues and Solutions

### Issue: SSH Permission Denied
**Solution:** Ensure SSH keys are properly configured and the backup server allows key-based authentication.

### Issue: Database Connection Failed
**Solution:** Verify network connectivity, database server is running, and credentials are correct.

### Issue: Jenkins UI Stuck After Restart
**Solution:** Wait 2-3 minutes, then hard refresh browser (Ctrl+F5 or Cmd+Shift+R).

### Issue: Job Not Triggering Automatically
**Solution:** Verify cron expression syntax and check Jenkins system time.

## File Structure
```
day-074-jenkins-database-backup-job/
├── challenge.md                    # Original challenge description
├── solution.md                     # This comprehensive solution (current file)
├── backup-script.sh               # Standalone backup script
├── jenkins-job-guide.md          # Detailed Jenkins configuration steps
├── cron-schedule-guide.md         # Cron scheduling explanation
└── troubleshooting-guide.md       # Common issues and solutions
```

## Additional Resources

- [Jenkins Official Documentation](https://www.jenkins.io/doc/)
- [MySQL Backup and Recovery](https://dev.mysql.com/doc/mysql-backup-excerpt/8.0/en/)
- [Cron Expression Generator](https://crontab.guru/)
- [SSH Key Management Best Practices](https://www.ssh.com/academy/ssh/keygen)

## Success Criteria

The solution is successful when:
1. Jenkins job runs automatically every 10 minutes
2. Database dumps are created with correct naming format
3. Backup files are successfully transferred to backup server
4. No errors in Jenkins console output
5. Backup files are accessible on backup server at specified location

This completes the Jenkins Database Backup Job challenge for Day 074!