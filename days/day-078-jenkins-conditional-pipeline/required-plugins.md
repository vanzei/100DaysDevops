# Required Jenkins Plugins for Conditional Pipeline Challenge

## Essential Core Plugins (Must Have)

### 1. **Pipeline Plugins**
- **Pipeline** (workflow-aggregator) - Core pipeline functionality
- **Pipeline: Groovy** (workflow-cps) - Groovy script execution
- **Pipeline: Job** (workflow-job) - Pipeline job type
- **Pipeline: API** (workflow-api) - Pipeline API support
- **Pipeline: Step API** (workflow-step-api) - Step execution
- **Pipeline: SCM Step** (workflow-scm-step) - SCM operations
- **Pipeline: Basic Steps** (workflow-basic-steps) - Basic pipeline steps

### 2. **Git Integration**
- **Git** - Git repository support
- **Git client** - Git client functionality
- **GitHub** (optional, but recommended)

### 3. **Node/Agent Management**
- **SSH Build Agents** (ssh-slaves) - SSH slave connectivity
- **Node and Label parameter** - Node selection in pipelines

### 4. **Script Security**
- **Script Security** - Groovy script approval and security

## Additional Recommended Plugins

### 5. **Pipeline Visualization**
- **Pipeline: Stage View** - Visual pipeline stages
- **Blue Ocean** (optional) - Modern UI for pipelines
- **Pipeline Graph Analysis** - Pipeline visualization

### 6. **Build Management**
- **Build Timeout** - Timeout configuration
- **Timestamper** - Timestamps in console output
- **AnsiColor** - Colored console output

### 7. **Parameter Handling**
- **Extended Choice Parameter** - Advanced parameter options
- **Active Choices** - Dynamic parameter choices

## How to Install Plugins

### Method 1: Through Jenkins UI
1. Go to **"Manage Jenkins"** → **"Manage Plugins"**
2. Click **"Available"** tab
3. Search for each plugin name
4. Check the box next to each plugin
5. Click **"Install without restart"** or **"Download now and install after restart"**
6. **Important**: Click **"Restart Jenkins when installation is complete and no jobs are running"**

### Method 2: Plugin Installation Commands
If you have CLI access, you can install plugins via command line:
```bash
# Install essential plugins
jenkins-plugin-cli --plugins workflow-aggregator git ssh-slaves script-security workflow-basic-steps
```

## Plugin Verification Checklist

After installing plugins, verify they're working:

- [ ] **Pipeline plugin installed** - Can create Pipeline jobs
- [ ] **Git plugin installed** - Can access Git repositories
- [ ] **SSH Slaves plugin installed** - Can connect to slave nodes
- [ ] **Script Security plugin installed** - Can execute Groovy scripts
- [ ] **Groovy Sandbox enabled** - Scripts can run in sandbox mode

## Most Likely Missing Plugin for Your Issue

Based on your symptoms (minimal console output), you're most likely missing:

1. **Pipeline: Basic Steps** - This provides `echo`, `sh`, and other basic commands
2. **Workflow: CPS** - This handles Groovy script execution
3. **Script Security** - This might be blocking script execution

## Quick Plugin Check

To check what plugins you currently have installed:
1. Go to **"Manage Jenkins"** → **"Manage Plugins"**
2. Click **"Installed"** tab
3. Search for: "pipeline", "workflow", "git", "ssh"

## Restart Requirements

**CRITICAL**: After installing pipeline-related plugins, you **MUST restart Jenkins**:
1. Install plugins
2. Check **"Restart Jenkins when installation is complete and no jobs are running"**
3. Wait for Jenkins to restart
4. Verify plugins are active in the "Installed" tab

## Common Plugin Issues

### Issue 1: Groovy Sandbox Problems
- **Solution**: Install **Script Security** plugin and approve scripts

### Issue 2: SSH Slave Connection
- **Solution**: Install **SSH Build Agents** plugin

### Issue 3: Git Operations Failing
- **Solution**: Install **Git** and **Git client** plugins

### Issue 4: Pipeline Steps Not Working
- **Solution**: Install **Pipeline: Basic Steps** and **Workflow: CPS**

## After Plugin Installation

Once you install the required plugins and restart Jenkins, try this test pipeline:

```groovy
pipeline {
    agent any
    stages {
        stage('Plugin Test') {
            steps {
                echo "Testing plugin functionality..."
                sh 'echo "Shell commands working"'
                sh 'date'
                script {
                    def message = "Groovy scripts working"
                    echo message
                }
            }
        }
    }
}
```

If this shows proper console output with all the echo statements and shell command results, then the plugins are working correctly.