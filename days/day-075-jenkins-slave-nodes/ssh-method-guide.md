# Jenkins Slave Node Setup - SSH Method (Working Solution)

## Issue with Agent Download Method
The manual agent jar download is failing with 403 Forbidden because the endpoint requires authentication or is restricted. The **SSH launch method** is the correct approach for this challenge.

## Correct Setup Process

### Step 1: Create SSH Credentials in Jenkins

1. **Access Jenkins UI** → "Manage Jenkins" → "Manage Credentials"
2. Click on "(global)" domain → "Add Credentials"
3. Configure SSH credentials:
   - **Kind**: SSH Username with private key
   - **Scope**: Global
   - **ID**: `jenkins-slave-ssh`
   - **Description**: SSH key for slave nodes
   - **Username**: `jenkins` (or the user Jenkins runs as)
   - **Private Key**: Enter directly (paste your SSH private key)

### Step 2: Prepare SSH Keys on Jenkins Server

```bash
# On Jenkins server (as jenkins user or root)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_slave -N ""

# Copy public key to each app server
ssh-copy-id -i ~/.ssh/jenkins_slave.pub tony@stapp01
ssh-copy-id -i ~/.ssh/jenkins_slave.pub steve@stapp02
ssh-copy-id -i ~/.ssh/jenkins_slave.pub banner@stapp03

# Test connections
ssh -i ~/.ssh/jenkins_slave tony@stapp01 "whoami"
ssh -i ~/.ssh/jenkins_slave steve@stapp02 "whoami"
ssh -i ~/.ssh/jenkins_slave banner@stapp03 "whoami"
```

### Step 3: Create Jenkins Directories on App Servers

```bash
# App Server 1
ssh tony@stapp01 "mkdir -p /home/tony/jenkins && chmod 755 /home/tony/jenkins"

# App Server 2
ssh steve@stapp02 "mkdir -p /home/steve/jenkins && chmod 755 /home/steve/jenkins"

# App Server 3
ssh banner@stapp03 "mkdir -p /home/banner/jenkins && chmod 755 /home/banner/jenkins"
```

### Step 4: Install Java on App Servers (if needed)

```bash
# On each app server, install Java
ssh tony@stapp01 "sudo yum install java-11-openjdk -y"
ssh steve@stapp02 "sudo yum install java-11-openjdk -y"
ssh banner@stapp03 "sudo yum install java-11-openjdk -y"
```

### Step 5: Create Jenkins Slave Nodes (SSH Method)

#### App_server_1 Configuration:
1. Go to "Manage Jenkins" → "Manage Nodes and Clouds"
2. Click "New Node"
3. **Node name**: `App_server_1`
4. **Type**: Permanent Agent → OK

**Configuration:**
- **Description**: App Server 1 Slave Node
- **Number of executors**: 2
- **Remote root directory**: `/home/tony/jenkins`
- **Labels**: `stapp01`
- **Usage**: Use this node as much as possible
- **Launch method**: **Launch agents via SSH** ← This is key!
- **Host**: `stapp01`
- **Credentials**: Select the SSH credentials you created
- **Host Key Verification Strategy**: Non verifying Verification Strategy
- **Availability**: Keep this agent online as much as possible

#### App_server_2 Configuration:
- **Node name**: `App_server_2`
- **Remote root directory**: `/home/steve/jenkins`
- **Labels**: `stapp02`
- **Host**: `stapp02`
- **Launch method**: Launch agents via SSH
- (Same other settings as App_server_1)

#### App_server_3 Configuration:
- **Node name**: `App_server_3`
- **Remote root directory**: `/home/banner/jenkins`
- **Labels**: `stapp03`
- **Host**: `stapp03`
- **Launch method**: Launch agents via SSH
- (Same other settings as App_server_1)

### Step 6: Update SSH Credentials for Each Server

Since each server has different usernames, you'll need separate credentials:

#### For App_server_1 (user: tony):
- **ID**: `stapp01-ssh`
- **Username**: `tony`
- **Private Key**: Your SSH private key

#### For App_server_2 (user: steve):
- **ID**: `stapp02-ssh`
- **Username**: `steve`
- **Private Key**: Your SSH private key

#### For App_server_3 (user: banner):
- **ID**: `stapp03-ssh`
- **Username**: `banner`
- **Private Key**: Your SSH private key

### Step 7: Verify Node Status

1. Go to "Manage Jenkins" → "Manage Nodes and Clouds"
2. All nodes should show as **"Online"**
3. If any node is offline, click on it and check the log

### Step 8: Test the Setup

Create a test job:
1. New Item → Freestyle project → Name: `test-slaves`
2. **Restrict where this project can be run**: `stapp01`
3. **Build** → Execute shell:
   ```bash
   echo "Node: $(hostname)"
   echo "User: $(whoami)"
   echo "Working dir: $(pwd)"
   ```
4. Build and verify it runs on the correct slave

## Troubleshooting Tips

### If nodes show as offline:
1. Check SSH connectivity from Jenkins server
2. Verify correct username in credentials
3. Check Jenkins logs for detailed error messages
4. Ensure Java is installed on slave nodes

### SSH Key Issues:
```bash
# Verify SSH key permissions
chmod 600 ~/.ssh/jenkins_slave
chmod 644 ~/.ssh/jenkins_slave.pub

# Test manual SSH connection
ssh -i ~/.ssh/jenkins_slave tony@stapp01
```

This SSH-based method will work much better than trying to manually download and run the agent jar files!