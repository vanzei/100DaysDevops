# Day 075: Jenkins Slave Nodes - Complete Solution

## Challenge Overview
Set up Jenkins slave nodes for all three app servers (stapp01, stapp02, stapp03) with specific configurations:
- Node names: App_server_1, App_server_2, App_server_3
- Labels: stapp01, stapp02, stapp03 respectively
- Remote directories: /home/tony/jenkins, /home/steve/jenkins, /home/banner/jenkins

## Prerequisites
- Jenkins server with admin access (admin/Adm!n321)
- SSH access to all app servers
- SSH key authentication configured

## Step-by-Step Solution

### Step 1: Access Jenkins UI
1. Click Jenkins button in top bar
2. Login with admin/Adm!n321

### Step 2: Install Required Plugins
1. Go to "Manage Jenkins" → "Manage Plugins"
2. Install these plugins if not already installed:
   - SSH Build Agents plugin
   - SSH Slaves plugin
3. Restart Jenkins if required

### Step 3: Configure SSH Keys (if needed)
On Jenkins server, ensure SSH keys are set up for connecting to app servers:

```bash
# Generate SSH key if not exists
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_slave

# Copy public key to each app server
ssh-copy-id -i ~/.ssh/jenkins_slave.pub tony@stapp01
ssh-copy-id -i ~/.ssh/jenkins_slave.pub steve@stapp02  
ssh-copy-id -i ~/.ssh/jenkins_slave.pub banner@stapp03

# Test connections
ssh -i ~/.ssh/jenkins_slave tony@stapp01
ssh -i ~/.ssh/jenkins_slave steve@stapp02
ssh -i ~/.ssh/jenkins_slave banner@stapp03
```

### Step 4: Create Remote Directories on App Servers

#### On App Server 1 (stapp01):
```bash
ssh -i ~/.ssh/jenkins_slave tony@stapp01
mkdir -p /home/tony/jenkins
chmod 755 /home/tony/jenkins
exit
```

#### On App Server 2 (stapp02):
```bash
ssh -i ~/.ssh/jenkins_slave steve@stapp02
mkdir -p /home/steve/jenkins
chmod 755 /home/steve/jenkins
exit
```

#### On App Server 3 (stapp03):
```bash
ssh -i ~/.ssh/jenkins_slave banner@stapp03
mkdir -p /home/banner/jenkins
chmod 755 /home/banner/jenkins
exit
```

### Step 5: Add Slave Nodes in Jenkins UI

#### For App_server_1:
1. Go to "Manage Jenkins" → "Manage Nodes and Clouds"
2. Click "New Node"
3. Configure:
   - **Node name**: `App_server_1`
   - **Type**: Select "Permanent Agent"
   - Click "OK"

4. Node Configuration:
   - **Description**: App Server 1 Slave Node
   - **Number of executors**: 2
   - **Remote root directory**: `/home/tony/jenkins`
   - **Labels**: `stapp01`
   - **Usage**: Use this node as much as possible
   - **Launch method**: Launch agents via SSH
   - **Host**: `stapp01`
   - **Credentials**: Add SSH credentials (private key)
   - **Host Key Verification Strategy**: Non verifying Verification Strategy

5. Click "Save"

#### For App_server_2:
1. Click "New Node"
2. Configure:
   - **Node name**: `App_server_2`
   - **Type**: Permanent Agent
3. Node Configuration:
   - **Description**: App Server 2 Slave Node
   - **Number of executors**: 2
   - **Remote root directory**: `/home/steve/jenkins`
   - **Labels**: `stapp02`
   - **Launch method**: Launch agents via SSH
   - **Host**: `stapp02`
   - **Credentials**: SSH credentials
4. Click "Save"

#### For App_server_3:
1. Click "New Node"  
2. Configure:
   - **Node name**: `App_server_3`
   - **Type**: Permanent Agent
3. Node Configuration:
   - **Description**: App Server 3 Slave Node
   - **Number of executors**: 2
   - **Remote root directory**: `/home/banner/jenkins`
   - **Labels**: `stapp03`
   - **Launch method**: Launch agents via SSH
   - **Host**: `stapp03`
   - **Credentials**: SSH credentials
4. Click "Save"

### Step 6: Fix the Agent Download Issue

