#!/bin/bash
set -e
echo "=== Apache Log Copy using Password Authentication ==="
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Define passwords (adjust if different)
APP_PASS="BigGr33n"
STORAGE_PASS="Bl@kW"

TEMP_DIR="/tmp/jenkins_logs_$TIMESTAMP"
mkdir -p $TEMP_DIR

echo "Copying logs from App Server 3..."
sshpass -p "$APP_PASS" scp -o StrictHostKeyChecking=no banner@stapp03.stratos.xfusioncorp.com:/var/log/httpd/access_log $TEMP_DIR/access_log_$TIMESTAMP
sshpass -p "$APP_PASS" scp -o StrictHostKeyChecking=no banner@stapp03.stratos.xfusioncorp.com:/var/log/httpd/error_log $TEMP_DIR/error_log_$TIMESTAMP

echo "Preparing Storage Server destination..."
sshpass -p "$STORAGE_PASS" ssh -o StrictHostKeyChecking=no natasha@ststor01.stratos.xfusioncorp.com "echo '$STORAGE_PASS' | sudo -S mkdir -p /usr/src/devops && echo '$STORAGE_PASS' | sudo -S chown natasha:natasha /usr/src/devops"


echo "Copying logs to Storage Server..."
sshpass -p "$STORAGE_PASS" scp -o StrictHostKeyChecking=no $TEMP_DIR/access_log_$TIMESTAMP natasha@ststor01.stratos.xfusioncorp.com:/usr/src/devops/
sshpass -p "$STORAGE_PASS" scp -o StrictHostKeyChecking=no $TEMP_DIR/error_log_$TIMESTAMP natasha@ststor01.stratos.xfusioncorp.com:/usr/src/devops/

rm -rf $TEMP_DIR

echo "✅ Success! Files copied with timestamp: $TIMESTAMP"