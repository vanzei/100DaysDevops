# Jenkins Console Output Troubleshooting Guide

## Common Issues and Solutions

### 1. Slave Node Connection Issues
- **Check if the slave node is online:**
  - Go to "Manage Jenkins" → "Manage Nodes and Clouds"
  - Verify that "Storage Server" (ststor01) is listed and online
  - If offline, check the slave agent logs

### 2. Pipeline Configuration Issues
- **Verify pipeline job configuration:**
  - Job type should be "Pipeline" (not Multibranch Pipeline)
  - Job name should be exactly "xfusion-webapp-job"
  - Pipeline script should be configured properly

### 3. Agent Label Issues
- **Ensure correct agent configuration:**
  ```groovy
  agent {
      label 'ststor01'  // This must match your slave node label
  }
  ```

### 4. Console Output Not Visible - Common Causes:

#### A. Job Not Starting
- Check if the job is queued but not running
- Verify slave node availability
- Check Jenkins system logs: "Manage Jenkins" → "System Log"

#### B. Permission Issues
- Ensure Jenkins user has proper permissions on slave node
- Check SSH connectivity to slave node
- Verify /var/www/html directory permissions

#### C. Git Repository Issues
- Ensure git repository exists at /var/www/html on Storage Server
- Check if branches (master/feature) exist in the repository
- Verify git configuration and access permissions

#### D. Browser/UI Issues
- Try refreshing the Jenkins page
- Clear browser cache
- Try accessing Jenkins in incognito/private mode
- Check if Jenkins service needs restart

### 5. Debugging Steps:

#### Step 1: Test Basic Pipeline
```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    stages {
        stage('Test') {
            steps {
                echo "Testing console output..."
                sh 'echo "Hello from slave node"'
                sh 'pwd'
                sh 'whoami'
            }
        }
    }
}
```

#### Step 2: Test Git Operations
```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    stages {
        stage('Git Test') {
            steps {
                sh 'cd /var/www/html && pwd'
                sh 'cd /var/www/html && git status'
                sh 'cd /var/www/html && git branch -a'
            }
        }
    }
}
```

#### Step 3: Check File Permissions
```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    stages {
        stage('Permission Test') {
            steps {
                sh 'ls -la /var/www/'
                sh 'ls -la /var/www/html/'
                sh 'whoami'
                sh 'id'
            }
        }
    }
}
```

### 6. Alternative Console Output Locations:
- Build History → Click on build number → Console Output
- Blue Ocean interface (if installed)
- Build logs in Jenkins workspace

### 7. Required Jenkins Plugins:
- Git plugin
- Pipeline plugin
- Pipeline: Stage View plugin
- SSH Slaves plugin (for slave node connectivity)

## Quick Checklist:
- [ ] Slave node "Storage Server" is online and labeled as "ststor01"
- [ ] Pipeline job named "xfusion-webapp-job" exists
- [ ] BRANCH string parameter is configured
- [ ] Git repository exists at /var/www/html on Storage Server
- [ ] Both master and feature branches exist in the repository
- [ ] Jenkins user has proper permissions on slave node
- [ ] Required plugins are installed and Jenkins is restarted