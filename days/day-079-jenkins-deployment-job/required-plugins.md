## Required Jenkins plugins for Day 79 (and why)

This challenge needs Jenkins to pull from Gitea and deploy to a remote Storage server on each push to `master`. The following plugins cover SCM integration, triggering, secure credentials, and remote deployment.

- **Git plugin**
  - **Why**: Clone the `web` repository from Gitea into the Jenkins workspace.
  - **How it’s used**: Configure in the job under Source Code Management → Git. Set repo URL, credentials, and branch `master`.

- **Gitea plugin** (recommended)
  - **Why**: Native integration for webhooks and Gitea servers. Supports “Build when a change is pushed to Gitea.”
  - **How it’s used**: Manage Jenkins → Configure System → Gitea Servers. In the job, enable the Gitea trigger. In Gitea, add a webhook to Jenkins.
  - **Alternative**: If not installed, use the **Generic Webhook Trigger** plugin or fallback to Poll SCM (less reliable for validation).

- **Publish Over SSH** (simplest deployment)
  - **Why**: Copy the entire workspace (excluding `.git`) to `/var/www/html` on the Storage server, then run remote commands.
  - **How it’s used**: Manage Jenkins → Configure System → Publish over SSH: define Storage server host, user `sarah`, SSH key, and default remote directory `/var/www/html`. In the job, add “Send build artifacts over SSH.”
  - **Alternative**: Use Pipeline `sshagent` with `scp`/`rsync`, or use the **SSH Agent** plugin for key provisioning and a shell step for deployment.

- **Credentials Binding** (baseline)
  - **Why**: Store Gitea credentials and SSH private keys securely for non-interactive use in jobs.
  - **How it’s used**: Manage Jenkins → Credentials. Reference by `credentialsId` in SCM and SSH steps.

- **Pipeline** (optional but common)
  - **Why**: Enables `Jenkinsfile` pipelines. Useful if you prefer declarative/scripted pipelines over Freestyle.
  - **How it’s used**: Define the checkout and deploy stages, use `sshagent` and `rsync` for idempotent deployment.

### Nice-to-have (hardening/real-world)

- **Matrix Authorization Strategy**: Granular UI permissions.
- **Folders**: Organize jobs and folder-level credentials.
- **AnsiColor**: Readable console logs.
- **Pipeline Utility Steps**: Utility functions in pipelines.

### Why these are sufficient for the challenge

- Git + Gitea plugin ensures push-triggered builds on `master`.
- Publish Over SSH ensures entire repo is deployed directly into `/var/www/html` (no extra `/web` subdirectory).
- Credentials plugins ensure non-interactive, repeatable runs.
- Pipeline is optional; Freestyle + Publish Over SSH fully satisfies requirements.


