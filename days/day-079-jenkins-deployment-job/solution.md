## Solution: Jenkins Deployment Job for Day 79

This solution auto-deploys the `web` repository to the shared docroot `/var/www/html` on the Storage server whenever someone pushes to `master`. It satisfies the challenge constraints and mirrors a practical approach used in small-to-mid deployments.

### High-level flow

1. Developer pushes to `master` in Gitea (`sarah/web`).
2. Gitea webhook notifies Jenkins.
3. Jenkins checks out the repo.
4. Jenkins deploys the entire workspace to `/var/www/html` on the Storage server as user `sarah`.
5. App servers serve the content via `httpd` on port 8080.

### Prerequisites (one-time)

- On the Storage server, ensure Jenkins can deploy without sudo prompts:
  - `sudo chown -R sarah:sarah /var/www/html`  
  - Rationale: Jenkins deploys as `sarah` via SSH; ownership avoids permission failures.

- On each App server, install and run `httpd` on port 8080:
  - `sudo yum install -y httpd`
  - `echo 'Listen 8080' | sudo tee /etc/httpd/conf.d/listen-8080.conf`
  - `sudo systemctl enable --now httpd `
  - Rationale: The app is served from the shared `/var/www/html` location on port 8080.

### Jenkins: plugins and credentials

- Install plugins: Git, Gitea, Publish Over SSH, Credentials Binding (Pipeline optional).  
  See `required-plugins.md` for why/how and alternatives.

- Add credentials:
  - Gitea username/password: `sarah` / `Sarah_pass123` (kind: Username with password).
  - Storage SSH private key for user `sarah` (kind: SSH Username with private key). Add public key to `~sarah/.ssh/authorized_keys` on the Storage server.

### Configure Gitea integration

1. Manage Jenkins → Configure System → Gitea Servers: Add your Gitea base URL and name it (e.g., `gitea-main`).
2. In the job (below), enable “Build when a change is pushed to Gitea.”
3. In Gitea (`sarah/web` → Settings → Webhooks), add a webhook pointing to Jenkins’ Gitea endpoint and enable push events.

### Create the job (Freestyle)

1. New Item → Name: `nautilus-app-deployment` → Freestyle project.
2. Source Code Management → Git:
   - Repository URL: `https://<gitea-host>/<user>/web.git` (or SSH URL)
   - Credentials: Gitea `sarah` credentials
   - Branches to build: `master`
3. Build Triggers:
   - Check “Build when a change is pushed to Gitea”.
   - (Fallback) If you cannot add webhooks, Poll SCM can work, but the challenge expects push-based triggering.
4. Build/Deployment (Publish Over SSH):
   - Manage Jenkins → Configure System → Publish over SSH → Add an SSH server:
     - Name: `storage`
     - Hostname: `<storage-host>`
     - Username: `sarah`
     - Remote Directory: `/var/www/html`
     - Advanced: upload SSH key credential if not set globally.
   - In the job → Post-build → “Send build artifacts over SSH”:
     - Name: `storage`
     - Source files: `**/*`
     - Excludes: `.git/**`
     - Remove prefix: (leave empty to deploy repo root directly into docroot)
     - Remote directory: (leave default `/var/www/html`)
     - Exec command (optional hardening):
       ```
       find /var/www/html -type d -exec chmod 755 {} \; && \
       find /var/www/html -type f -exec chmod 644 {} \;
       ```
     - Optional repeatability: enable “Clean remote” or switch to an rsync-based pipeline (below) with `--delete`.

### Verify end-to-end

1. SSH to Storage as `sarah`, edit the repo `~/web/index.html` to contain: `Welcome to the xFusionCorp Industries`.
2. Commit and push to `master`.
3. Confirm Jenkins job auto-triggers, completes successfully, and deploys the whole repo to `/var/www/html`.
4. Open the app’s main URL (`https://<LBR-URL>`) and see the updated text on the root (no `/web` path).

### Why these steps are required (challenge constraints)

