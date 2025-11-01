# Jenkins Database Backup Job Configuration Guide

## Prerequisites
- Jenkins server with admin access (username: admin, password: Adm!n321)
- Database server with MySQL/MariaDB running
- Backup server accessible via SSH
- SSH keys configured for passwordless access between Jenkins and backup server

## Step-by-Step Configuration

### Step 1: Access Jenkins UI
1. Click on the Jenkins button in the top bar
2. Login with credentials:
   - Username: `admin`
   - Password: `Adm!n321`

### Step 2: Create New Job
1. Click "New Item" on the Jenkins dashboard
2. Enter job name: `database-backup`
3. Select "Freestyle project"
4. Click "OK"

### Step 3: Configure General Settings
1. In the job configuration page:
   - Add description: "Automated database backup job for kodekloud_db01"
   - Check "Discard old builds" (optional, recommended)
   - Set "Max # of builds to keep" to 10

### Step 4: Configure Build Triggers
1. In the "Build Triggers" section:
   - Check "Build periodically"
   - In the Schedule field, enter: `*/10 * * * *`
   - This will run the job every 10 minutes

### Step 5: Configure Build Environment
1. If using SSH keys, check "Use secret text(s) or file(s)"
2. Add any necessary environment variables

### Step 6: Configure Build Steps
1. Click "Add build step" → "Execute shell"
2. In the command field, enter the backup script commands:

```bash
#!/bin/bash

# Database configuration
DB_HOST="stdb01"  # Use actual database server hostname
DB_NAME="kodekloud_db01"
DB_USER="kodekloud_roy"
DB_PASS="asdfgdsd"

# Backup configuration
BACKUP_DATE=$(date +%F)
DUMP_FILE="db_${BACKUP_DATE}.sql"
BACKUP_SERVER="stbkp01"  # Use actual backup server hostname
BACKUP_USER="clint"
BACKUP_PATH="/home/clint/db_backups"

# Test database connectivity first
echo "Testing database connectivity..."
mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} -e "SELECT 1;" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: Cannot connect to database server ${DB_HOST}"
    echo "Please check database server connectivity, credentials, and firewall rules"
    exit 1
fi

# Create database dump
echo "Creating database dump for ${DB_NAME}..."
mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} --single-transaction --routines --triggers ${DB_NAME} > ${DUMP_FILE} 2>&1

# Check if dump was successful
if [ $? -eq 0 ]; then
    echo "Database dump created successfully: ${DUMP_FILE}"
    
    # Copy dump to backup server
    echo "Copying dump to backup server..."
    scp ${DUMP_FILE} ${BACKUP_USER}@${BACKUP_SERVER}:${BACKUP_PATH}/
    
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

### Step 7: Configure Post-build Actions (Optional)
1. Add "Archive the artifacts" if you want to keep copies in Jenkins
2. Add "E-mail Notification" for failure alerts
3. Add build result notifications as needed

### Step 8: Save Configuration
1. Click "Save" to save the job configuration
2. The job will now appear in the Jenkins dashboard

### Step 9: Test the Job
1. Click on the job name to view details
2. Click "Build Now" to test the job manually
3. Check the console output to verify successful execution

## Important Notes

### SSH Key Setup
Before running the job, ensure SSH keys are properly configured:

**IMPORTANT**: SSH keys should be generated on the **Jenkins server** and copied TO the **Backup server**

```bash
# ON JENKINS SERVER:
# Generate SSH key pair (if not exists)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_backup

# Copy the PUBLIC key to the Backup server
ssh-copy-id -i ~/.ssh/jenkins_backup.pub clint@stbkp01

# Test the connection from Jenkins to Backup server
ssh -i ~/.ssh/jenkins_backup clint@stbkp01

# Verify you can write to the backup directory
ssh -i ~/.ssh/jenkins_backup clint@backup-server "touch /home/clint/db_backups/test.txt && rm /home/clint/db_backups/test.txt"
```

**Why this direction?**
- Jenkins job runs on Jenkins server and needs to PUSH files to Backup server
- Jenkins initiates the SCP connection to transfer backup files
- Backup server receives the files (doesn't initiate connections)

### Install MySQL Client Tools
The Jenkins server needs MySQL client tools to create database dumps:

```bash
# On Jenkins server - Install MySQL client
# For Ubuntu/Debian:
sudo apt update
sudo apt install mysql-client -y

# For CentOS/RHEL:
sudo yum install mysql -y
# OR for newer versions:
sudo dnf install mysql -y

# Verify installation
mysqldump --version
mysql --version
```

### Database Access
Ensure the Jenkins server can access the database server:
```bash
# Test database connection
mysql -h database-server -u kodekloud_roy -pasdfgdsd kodekloud_db01 -e "SHOW TABLES;"
```

### Backup Directory
Ensure the backup directory exists on the backup server:
```bash
# On backup server
sudo mkdir -p /home/clint/db_backups
sudo chown clint:clint /home/clint/db_backups
```