# Day 21: Set Up Git Repository on Storage Server - Implementation Guide

## Overview

This challenge involves setting up a Git repository on the Storage Server for the Nautilus development team. The task requires installing Git and creating a bare repository that can be used as a central repository for team collaboration.

## Understanding Bare Repositories

**What is a Bare Repository?**

- A bare repository contains only the Git data (no working directory)
- Used as a central repository that multiple developers can push to and pull from
- Cannot be used for direct file editing (no checkout/working tree)
- Ideal for server-side repositories in team environments
- Convention: named with `.git` suffix

**Why Use Bare Repositories?**

- **Central Storage**: Acts as the authoritative source of code
- **Team Collaboration**: Multiple developers can push/pull from it
- **No Working Directory Conflicts**: Avoids issues with checked-out files
- **Server Deployment**: Standard practice for Git servers

## Implementation Plan

### Step 1: Install Git Package on Storage Server

**Command:**
```bash
# Install Git using yum package manager
sudo yum install git -y

# Verify Git installation
git --version
which git
```

**Why this step is required:**

- Git package provides all necessary tools for repository management
- Yum is the specified package manager for this environment
- Verification ensures Git is properly installed and accessible
- Required for all subsequent Git operations

### Step 2: Create the Bare Repository

**Commands:**
```bash
# Navigate to the parent directory
cd /opt

# Create the bare repository with exact name specified
sudo git init --bare demo.git

# Verify the repository was created correctly
ls -la /opt/demo.git/
sudo ls -la /opt/demo.git/
```

**Alternative method (if permissions require it):**
```bash
# Create directory first, then initialize
sudo mkdir -p /opt/demo.git
cd /opt/demo.git
sudo git init --bare .

# Or initialize with full path
sudo git init --bare /opt/demo.git
```

**Why this step is required:**

- **--bare flag**: Creates a repository without a working directory
- **Exact name**: `/opt/demo.git` as specified in requirements
- **Location**: `/opt/` is a standard directory for optional software
- **Permissions**: May require sudo for system directory access

### Step 3: Set Proper Permissions and Ownership

**Commands:**
```bash
# Check current ownership and permissions
sudo ls -la /opt/demo.git/

# Set appropriate ownership (adjust user/group as needed)
# Common options:
sudo chown -R git:git /opt/demo.git/          # If git user exists
sudo chown -R root:root /opt/demo.git/        # Root ownership
sudo chown -R developer:developer /opt/demo.git/  # Developer group

# Set appropriate permissions
sudo chmod -R 755 /opt/demo.git/              # Standard permissions
sudo chmod -R 775 /opt/demo.git/              # Group write access

# For shared access, you might need:
sudo chmod -R g+ws /opt/demo.git/             # Group sticky bit
```

**Why this step is required:**

- **Security**: Proper permissions prevent unauthorized access
- **Collaboration**: Group permissions allow team access
- **Functionality**: Git needs read/write access to repository files
- **Best Practice**: Following standard Unix permission models

### Step 4: Verify Repository Structure

**Commands:**
```bash
# Check the bare repository structure
sudo ls -la /opt/demo.git/

# Verify it's a bare repository
sudo cat /opt/demo.git/config

# Check Git recognizes it as a repository
cd /opt/demo.git
sudo git rev-parse --is-bare-repository
```

**Expected bare repository contents:**
```
branches/
config
description
HEAD
hooks/
info/
objects/
refs/
```

**Why verification is important:**

- **Structure Validation**: Ensures all Git components are present
- **Bare Repository Confirmation**: Verifies no working directory exists
- **Configuration Check**: Confirms Git settings are correct
- **Troubleshooting**: Identifies any setup issues early

### Step 5: Configure Repository (Optional but Recommended)

**Commands:**
```bash
# Set repository description
sudo sh -c 'echo "Demo repository for Nautilus development team" > /opt/demo.git/description'

# Configure repository settings (if needed)
cd /opt/demo.git
sudo git config core.sharedRepository group    # For group access
sudo git config receive.denyNonFastForwards false  # Allow force pushes if needed

# View current configuration
sudo git config --list
```

