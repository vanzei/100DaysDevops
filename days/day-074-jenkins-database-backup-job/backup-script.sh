#!/bin/bash

# Jenkins Database Backup Script
# This script creates a database dump and copies it to the backup server

# Database configuration
DB_HOST="database-server"  # Replace with actual database server hostname/IP
DB_NAME="kodekloud_db01"
DB_USER="kodekloud_roy"
DB_PASS="asdfgdsd"

# Backup configuration
BACKUP_DATE=$(date +%F)
DUMP_FILE="db_${BACKUP_DATE}.sql"
BACKUP_SERVER="backup-server"  # Replace with actual backup server hostname/IP
BACKUP_USER="clint"
BACKUP_PATH="/home/clint/db_backups"

# Create database dump
echo "Creating database dump for ${DB_NAME}..."
mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} > ${DUMP_FILE}

# Check if dump was successful
if [ $? -eq 0 ]; then
    echo "Database dump created successfully: ${DUMP_FILE}"
    
    # Copy dump to backup server
    echo "Copying dump to backup server..."
    scp ${DUMP_FILE} ${BACKUP_USER}@${BACKUP_SERVER}:${BACKUP_PATH}/
    
    if [ $? -eq 0 ]; then
        echo "Backup successfully copied to ${BACKUP_SERVER}:${BACKUP_PATH}/${DUMP_FILE}"
        
        # Clean up local dump file (optional)
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