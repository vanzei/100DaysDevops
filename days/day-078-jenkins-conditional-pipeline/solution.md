# Day 078: Jenkins Conditional Pipeline - Complete Solution

## Challenge Summary
Create a Jenkins pipeline job that conditionally deploys code from a Git repository based on branch parameter (master or feature).

## Prerequisites Setup

### 1. Slave Node Configuration
- **Node Name**: Storage Server
- **Label**: ststor01
- **Remote Root Directory**: /var/www/html
- **Launch Method**: SSH (ensure SSH connectivity is working)

### 2. Git Repository Setup
- Repository should be cloned at `/var/www/html` on Storage Server
- Both `master` and `feature` branches should exist
- Jenkins user should have proper permissions

## Pipeline Job Configuration

### 1. Create Pipeline Job
1. Go to Jenkins Dashboard
2. Click "New Item"
3. Enter name: `xfusion-webapp-job`
4. Select "Pipeline" (NOT Multibranch Pipeline)
5. Click "OK"

### 2. Configure Job Parameters
In the job configuration:
1. Check "This project is parameterized"
2. Add "String Parameter":
   - **Name**: BRANCH
   - **Default Value**: master
   - **Description**: Branch to deploy (master or feature)

### 3. Pipeline Script
Use the following pipeline script:

```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    
    parameters {
        string(name: 'BRANCH', defaultValue: 'master', description: 'Branch to deploy (master or feature)')
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    // Clean the workspace first
                    sh 'rm -rf *'
                    
                    // Conditional deployment based on BRANCH parameter
                    if (params.BRANCH == 'master') {
                        echo "Deploying master branch..."
                        sh '''
                            cd /var/www/html
                            git fetch origin
                            git checkout master
                            git pull origin master
                            echo "Successfully deployed master branch"
                        '''
                    } else if (params.BRANCH == 'feature') {
                        echo "Deploying feature branch..."
                        sh '''
                            cd /var/www/html
                            git fetch origin
                            git checkout feature
                            git pull origin feature
                            echo "Successfully deployed feature branch"
                        '''
                    } else {
                        error "Invalid branch parameter. Please use 'master' or 'feature'"
                    }
                    
                    // List deployed files for verification
                    sh '''
                        echo "Deployed files:"
                        ls -la /var/www/html/
                        echo "Current branch:"
                        cd /var/www/html && git branch --show-current
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo "Deployment completed successfully for branch: ${params.BRANCH}"
        }
        failure {
            echo "Deployment failed for branch: ${params.BRANCH}"
        }
        always {
            echo "Pipeline execution finished"
        }
    }
}
```

## Console Output Troubleshooting

### If you can't see console output, try these steps:

1. **Check Build Status**
   - Go to Build History
   - Click on the build number
   - Click "Console Output"

2. **Verify Slave Node Connection**
   - Go to "Manage Jenkins" → "Manage Nodes and Clouds"
   - Ensure "Storage Server" is online and labeled as "ststor01"

3. **Test Basic Connectivity**
   Create a simple test job with this pipeline:
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
                   sh 'pwd && whoami'
               }
           }
       }
   }
   ```

4. **Common Issues and Solutions**
   - **Job stuck in queue**: Check if slave node is available
   - **Permission denied**: Ensure Jenkins user has SSH access to slave node
   - **Git errors**: Verify repository exists and has correct branches
   - **No console output**: Try refreshing browser or checking system logs

## Testing the Pipeline

### Test Master Branch Deployment
1. Go to pipeline job
2. Click "Build with Parameters"
3. Set BRANCH parameter to "master"
4. Click "Build"
5. Check console output for successful deployment

### Test Feature Branch Deployment
1. Click "Build with Parameters"
2. Set BRANCH parameter to "feature"
3. Click "Build"
4. Check console output for successful deployment

## Verification Steps

1. **Check Deployment**
   - Pipeline should complete successfully
   - Console output should show branch switching and file listing
   - App servers should serve content from the deployed branch

2. **Access Application**
   - Click the "App" button to verify deployment
   - Content should load from the correct branch
   - URL should be clean (no sub-directories)

## Required Jenkins Plugins
- Git plugin
- Pipeline plugin
- Pipeline: Stage View plugin
- SSH Slaves plugin

## Troubleshooting Tips

1. **If pipeline fails to start**:
   - Check slave node connectivity
   - Verify label configuration
   - Check Jenkins system logs

2. **If git operations fail**:
   - Ensure repository exists at /var/www/html
   - Check file permissions
   - Verify branches exist

3. **If console output is empty**:
   - Try running the test pipeline first
   - Check browser developer tools for errors
   - Restart Jenkins if necessary

4. **If deployment doesn't reflect on app servers**:
   - Verify /var/www/html is properly mounted
   - Check Apache configuration
   - Ensure proper file permissions

## Success Criteria
- ✅ Pipeline job named "xfusion-webapp-job" created
- ✅ BRANCH string parameter configured
- ✅ Single "Deploy" stage implemented
- ✅ Conditional logic for master/feature branches working
- ✅ Console output visible and informative
- ✅ Application accessible via App button
- ✅ Clean URL without sub-directories