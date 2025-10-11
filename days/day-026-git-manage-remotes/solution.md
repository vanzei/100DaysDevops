# Day 026: Git Manage Remotes - Solution

## Overview

This challenge involves managing Git remotes, specifically adding a new remote repository, copying a file to the repo, committing changes, and pushing to the new remote.

## Prerequisites

- Access to Storage server in Stratos DC
- Git repository located at `/usr/src/kodekloudrepos/apps`
- New remote repository at `/opt/xfusioncorp_apps.git`
- Source file located at `/tmp/index.html`

## Task Requirements

1. Add a new remote called `dev_apps` pointing to `/opt/xfusioncorp_apps.git`
2. Copy `/tmp/index.html` file to the repository
3. Add and commit the file to master branch
4. Push master branch to the new remote `dev_apps`

## Solution Steps

```bash
cd /usr/src/kodekloudrepos/apps
```


```bash
# Add the new remote dev_apps pointing to /opt/xfusioncorp_apps.git
git remote add dev_apps /opt/xfusioncorp_apps.git

# Verify the remote was added
git remote -v
```



```bash
# Copy index.html from /tmp to the repository
sudo cp /tmp/index.html .

# Verify the file was copied
ls -la index.html
```

```bash
# If permission errors occur, use sudo for Git commands
sudo git add index.html
sudo git commit -m "Add index.html file to master branch"
sudo git push dev_apps master
```
