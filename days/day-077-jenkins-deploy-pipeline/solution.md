# Day 077: Jenkins Deploy Pipeline - Complete Solution

## Challenge Overview
Create a Jenkins pipeline job named `datacenter-webapp-job` to deploy code from Gitea's `web_app` repository to the Storage Server, which is mounted to all app servers' document root.

## Prerequisites (Already Completed by You)
- ✅ Jenkins slave node "Storage Server" connected with label `ststor01`
- ✅ Remote root directory: `/var/www/html`
- ✅ Gitea connected with repository `web_app`
- ✅ Repository cloned at `/var/www/html` on Storage Server

## Step-by-Step Job Creation

### Step 1: Create the Pipeline Job

1. **Access Jenkins Dashboard**
   - Login with admin/Adm!n321

2. **Create New Job**
   - Click "New Item"
   - **Item name**: `datacenter-webapp-job`
   - **Type**: Select "Pipeline" (NOT Multibranch Pipeline)
   - Click "OK"

### Step 2: Configure General Settings

1. **Description**: Add description like "Deploy web_app from Gitea to Storage Server"

2. **Build Triggers** (Optional but recommended):
   - You can set up polling or webhooks if needed
   - For testing, leave empty to trigger manually

### Step 3: Configure Pipeline Script

In the Pipeline section, select **"Pipeline script"** and enter this script:

```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    // Clean the deployment directory first
                    sh 'rm -rf /var/www/html/*'
                    
                    // Clone the latest code from Gitea
                    sh '''
                        cd /var/www/html
                        git clone http://sarah:Sarah_pass123@gitea:3000/sarah/web_app.git .
                    '''
                    
                    // Verify deployment
                    sh 'ls -la /var/www/html'
                }
            }
        }
    }
}
```

### Alternative Pipeline Script (Using Git Plugin)

If you prefer using Jenkins Git plugin:

```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    
    stages {
        stage('Deploy') {
            steps {
                // Clean workspace
                deleteDir()
                
                // Checkout code from Gitea
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'http://gitea:3000/sarah/web_app.git',
                        credentialsId: 'gitea-sarah-credentials'
                    ]]
                ])
                
                // Deploy files to document root
                sh '''
                    # Remove old files
                    rm -rf /var/www/html/*
                    
                    # Copy new files
                    cp -r * /var/www/html/
                    
                    # Set proper permissions
                    chmod -R 755 /var/www/html
                '''
                
                // Verify deployment
                sh 'ls -la /var/www/html'
            }
        }
    }
}
```

### Step 4: Configure Git Credentials (If Using Git Plugin)

If you choose the Git plugin approach:

1. **Go to Manage Jenkins → Manage Credentials**
2. **Add Credentials**:
   - **Kind**: Username with password
   - **Scope**: Global
   - **Username**: `sarah`
   - **Password**: `Sarah_pass123`
   - **ID**: `gitea-sarah-credentials`
   - **Description**: Gitea Sarah Credentials

### Step 5: Save and Test the Job

1. **Click "Save"** to save the pipeline configuration

2. **Test the Pipeline**:
   - Click "Build Now"
   - Check the console output
   - Verify the build runs on `ststor01` node
   - Ensure the "Deploy" stage executes successfully

### Step 6: Verify Deployment

1. **Check Jenkins Console Output**:
   - Should show successful execution on `ststor01` node
   - Deploy stage should complete without errors

2. **Check Storage Server**:
   ```bash
   # SSH to Storage Server and verify
   ls -la /var/www/html
   # Should show web_app files
   ```

3. **Test Web Application**:
   - Click the "App" button in the interface
   - Check that the website loads correctly
   - Ensure no subdirectory in URL (should be direct access)

## Enhanced Pipeline Script with Error Handling

Here's a more robust pipeline script:

```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    
    environment {
        GITEA_URL = 'http://gitea:3000/sarah/web_app.git'
        DEPLOY_PATH = '/var/www/html'
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    try {
                        echo "Starting deployment to Storage Server..."
                        
                        // Clean deployment directory
                        sh """
                            echo "Cleaning deployment directory..."
                            rm -rf ${DEPLOY_PATH}/*
                            rm -rf ${DEPLOY_PATH}/.[^.]*
                        """
                        
                        // Clone fresh code
                        sh """
                            echo "Cloning web_app repository..."
                            cd ${DEPLOY_PATH}
                            git clone ${GITEA_URL} temp_clone
                            mv temp_clone/* .
                            mv temp_clone/.[^.]* . 2>/dev/null || true
                            rm -rf temp_clone
                        """
                        
                        // Set permissions
                        sh """
                            echo "Setting proper permissions..."
                            find ${DEPLOY_PATH} -type f -exec chmod 644 {} \\;
                            find ${DEPLOY_PATH} -type d -exec chmod 755 {} \\;
                        """
                        
                        // Verify deployment
                        sh """
                            echo "Verifying deployment..."
                            ls -la ${DEPLOY_PATH}
                            echo "Deployment completed successfully!"
                        """
                        
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
```

## Troubleshooting Common Issues

### Issue 1: Pipeline Not Running on Correct Node
**Solution**: Verify the agent label matches your slave node label (`ststor01`)

### Issue 2: Git Clone Fails
**Solutions**:
- Check Gitea URL is accessible from Storage Server
- Verify credentials are correct
- Test manual git clone on Storage Server

### Issue 3: Permission Denied
**Solution**: Ensure Jenkins user on Storage Server has write permissions to `/var/www/html`

### Issue 4: Files Not Visible on App Servers
**Solution**: Verify `/var/www/html` is properly mounted across app servers

## Verification Checklist

- [ ] Pipeline job named `datacenter-webapp-job` created
- [ ] Job type is "Pipeline" (not Multibranch)
- [ ] Pipeline runs on `ststor01` node
- [ ] Single stage named "Deploy" (case-sensitive)
- [ ] Code deploys to `/var/www/html` on Storage Server
- [ ] Web application accessible via App button
- [ ] No subdirectory in URL (direct access to content)
- [ ] Apache serves content on port 8080

## Key Points

1. **Job Name**: Must be exactly `datacenter-webapp-job`
2. **Stage Name**: Must be exactly "Deploy" (case-sensitive)
3. **Node Label**: Must run on `ststor01`
4. **Deployment Path**: Must deploy to `/var/www/html`
5. **Content Access**: Direct URL access (no subdirectories)

This pipeline will clone the latest code from Gitea and deploy it to the Storage Server, making it available to all app servers through the shared mount point.