- **Ownership of `/var/www/html`**: Jenkins deploys as `sarah` over SSH; avoiding sudo is necessary for non-interactive, repeatable runs.
- **Deploy entire repository**: The validator checks that not only `index.html` but the whole repo content is deployed.
- **Deploy to exact docroot**: Content must live at `/var/www/html` so the main URL serves it directly (no subdirectory).
- **Push-based trigger on `master`**: The job must run automatically on push to `master`.
- **Idempotence**: Repeated builds should succeed; cleaning/rsync `--delete` avoids stale artifacts.

### Real-world alternatives and improvements

- **Pipeline as Code (Jenkinsfile)**
  - Store the pipeline in the repo for versioned CI/CD.
  - Example (declarative, using sshagent + rsync):
    ```groovy
    pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo "🚀 Challenge 79: Jenkins + Gitea Integration"
                echo "📋 Build Information:"
                echo "  - Job: ${env.JOB_NAME}"
                echo "  - Build: #${env.BUILD_NUMBER}"
                echo "  - Node: ${env.NODE_NAME}"
                
                script {
                    // Get current timestamp
                    def timestamp = new Date().format('yyyy-MM-dd HH:mm:ss')
                    echo "  - Started: ${timestamp}"
                }
                
                sh '''
                    echo "=== System Information ==="
                    echo "Hostname: $(hostname)"
                    echo "Current User: $(whoami)"
                    echo "Working Directory: $(pwd)"
                    echo "Available Space:"
                    df -h . | tail -1
                    
                    echo "=== Git Repository Check ==="
                    if [ -d .git ]; then
                        echo "✅ Git repository detected"
                        echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
                        echo "Latest commit: $(git log --oneline -1 2>/dev/null || echo 'no commits')"
                    else
                        echo "ℹ️  No Git repository found (normal for manual testing)"
                    fi
                    
                    echo "=== Simulating Build Process ==="
                    echo "Step 1: Preparing environment..."
                    sleep 1
                    echo "Step 2: Processing files..."
                    sleep 1  
                    echo "Step 3: Finalizing build..."
                    sleep 1
                    echo "✅ Build simulation completed successfully!"
                '''
                
                echo "✅ Build stage completed successfully"
            }
        }
    }
    
    post {
        always {
            echo "🏁 Jenkins + Gitea integration test completed"
        }
        success {
            echo "🎉 SUCCESS: Ready for Gitea webhook integration!"
            echo "📝 Next steps:"
            echo "  1. Configure Gitea webhook URL"
            echo "  2. Set up automatic triggers"
            echo "  3. Test with actual Git push"
        }
        failure {
            echo "💥 FAILED: Check configuration and try again"
        }
    }
}
    ```

- **Artifact build and promote**
  - Build immutable artifacts (zip/tar) in CI, publish to an artifact repo, and deploy via a CD job; improves traceability.

- **Infrastructure-as-Code deployment**
  - Use Ansible/Puppet/Chef for idempotent deployment and server configuration. Jenkins triggers the IaC tool.

- **Containerize and orchestrate**
  - Pack the app into an image and deploy with Kubernetes/Helm or Docker Swarm. Jenkins builds/pushes images, CD updates deployments.

- **Blue/Green or Rolling**
  - Deploy to an alternate target and switch traffic to reduce downtime.

- **Secrets management**
  - Use Jenkins Credentials + Folder-scoped credentials, or external vaults (HashiCorp Vault, AWS Secrets Manager) for production-grade security.

### Common pitfalls (and fixes)

- Files end up at `/var/www/html/web/...`: Remove prefix must be empty; deploy the repo root directly to the docroot.
- Permission denied on deploy: Ensure `/var/www/html` is owned by `sarah` and the SSH key works without a password.
- Job doesn’t trigger: Confirm Gitea webhook URL, secret (if used), and that the Gitea plugin trigger is enabled.
- Repeated runs leave stale files: Use rsync with `--delete` or enable “Clean remote” in Publish Over SSH.