The error you encountered is due to a malformed URL. Here's the correct way to download and run the agent:

#### Method 1: Download from Jenkins UI (Recommended)
1. Go to "Manage Jenkins" → "Manage Nodes and Clouds"
2. Click on the node (e.g., App_server_1)
3. You'll see the correct download command, something like:

```bash
# The correct URL should be (replace YOUR_JENKINS_URL):
curl -sO http://YOUR_JENKINS_URL:8080/jnlpJars/agent.jar

# Then run:
java -jar agent.jar -url http://YOUR_JENKINS_URL:8080/ -secret YOUR_SECRET -name "App_server_1" -webSocket -workDir "/home/tony/jenkins"
```

#### Method 2: Manual Agent Installation (Alternative)
If the Jenkins UI method doesn't work, you can manually install the agent:

```bash
# On each app server, create the jenkins directory and download agent
mkdir -p /home/tony/jenkins  # Change path for each server
cd /home/tony/jenkins

# Download the agent jar from Jenkins
wget http://jenkins-server:8080/jnlpJars/agent.jar

# Or use curl with correct URL
curl -O http://jenkins-server:8080/jnlpJars/agent.jar

# Verify download
ls -la agent.jar
```

### Step 7: Configure SSH Credentials in Jenkins

1. Go to "Manage Jenkins" → "Manage Credentials"
2. Click on "(global)" domain
3. Click "Add Credentials"
4. Configure:
   - **Kind**: SSH Username with private key
   - **Scope**: Global
   - **ID**: jenkins-slave-ssh
   - **Description**: SSH key for slave nodes
   - **Username**: (varies by server - tony, steve, banner)
   - **Private Key**: Enter directly (paste your private key)
5. Click "OK"

### Step 8: Verify Node Status

1. Go to "Manage Jenkins" → "Manage Nodes and Clouds"
2. Check that all nodes show as "Online"
3. If any node is offline, click on it and check the log for errors

### Step 9: Test the Slave Nodes

Create a simple test job to verify nodes are working:

1. Create a new "Freestyle project"
2. In "Restrict where this project can be run", enter label: `stapp01`
3. Add build step "Execute shell":
   ```bash
   echo "Running on node: $(hostname)"
   whoami
   pwd
   ```
4. Build the job and verify it runs on the correct slave node

## Troubleshooting Common Issues

### Issue: Agent jar download fails
**Solution:** Ensure you're using the correct Jenkins URL format:
```bash
# Correct format:
curl -sO http://jenkins-server:8080/jnlpJars/agent.jar

# NOT:
curl -sO https://8080-port-./jnlpJars/agent.jar
```

### Issue: SSH Connection Failed
**Solutions:**
1. Verify SSH key authentication works manually
2. Check firewall rules allow SSH (port 22)
3. Ensure correct username for each server
4. Verify SSH key permissions (600 for private key)

### Issue: Permission Denied on Remote Directory
**Solution:**
```bash
# On each app server, ensure correct ownership
sudo chown tony:tony /home/tony/jenkins      # App server 1
sudo chown steve:steve /home/steve/jenkins   # App server 2  
sudo chown banner:banner /home/banner/jenkins # App server 3
```

### Issue: Java Not Found on Slave Node
**Solution:** Install Java on the app servers:
```bash
# On each app server
sudo yum install java-11-openjdk -y
# or
sudo apt install openjdk-11-jdk -y
```

## Verification Checklist

- [ ] All three slave nodes (App_server_1, App_server_2, App_server_3) are created
- [ ] Each node has correct labels (stapp01, stapp02, stapp03)
- [ ] Remote directories are correctly configured
- [ ] All nodes show "Online" status
- [ ] SSH credentials are properly configured
- [ ] Test job can run on each slave node
- [ ] Agent jar files are successfully downloaded and working

## Important Notes

1. **Plugin Requirements**: SSH Build Agents plugin is essential
2. **Restart Jenkins**: May be required after plugin installation
3. **SSH Key Authentication**: Preferred over password authentication
4. **Network Connectivity**: Ensure Jenkins can reach all app servers
5. **Java Installation**: Required on all slave nodes
6. **Firewall Rules**: SSH (port 22) must be open between Jenkins and slaves

This completes the Jenkins slave nodes setup for all three app servers.