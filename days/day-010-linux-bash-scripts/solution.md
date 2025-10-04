# Day 010: Linux Bash Scripts - Solution

## Prerequisites

### 1. Install zip package
```bash
sudo dnf install zip -y
```

### 2. Create backup directory (if it doesn't exist)
```bash
sudo mkdir -p /backup
sudo chmod 755 /backup
```

### 3. Create scripts directory (if it doesn't exist)
```bash
sudo mkdir -p /scripts
sudo chmod 755 /scripts
```

## Solution: Create news_backup.sh Script

### Step 1: Create the backup script

```bash
sudo vi /scripts/news_backup.sh
```

### Step 2: Script Content

```bash
#!/bin/bash

# news_backup.sh - Backup script for xFusionCorp news website
# This script creates a zip archive of the news directory and copies it to backup server

# Variables
SOURCE_DIR="/var/www/html/news"
ARCHIVE_NAME="xfusioncorp_news.zip"
LOCAL_BACKUP_DIR="/backup"
BACKUP_SERVER="backup_server_ip_or_hostname"  # Replace with actual backup server
BACKUP_DIR="/backup"
BACKUP_USER="backup_user"  # Replace with actual backup server user

# Create timestamp for logging
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Starting backup process..."

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "[$TIMESTAMP] ERROR: Source directory $SOURCE_DIR does not exist!"
    exit 1
fi

# Check if local backup directory exists
if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
    echo "[$TIMESTAMP] ERROR: Local backup directory $LOCAL_BACKUP_DIR does not exist!"
    exit 1
fi

# Change to the parent directory of the news folder
cd /var/www/html || {
    echo "[$TIMESTAMP] ERROR: Cannot change to /var/www/html directory!"
    exit 1
}

# Create zip archive
echo "[$TIMESTAMP] Creating zip archive: $ARCHIVE_NAME"
zip -r "$LOCAL_BACKUP_DIR/$ARCHIVE_NAME" news/

# Check if zip creation was successful
if [ $? -eq 0 ]; then
    echo "[$TIMESTAMP] Successfully created archive: $LOCAL_BACKUP_DIR/$ARCHIVE_NAME"
else
    echo "[$TIMESTAMP] ERROR: Failed to create zip archive!"
    exit 1
fi

# Copy archive to remote backup server
echo "[$TIMESTAMP] Copying archive to backup server..."
scp "$LOCAL_BACKUP_DIR/$ARCHIVE_NAME" "$BACKUP_USER@$BACKUP_SERVER:$BACKUP_DIR/"

# Check if copy was successful
if [ $? -eq 0 ]; then
    echo "[$TIMESTAMP] Successfully copied archive to backup server"
else
    echo "[$TIMESTAMP] ERROR: Failed to copy archive to backup server!"
    exit 1
fi

echo "[$TIMESTAMP] Backup process completed successfully!"
```

### Step 3: Make script executable

```bash
sudo chmod +x /scripts/news_backup.sh
```

### Step 4: Set proper ownership (assuming tony is the user for App Server 1)

```bash
sudo chown tony:tony /scripts/news_backup.sh
```

## SSH Key Setup (for passwordless copy)

### Step 1: Generate SSH key pair (run as the user who will execute the script)

```bash
# Switch to the appropriate user (e.g., tony)
su - tony

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### Step 2: Copy public key to backup server

```bash
# Copy the public key to backup server
ssh-copy-id $BACKUP_USER@$BACKUP_SERVER

# Or manually copy the key
cat ~/.ssh/id_rsa.pub | ssh $BACKUP_USER@$BACKUP_SERVER "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Step 3: Test SSH connection

```bash
# Test passwordless SSH connection
ssh $BACKUP_USER@$BACKUP_SERVER "echo 'SSH connection successful'"
```

## Simple Command for Creating Zip Archive Only

If you only need to create the zip archive (as requested in your question):

```bash
# Method 1: Create zip from within the source directory
cd /var/www/html
zip -r /backup/xfusioncorp_news.zip news/

# Method 2: Create zip from anywhere
zip -r /backup/xfusioncorp_news.zip /var/www/html/news/

# Method 3: Create zip with relative paths (recommended)
cd /var/www/html && zip -r /backup/xfusioncorp_news.zip news/
```

## Verification Commands

```bash
# Check if zip file was created
ls -la /backup/xfusioncorp_news.zip

# Check zip file contents
unzip -l /backup/xfusioncorp_news.zip

# Test the backup script
/scripts/news_backup.sh
```

## Script Execution

```bash
# Run the backup script
./scripts/news_backup.sh

# Or run with bash
bash /scripts/news_backup.sh
```

## Notes

1. **No sudo in script**: The script doesn't use sudo as required
2. **Passwordless copy**: SSH key setup enables passwordless scp
3. **Error handling**: Script includes proper error checking
4. **Logging**: Timestamps help track script execution
5. **Permissions**: Script can be run by the specified user (tony)

Replace the placeholder values in the variables section (BACKUP_SERVER, BACKUP_USER) with actual values for your environment.