**Why configuration matters:**

- **Documentation**: Description helps identify repository purpose
- **Shared Access**: Proper sharing configuration for team use
- **Workflow Rules**: Push/pull policies for team collaboration
- **Maintenance**: Easier repository management

## Testing the Repository

### Step 6: Test Repository Functionality

**Commands:**
```bash
# Test 1: Clone the repository (creates a working copy)
cd /tmp
git clone /opt/demo.git test-clone
cd test-clone

# Test 2: Create a test file and push it
echo "# Demo Repository" > README.md
git add README.md
git commit -m "Initial commit with README"
git push origin main  # or master depending on default branch

# Test 3: Verify the push worked
cd /opt/demo.git
sudo git log --oneline

# Clean up test clone
rm -rf /tmp/test-clone
```

**Why testing is important:**

- **Functionality Verification**: Ensures repository works for push/pull operations
- **Team Readiness**: Confirms developers can use the repository
- **Issue Detection**: Identifies permission or configuration problems
- **Documentation**: Provides usage examples

## Common Git Repository Operations

### For Development Teams:

**Clone the repository:**
```bash
git clone /opt/demo.git project-name
cd project-name
```

**Initial setup for remote access:**
```bash
# If accessing remotely (SSH)
git clone user@storage-server:/opt/demo.git project-name

# Or with Git protocol (if Git daemon is running)
git clone git://storage-server/opt/demo.git project-name
```

**Push changes:**
```bash
git add .
git commit -m "Your commit message"
git push origin main
```

**Pull updates:**
```bash
git pull origin main
```

## Troubleshooting Guide

### Common Issues and Solutions:

1. **Permission Denied Errors:**
   ```bash
   # Fix: Adjust permissions and ownership
   sudo chown -R appropriate-user:appropriate-group /opt/demo.git/
   sudo chmod -R 755 /opt/demo.git/
   ```

2. **Repository Not Recognized:**
   ```bash
   # Check if it's properly initialized
   ls -la /opt/demo.git/
   # Should contain: HEAD, config, objects/, refs/, etc.
   ```

3. **Cannot Push to Repository:**
   ```bash
   # Check if it's truly bare
   sudo git rev-parse --is-bare-repository
   # Should return: true
   ```

4. **Git Command Not Found:**
   ```bash
   # Reinstall or check installation
   sudo yum install git -y
   which git
   ```

### Log Files and Diagnostics:

```bash
# Check Git configuration
sudo git config --list --show-origin

# Verify repository integrity
cd /opt/demo.git
sudo git fsck

# Check repository status
sudo git rev-parse --git-dir
sudo git rev-parse --is-bare-repository
```

## Security Considerations

1. **Access Control**: Set appropriate user/group permissions
2. **Network Security**: Configure firewalls if remote access is needed
3. **Backup Strategy**: Regular backups of the repository
4. **Audit Trail**: Git naturally provides commit history
5. **User Authentication**: Consider SSH keys for secure access

## Expected Outcomes

After successful implementation:

- ✅ Git package installed on Storage Server
- ✅ Bare repository created at `/opt/demo.git`
- ✅ Repository has proper structure and permissions
- ✅ Repository accepts push/pull operations
- ✅ Development team can clone and use the repository

## Next Steps for Development Team

1. **Clone the repository** to their local machines
2. **Set up remote tracking** for collaborative workflows
3. **Establish branching strategy** (main, develop, feature branches)
4. **Configure Git hooks** if automated processes are needed
5. **Set up backup procedures** for the central repository

## Advanced Configuration (Optional)

### Git Hooks Setup:
```bash
# Navigate to hooks directory
cd /opt/demo.git/hooks/

# Example: Pre-receive hook for validation
sudo nano pre-receive
# Add hook script content
sudo chmod +x pre-receive
```

### Git Daemon Setup (for Git protocol access):
```bash
# Install git-daemon
sudo yum install git-daemon -y

# Configure daemon
sudo systemctl enable git-daemon
sudo systemctl start git-daemon
```

This implementation provides a robust, secure, and functional Git repository setup for team collaboration following best practices for server-side Git repositories.