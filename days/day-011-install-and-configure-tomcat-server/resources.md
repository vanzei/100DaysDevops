# Day 011: Install and Configure Tomcat Server - Resources

## Overview

Install and configure Apache Tomcat server on App Server 1, configure it to run on a custom port, and deploy a Java web application.

## Required Tasks & Why They're Necessary

### 1. Install Tomcat Server

**Task:** Install Apache Tomcat on App Server 1

```bash
# Install Java (prerequisite for Tomcat)
sudo dnf install java-11-openjdk java-11-openjdk-devel -y

# Install Tomcat (method varies by system)
sudo dnf install tomcat -y
# OR download and install manually
```

**Why Required:**

- **Java Runtime**: Tomcat is a Java servlet container that requires JVM
- **Application Server**: Needed to host and run Java web applications
- **Enterprise Standard**: Tomcat is industry-standard for Java web apps

### 2. Configure Tomcat Port

**Task:** Change Tomcat to run on port 5001 instead of default 8080

```bash
# Edit server.xml configuration
sudo vi /etc/tomcat/server.xml
# OR
sudo vi /opt/tomcat/conf/server.xml

# Change connector port from 8080 to 5001
<Connector port="5001" protocol="HTTP/1.1" ... />
```

**Why Required:**

- **Custom Requirements**: Application specifications demand port 5001
- **Port Conflicts**: Default port 8080 might be used by other services
- **Network Policies**: Organization may have specific port assignments
- **Security**: Custom ports can provide obscurity (though not real security)

### 3. Deploy ROOT.war Application

**Task:** Copy and deploy ROOT.war from Jump host to Tomcat server

```bash
# Copy from Jump host to App Server 1
scp /tmp/ROOT.war user@stapp01:/tmp/

# Deploy to Tomcat webapps directory
sudo cp /tmp/ROOT.war /var/lib/tomcat/webapps/
# OR
sudo cp /tmp/ROOT.war /opt/tomcat/webapps/
```

**Why Required:**

- **Application Deployment**: The web application needs to be accessible
- **ROOT Context**: Deploying as ROOT.war makes it accessible at base URL
- **Business Logic**: This contains the actual application the team developed

### 4. Start and Enable Tomcat Service

**Task:** Start Tomcat and enable it for auto-start

```bash
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo systemctl status tomcat
```

**Why Required:**

- **Service Availability**: Application must be running to serve requests
- **Persistence**: Auto-start ensures service survives server reboots
- **Reliability**: System service management provides better control

### 5. Verify Deployment

**Task:** Test that application works on base URL

```bash
curl http://stapp01:5001
```

**Why Required:**

- **Functional Testing**: Confirms the application is properly deployed
- **URL Validation**: Ensures base URL access works as specified
- **Quality Assurance**: Verifies all configuration steps worked correctly

## Detailed Technical Requirements

### Port Configuration Details

- **File Location**: `/etc/tomcat/server.xml` or `/opt/tomcat/conf/server.xml`
- **Element to Modify**: `<Connector>` tag
- **Change**: `port="8080"` → `port="5001"`

### WAR Deployment Process

1. **ROOT.war Significance**: 
   - When deployed as ROOT.war, application is accessible at server root (`/`)
   - Without ROOT prefix, would be accessible at `/ROOT/`
2. **Auto-deployment**: Tomcat automatically extracts and deploys WAR files
3. **Hot Deployment**: Can deploy without restarting Tomcat (in most cases)

### Service Management

- **Start Service**: `systemctl start tomcat`
- **Check Status**: `systemctl status tomcat`
- **View Logs**: `journalctl -u tomcat -f`
- **Restart if Needed**: `systemctl restart tomcat`

## Complete Installation Guide

### Step 1: Install Prerequisites

```bash
# Update system packages
sudo dnf update -y

# Install Java 11 (required for Tomcat)
sudo dnf install java-11-openjdk java-11-openjdk-devel -y

# Verify Java installation
java -version
javac -version
```

### Step 2: Install Tomcat

#### Method 1: Package Manager Installation

```bash
# Install Tomcat via DNF
sudo dnf install tomcat tomcat-webapps -y
```

#### Method 2: Manual Installation

```bash
# Create tomcat user
sudo useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat

# Download Tomcat (check for latest version)
cd /tmp
wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz

# Extract and move to /opt/tomcat
sudo tar xzf apache-tomcat-9.0.80.tar.gz -C /opt/tomcat --strip-components=1

# Set ownership
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh
```

