# Day 012: Linux Network Services - Solution

## Problem Analysis

Apache service not reachable on port 8085 from jump host.

## Step 1: Check Service Status

```bash
sudo systemctl status httpd
```

**Issue Found**: Apache service failed to start with "Address already in use" error.

## Step 2: Identify Port Conflict

```bash
sudo netstat -tlnp | grep 8085
```

**Result**: Port 8085 was being used by sendmail service (PID 449):
```
tcp        0      0 127.0.0.1:8085          0.0.0.0:*               LISTEN      449/sendmail: accep
```

## Step 3: Resolve Port Conflict

```bash
# Stop sendmail service that was using port 8085
sudo systemctl stop sendmail

# Verify port is now free
sudo netstat -tlnp | grep 8085

# Start Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Verify Apache is now using port 8085
sudo netstat -tlnp | grep 8085
```

## Step 4: Test Local Connectivity

```bash
# Test local connection (works)
curl http://localhost:8085
curl http://127.0.0.1:8085
```

## Step 5: Fix Remote Access (Firewall Issue)

Apache works locally but not remotely due to firewall blocking external access.

### Iptables Configuration (RESOLVED)

```bash
# Check current iptables rules
sudo iptables -L -n

# Add rule to allow port 8085 (COMPLETED)
sudo iptables -I INPUT -p tcp --dport 8085 -j ACCEPT

# Current iptables shows rule is in place:
# ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:8085
```

**Status**: ✅ Firewall rule added successfully

### Additional Troubleshooting (Still not reachable remotely)

Since firewall rule is in place but still not accessible remotely, check:

```bash
# 1. Verify Apache is listening on ALL interfaces (not just localhost)
sudo netstat -tlnp | grep 8085

# 2. Check Apache configuration for Listen directive
grep -r "Listen" /etc/httpd/conf/
grep -r "8085" /etc/httpd/conf/

# 3. Check if Apache is binding to 127.0.0.1 only
sudo ss -tlnp | grep 8085

# 4. Test with telnet from jump host
telnet stapp01 8085
```

### Option B: If no firewall is running

```bash
# Check if any firewall service is running
sudo systemctl status firewalld
sudo systemctl status ufw
sudo systemctl status iptables

# If none are running, the issue might be elsewhere
```

### Option C: Alternative firewall tools

```bash
# For UFW (Ubuntu/Debian style)
sudo ufw allow 8085/tcp

# For older systems with service command
sudo service iptables status
```

## Step 6: Verify Remote Access

```bash
# Test from the server itself
curl http://stapp01:8085

# Test from jump host
curl http://stapp01:8085
```

## Complete Resolution Commands

```bash
# 1. Stop conflicting service
sudo systemctl stop sendmail

# 2. Start Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# 3. Configure firewall (choose appropriate method)
# For iptables:
sudo iptables -I INPUT -p tcp --dport 8085 -j ACCEPT
# OR for ufw:
sudo ufw allow 8085/tcp

# 4. Verify everything works
sudo netstat -tlnp | grep 8085
curl http://localhost:8085
curl http://stapp01:8085
```

## Root Cause Summary

1. **Port Conflict**: Sendmail was using port 8085, preventing Apache from binding
2. **Firewall Blocking**: Even after Apache started, firewall blocked external access to port 8085
3. **Solution**: Stop sendmail, start Apache, and configure firewall to allow port 8085

## Final Verification

✅ Apache service running: `sudo systemctl status httpd`  
✅ Port 8085 bound to Apache: `sudo netstat -tlnp | grep 8085`  
✅ Local access works: `curl http://localhost:8085`  
✅ Remote access works: `curl http://stapp01:8085` from jump host  
✅ Firewall configured: Port 8085 allowed through firewall



