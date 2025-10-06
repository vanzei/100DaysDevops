# Day 014: Linux Process Troubleshooting - Solution

## Problem Analysis

Apache service unavailable on app server. Monitoring shows service issues.

## Step 1: Initial Diagnosis

```bash
# Check Apache service status
sudo systemctl status httpd

# Test connectivity to port 6100
curl -I http://stapp01:6100
# Result: Connection refused

# Check what's using port 6100
sudo netstat -tlnp | grep 6100
```

**Issue Identified**: Sendmail is using port 6100, preventing Apache from binding to it.

```
tcp        0      0 127.0.0.1:6100          0.0.0.0:*               LISTEN      654/sendmail: accep
```

## Step 2: Resolve Port Conflict

```bash
# Stop sendmail service that's using port 6100
sudo systemctl stop sendmail
sudo systemctl disable sendmail

# Verify port 6100 is now free
sudo netstat -tlnp | grep 6100
# Should return nothing
```

## Step 3: Configure Apache for Port 6100

```bash
# Check current Apache configuration
grep -n "Listen" /etc/httpd/conf/httpd.conf

# Configure Apache to listen on port 6100
sudo sed -i 's/^Listen 80$/Listen 6100/' /etc/httpd/conf/httpd.conf

# Verify the change
grep "Listen" /etc/httpd/conf/httpd.conf
```

## Step 4: Start Apache Service

```bash
# Start Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Check service status
sudo systemctl status httpd
```

## Step 5: Verification

```bash
# Verify Apache is listening on port 6100
sudo netstat -tlnp | grep 6100
# Should show httpd process

# Test local connectivity
curl -I http://localhost:6100

# Test remote connectivity
curl -I http://stapp01:6100
```