### Step 3: Configure Tomcat Port

```bash
# Edit server.xml configuration file
sudo vi /etc/tomcat/server.xml
# OR for manual installation
sudo vi /opt/tomcat/conf/server.xml

# Find the Connector element and change port from 8080 to 5001
# Original:
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />

# Modified:
<Connector port="5001" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

### Step 4: Configure Firewall (if enabled)

```bash
# Check if firewall is active
sudo firewall-cmd --state

# Open port 5001
sudo firewall-cmd --permanent --add-port=5001/tcp
sudo firewall-cmd --reload

# Verify port is open
sudo firewall-cmd --list-ports
```

### Step 5: Deploy ROOT.war Application

```bash
# Copy ROOT.war from Jump host (if needed)
scp /tmp/ROOT.war user@stapp01:/tmp/

# Deploy to Tomcat webapps directory
# For package installation:
sudo cp /tmp/ROOT.war /var/lib/tomcat/webapps/

# For manual installation:
sudo cp /tmp/ROOT.war /opt/tomcat/webapps/

# Set proper ownership
sudo chown tomcat:tomcat /var/lib/tomcat/webapps/ROOT.war
# OR
sudo chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war
```

### Step 6: Start and Enable Tomcat Service

```bash
# Start Tomcat service
sudo systemctl start tomcat

# Enable auto-start on boot
sudo systemctl enable tomcat

# Check service status
sudo systemctl status tomcat

# View logs if needed
sudo journalctl -u tomcat -f
```

### Step 7: Verify Installation

```bash
# Test local connection
curl http://localhost:5001

# Test from external host
curl http://stapp01:5001

# Check if port is listening
sudo netstat -tlnp | grep 5001
# OR
sudo ss -tlnp | grep 5001
```

## Potential Challenges & Solutions

### Java Installation Issues

```bash
# Verify Java installation
java -version
javac -version

# Set JAVA_HOME if needed
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' >> ~/.bashrc

# For system-wide setting
echo 'JAVA_HOME=/usr/lib/jvm/java-11-openjdk' | sudo tee /etc/environment
```

### Permission Issues

```bash
# Fix Tomcat directory permissions
sudo chown -R tomcat:tomcat /var/lib/tomcat
sudo chown -R tomcat:tomcat /etc/tomcat
sudo chown -R tomcat:tomcat /var/log/tomcat

# For manual installation
sudo chown -R tomcat:tomcat /opt/tomcat
```

### Service Start Issues

```bash
# Check for port conflicts
sudo netstat -tlnp | grep 5001

# Check Tomcat logs for errors
sudo journalctl -u tomcat --no-pager
sudo tail -f /var/log/tomcat/catalina.out

# Restart service if configuration changed
sudo systemctl restart tomcat
```

### WAR Deployment Issues

```bash
# Check webapps directory permissions
ls -la /var/lib/tomcat/webapps/

# Manually extract WAR if auto-deployment fails
cd /var/lib/tomcat/webapps/
sudo jar -xvf ROOT.war
sudo chown -R tomcat:tomcat ROOT/
```

## Troubleshooting Commands

### Check Service Status

```bash
# Service status
sudo systemctl status tomcat

# Check if process is running
ps aux | grep tomcat

# Check listening ports
sudo netstat -tlnp | grep java
```

### View Logs

```bash
# System logs
sudo journalctl -u tomcat -f

# Tomcat logs
sudo tail -f /var/log/tomcat/catalina.out
sudo tail -f /var/log/tomcat/localhost.log
```

### Configuration Verification

```bash
# Verify server.xml syntax
sudo /usr/libexec/tomcat/server start

# Check Tomcat version
/usr/share/tomcat/bin/version.sh
```

## Success Criteria

✅ Tomcat server installed and running  
✅ Service configured to run on port 5001  
✅ ROOT.war deployed successfully  
✅ Application accessible via `curl http://stapp01:5001`  
✅ Service enabled for auto-start  
✅ No errors in Tomcat logs  

## Business Justification

This setup provides:

- **Application Hosting**: Platform for Java web application deployment
- **Scalability**: Tomcat can handle multiple concurrent users
- **Production Readiness**: Enterprise-grade application server
- **Team Requirements**: Meets development team's specifications
- **Operational Standards**: Follows standard deployment practices

The challenge simulates real-world application deployment scenarios that are common in enterprise Java development environments.