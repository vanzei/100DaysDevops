# Day 024: Git Create Branches - Solution

## Overview

This challenge involves creating a new branch from the master branch in an existing Git repository without making any code changes.

## Prerequisites

- Access to Storage server in Stratos DC
- Git repository located at `/usr/src/kodekloudrepos/beta`
- The repository should have a `master` branch

## Task Requirements

- Create a new branch named `xfusioncorp_beta` from the `master` branch
- Do not make any changes to the code
- Work with the repository at `/usr/src/kodekloudrepos/beta`

## Solution Steps

### Step 1: Navigate to the Repository

```bash
cd /usr/src/kodekloudrepos/beta
```

### Step 2: Fix Git Ownership and Permission Issues (if encountered)

If you encounter a "dubious ownership" error, add the directory as a safe directory:

```bash
# Add the repository as a safe directory
git config --global --add safe.directory /usr/src/kodekloudrepos/beta
```

If you encounter permission denied errors for creating locks, you need to fix the repository permissions:

```bash
# Check current ownership and permissions
ls -la /usr/src/kodekloudrepos/beta/.git/

# Option 1: Change ownership to current user (if you have sudo access)
sudo chown -R $(whoami):$(whoami) /usr/src/kodekloudrepos/beta

# Option 2: Add write permissions for group/others (less secure)
sudo chmod -R 775 /usr/src/kodekloudrepos/beta

# Option 3: Change ownership to current user and group
sudo chown -R natasha:natasha /usr/src/kodekloudrepos/beta
```

### Step 3: Verify Current Branch and Status

```bash
# Check current branch
git branch

# Check repository status
git status
```

### Step 4: Ensure You're on Master Branch

```bash
# Switch to master branch if not already there
git checkout master
```

### Step 5: Pull Latest Changes (Optional)

```bash
# Ensure master branch is up to date
git pull origin master
```

### Step 6: Create New Branch from Master

```bash
# Create and switch to the new branch
git checkout -b xfusioncorp_beta

# Alternative approach - create branch without switching
# git branch xfusioncorp_beta master
```

### Step 7: Verify Branch Creation

```bash
# List all branches to confirm creation
git branch

# Check that you're on the new branch
git branch --show-current
```

### Step 8: Push New Branch to Remote (if needed)

```bash
# Push the new branch to remote repository
git push origin xfusioncorp_beta

# Set upstream tracking for the branch
git push -u origin xfusioncorp_beta
```

## Verification

After completing the steps, verify the following:

- The new branch `xfusioncorp_beta` exists
- The branch was created from `master` branch
- No code changes were made
- The branch contains the same content as master

### Verification Commands

```bash
# List all branches
git branch -a

# Show branch creation details
git log --oneline --graph --all

# Compare branches to ensure they're identical
git diff master xfusioncorp_beta
```

## Expected Output

```bash
# After creating the branch, git branch should show:
* xfusioncorp_beta
  master

# git diff should show no differences between master and xfusioncorp_beta
```

## Troubleshooting

### Permission Denied Errors

If you encounter "Permission denied" errors when creating branches:

1. **Check repository ownership:**
   ```bash
   ls -la /usr/src/kodekloudrepos/beta/.git/
   ```

2. **Fix ownership (recommended approach):**
   ```bash
   sudo chown -R natasha:natasha /usr/src/kodekloudrepos/beta
   ```

3. **Verify permissions after ownership change:**
   ```bash
   ls -la /usr/src/kodekloudrepos/beta/.git/
   ```

4. **Retry branch creation:**
   ```bash
   git checkout -b xfusioncorp_beta
   ```

### If Branch Was Partially Created

If you see a branch with a slightly different name (like `kodekloud_beta` instead of `xfusioncorp_beta`):

1. **Delete the incorrect branch:**
   ```bash
   git branch -d kodekloud_beta
   ```

2. **Create the correct branch:**
   ```bash
   git checkout -b xfusioncorp_beta
   ```

## Notes

- The `git checkout -b` command creates a new branch and switches to it in one step
- The branch `xfusioncorp_beta` will contain the exact same content as `master` branch
- No code modifications should be made as per the requirements
- The new branch serves as a separate development line for new features
- Permission issues are common in shared environments and need to be resolved before Git operations