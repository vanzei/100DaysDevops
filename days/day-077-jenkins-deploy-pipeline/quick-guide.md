# Quick Job Creation Guide for Challenge 77

Since you've already connected the slave node and Gitea, here's exactly how to create the pipeline job:

## Step 1: Create the Pipeline Job

1. **Jenkins Dashboard** → **"New Item"**
2. **Item name**: `datacenter-webapp-job`
3. **Select**: "Pipeline" (NOT Multibranch Pipeline)
4. **Click**: "OK"

## Step 2: Configure the Pipeline

In the job configuration page:

### Pipeline Section:
- **Definition**: Pipeline script
- **Script**: Copy and paste this pipeline:

```groovy
pipeline {
    agent {
        label 'ststor01'
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    // Clean the deployment directory
                    sh 'rm -rf /var/www/html/* /var/www/html/.[^.]*'
                    
                    // Clone the repository
                    sh '''
                        cd /var/www/html
                        git clone http://sarah:Sarah_pass123@gitea:3000/sarah/web_app.git temp
                        mv temp/* . 2>/dev/null || true
                        mv temp/.[^.]* . 2>/dev/null || true
                        rm -rf temp
                    '''
                    
                    // Set permissions
                    sh 'chmod -R 755 /var/www/html'
                    
                    // Verify
                    sh 'ls -la /var/www/html'
                }
            }
        }
    }
}
```

## Step 3: Save and Test

1. **Click "Save"**
2. **Click "Build Now"**
3. **Check Console Output** - should run on `ststor01` node
4. **Verify** - Click "App" button to see the deployed website

## Key Points:
- Job name: `datacenter-webapp-job` (exact spelling)
- Stage name: `Deploy` (exact spelling, case-sensitive)
- Runs on: `ststor01` node (your slave node label)
- Deploys to: `/var/www/html` (shared with app servers)

That's it! The pipeline will clone the web_app repository content directly into `/var/www/html` without creating a subdirectory, so the content is accessible directly via the main URL.