# Jenkins Agent Installation Troubleshooting

## Your Current Issue: "Error: Unable to access jarfile agent.jar"

### Root Cause
The curl command is using a malformed URL: `https://8080-port-./jnlpJars/agent.jar`

### Immediate Fix

#### Step 1: Use Correct URL Format
Replace your command with the correct URL format:

```bash
# WRONG (what you used):
curl -sO https://8080-port-./jnlpJars/agent.jar

# CORRECT (use this instead):
curl -sO http://jenkins-server:8080/jnlpJars/agent.jar
# OR if using HTTPS:
curl -sO https://jenkins-server:8080/jnlpJars/agent.jar
```

#### Step 2: Find the Correct Jenkins URL
1. Go to Jenkins UI → "Manage Jenkins" → "Manage Nodes and Clouds"
2. Click on your node (App_server_1)
3. Copy the exact download command shown there

#### Step 3: Complete Fixed Command
```bash
# On App Server 1 (stapp01) as user tony:
cd /home/tony/jenkins

# Download agent jar (replace with your actual Jenkins server URL)
curl -sO http://your-jenkins-server:8080/jnlpJars/agent.jar

# Verify download
ls -la agent.jar

# Run agent (get the secret from Jenkins UI)
java -jar agent.jar -url http://your-jenkins-server:8080/ -secret YOUR_ACTUAL_SECRET -name "App_server_1" -webSocket -workDir "/home/tony/jenkins"
```

## Alternative Download Methods

### Method 1: Using wget
```bash
wget http://jenkins-server:8080/jnlpJars/agent.jar
```

### Method 2: Direct browser download
1. Open browser: `http://jenkins-server:8080/jnlpJars/agent.jar`
2. Save the file to the target server

### Method 3: Copy from Jenkins server
```bash
# If you have access to Jenkins server
scp jenkins-server:/var/lib/jenkins/war/WEB-INF/lib/remoting-*.jar agent.jar
```

## Getting the Correct Secret and Command

### From Jenkins UI:
1. Go to "Manage Jenkins" → "Manage Nodes and Clouds"
2. Click on the node name (e.g., "App_server_1")
3. The page will show the exact command to run, like:

```bash
curl -sO http://jenkins-server:8080/jnlpJars/agent.jar
java -jar agent.jar -url http://jenkins-server:8080/ -secret abcd1234efgh5678... -name "App_server_1" -webSocket -workDir "/home/tony/jenkins"
```

## Step-by-Step Manual Process

### 1. Create Jenkins Directory
```bash
# On stapp01 as tony
mkdir -p /home/tony/jenkins
cd /home/tony/jenkins
```

### 2. Download Agent Jar
```bash
# Use the correct Jenkins server URL (examples):
curl -sO http://jenkins:8080/jnlpJars/agent.jar
# OR
curl -sO http://10.0.1.100:8080/jnlpJars/agent.jar
# OR  
curl -sO https://jenkins.company.com:8080/jnlpJars/agent.jar
```

### 3. Verify Download
```bash
# Check file exists and has content
ls -la agent.jar
file agent.jar  # Should show "Java archive data (JAR)"
```

### 4. Test Java
```bash
# Ensure Java is available
java -version
which java
```

### 5. Run Agent
```bash
# Use the exact command from Jenkins UI
java -jar agent.jar -url http://jenkins-server:8080/ -secret YOUR_SECRET -name "App_server_1" -webSocket -workDir "/home/tony/jenkins"
```

## Common URL Formats

Based on different Jenkins setups:

```bash
# Standard Jenkins
http://jenkins-server:8080/jnlpJars/agent.jar

# Jenkins with custom port
http://jenkins-server:9090/jnlpJars/agent.jar

# Jenkins with HTTPS
https://jenkins-server:8080/jnlpJars/agent.jar

# Jenkins with domain name
http://jenkins.company.com:8080/jnlpJars/agent.jar

# Jenkins behind reverse proxy
http://company.com/jenkins/jnlpJars/agent.jar
```

## Quick Test Commands

```bash
# Test connectivity to Jenkins
curl -I http://jenkins-server:8080/

# Test agent jar URL
curl -I http://jenkins-server:8080/jnlpJars/agent.jar

# Download and verify in one command
curl -sO http://jenkins-server:8080/jnlpJars/agent.jar && ls -la agent.jar
```

## If Download Still Fails

### Check Network Connectivity
```bash
# Test basic connectivity
ping jenkins-server
telnet jenkins-server 8080

# Test HTTP access
curl -v http://jenkins-server:8080/
```

### Check Firewall Rules
```bash
# On the app server, check if port 8080 is accessible
nmap -p 8080 jenkins-server
```

### Alternative: Copy via SCP
```bash
# If you can access Jenkins server directly
scp jenkins-server:/path/to/agent.jar /home/tony/jenkins/
```

Remember to replace:
- `jenkins-server` with your actual Jenkins server hostname/IP
- `YOUR_SECRET` with the actual secret from Jenkins UI
- Verify the correct port (8080 is default)
- Use http or https as appropriate for your setup