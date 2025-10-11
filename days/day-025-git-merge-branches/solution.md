# Day 025: Git Merge Branches - Solution

## Overview

This challenge involves creating a new branch, adding a file to it, committing the changes, and then merging the branch back into master.

## Prerequisites

- Access to Storage server in Stratos DC
- Git repository located at `/usr/src/kodekloudrepos/demo`
- Source file located at `/tmp/index.html`
- The repository should have a `master` branch

## Task Requirements

1. Create a new branch `nautilus` from `master` branch
2. Copy `/tmp/index.html` file into the repository
3. Add and commit the file in the new branch
4. Merge the `nautilus` branch back into `master` branch
5. Push changes to origin for both branches

## Solution Steps

### Step 1: Navigate to the Repository

```bash
cd /usr/src/kodekloudrepos/demo
```

### Step 2: Configure Git Identity

```bash
# Set Git user identity (required for commits)
git config --global user.email "natasha@stratos.xfusioncorp.com"
git config --global user.name "Natasha"

# Alternatively, set only for this repository (omit --global)
# git config user.email "natasha@stratos.xfusioncorp.com"
# git config user.name "Natasha"
```

### Step 3: Fix Git Ownership Issues (if needed)

```bash
# Add the repository as a safe directory if needed
git config --global --add safe.directory /usr/src/kodekloudrepos/demo

# Fix ownership if permission errors occur
sudo chown -R $(whoami):$(whoami) /usr/src/kodekloudrepos/demo
```

### Step 4: Ensure You're on Master Branch

```bash
# Switch to master branch
git checkout master

# Pull latest changes
git pull origin master
```

### Step 5: Create New Branch 'datacenter' from Master

```bash
# Create and switch to the new branch
git checkout -b datacenter
```

### Step 6: Copy the Required File

```bash
# Copy index.html from /tmp to the repository
cp /tmp/index.html .

# Verify the file was copied
ls -la index.html
```

### Step 7: Add and Commit the File

```bash
# Add the file to staging area
git add index.html

# Commit the changes
git commit -m "Add index.html file to datacenter branch"
```

### Step 8: Push the New Branch to Origin

```bash
# Push the datacenter branch to remote
git push origin datacenter
```

### Step 9: Switch Back to Master Branch

```bash
# Switch to master branch
git checkout master
```

### Step 10: Merge datacenter Branch into Master

```bash
# Merge the datacenter branch into master
git merge datacenter
```

### Step 11: Push Both Branches to Origin

```bash
# Push the updated master branch
git push origin master

# Ensure the datacenter branch is also pushed (if it failed earlier)
git push origin datacenter
```

**Note**: The task requires pushing "both branches" to origin. If the datacenter branch push failed earlier due to permissions, you'll need to retry it after the merge.

## Verification

After completing all steps, verify the following:

### Check Branch Status

```bash
# List all branches
git branch -a

# Show current branch
git branch --show-current
```

### Verify File Exists in Master

```bash
# Ensure you're on master
git checkout master

# Check if index.html exists
ls -la index.html

# View commit history
git log --oneline
```

### Verify Remote Branches

```bash
# Check remote branches
git branch -r

# Verify both branches are pushed
git ls-remote origin
```

## Expected Results

- New branch `datacenter` created from `master`
- File `index.html` copied and committed in `datacenter` branch
- `datacenter` branch merged back into `master`
- Both branches pushed to origin
- Master branch contains the `index.html` file

## Complete Command Sequence

Here's the complete sequence of commands:

```bash
cd /usr/src/kodekloudrepos/demo
git config --global user.email "natasha@stratos.xfusioncorp.com"
git config --global user.name "Natasha"
git checkout master
git pull origin master
git checkout -b datacenter
cp /tmp/index.html .
git add index.html
git commit -m "Add index.html file to datacenter branch"
git push origin datacenter
git checkout master
git merge datacenter
git push origin master
```

## Troubleshooting

### Remote Push Errors - "unable to create temporary object directory"

If you encounter the "remote unpack failed: unable to create temporary object directory" error:

1. **Check remote repository permissions:**
   ```bash
   # Check ownership of the remote repository
   ls -la /opt/demo.git/
   
   # Check internal directory permissions
   ls -la /opt/demo.git/objects/
   ls -la /opt/demo.git/refs/
   ```

2. **Fix remote repository permissions:**
   ```bash
   # Fix ownership of the bare repository (adjust path as needed)
   sudo chown -R natasha:natasha /opt/demo.git
   
   # Fix permissions to allow write access
   sudo chmod -R 775 /opt/demo.git
   
   # Specifically fix objects directory permissions
   sudo chmod -R 775 /opt/demo.git/objects/
   sudo chmod -R 775 /opt/demo.git/refs/
   ```

3. **Alternative: Fix permissions for Git user/group:**
   ```bash
   # If there's a specific git user/group
   sudo chown -R git:git /opt/blog.git
   sudo chmod -R 775 /opt/blog.git
   ```

4. **Retry the push after fixing permissions:**
   ```bash
   git push origin xfusion
   ```

### Permission Issues Workflow

If you encounter permission errors during push operations:

#### Option A: Fix permissions first, then complete workflow
1. **Fix remote repository permissions:**
   ```bash
   sudo chown -R natasha:natasha /opt/blog.git
   ```
2. **Push the xfusion branch:**
   ```bash
   git push origin xfusion
   ```
3. **Complete merge and push master:**
   ```bash
   git checkout master
   git merge xfusion
   git push origin master
   ```

#### Option B: Complete local workflow, then push everything
1. **Complete the merge locally (even if push failed):**
   ```bash
   git checkout master
   git merge xfusion
   ```
2. **Fix remote repository permissions:**
   ```bash
   sudo chown -R natasha:natasha /opt/blog.git
   ```
3. **Push both branches:**
   ```bash
   git push origin master
   git push origin xfusion
   ```

### Verification for Remote Branch Creation

To verify the branch exists on the remote repository:

```bash
# Check remote branches
git ls-remote origin

# Or check branches in the bare repository directly
git --git-dir=/opt/blog.git branch -a
```

## Notes

- **git checkout -b**: Creates a new branch and switches to it
- **git merge**: Merges the specified branch into the current branch
- The workflow follows: create branch → make changes → commit → merge → push
- Both branches (master and xfusion) will exist on the remote after completion
- The merge will be a fast-forward merge if no other changes were made to master
- Remote repository permission issues are common in shared environments and need to be resolved before pushing