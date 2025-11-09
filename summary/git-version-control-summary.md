# Git Version Control - 100 Days DevOps Challenge

## Overview

Git version control was covered in Days 21-34 of the challenge, focusing on distributed version control, collaboration workflows, and advanced Git operations. This module built upon basic Git concepts to cover branching strategies, merge conflicts, rebasing, and collaborative development practices.

## What We Practiced

### Repository Management
- **Git repository initialization** and cloning
- **Remote repository management** (add, remove, fetch, pull, push)
- **Forking repositories** for collaborative development
- **Repository synchronization** between local and remote

### Branching & Merging
- **Branch creation and management** (create, switch, delete)
- **Merge strategies** (fast-forward, recursive, octopus)
- **Merge conflict resolution** in various scenarios
- **Branch naming conventions** and workflow patterns

### Advanced Operations
- **Git rebase** for cleaner commit history
- **Cherry-picking** specific commits between branches
- **Git stash** for temporary work preservation
- **Hard reset** and revert operations
- **Interactive rebase** for commit history modification

### Collaboration & Code Review
- **Pull request management** and code review processes
- **Git hooks** for automation and quality checks
- **Branch protection** and access controls
- **Conflict resolution** in team environments

## Key Commands Practiced

### Repository Setup
```bash
# Initialize new repository
git init

# Clone existing repository
git clone https://github.com/user/repo.git
git clone git@github.com:user/repo.git

# Add remote repository
git remote add origin https://github.com/user/repo.git

# Verify remote configuration
git remote -v
```

### Basic Workflow
```bash
# Check repository status
git status

# Stage files for commit
git add filename.txt
git add .                    # Stage all changes
git add -A                  # Stage all changes including deletions

# Commit changes
git commit -m "Descriptive commit message"
git commit -am "Add and commit tracked files"

# Push to remote
git push origin main
git push -u origin feature-branch  # Set upstream
```

### Branching Operations
```bash
# Create and switch to new branch
git checkout -b feature/new-feature
git switch -c feature/new-feature  # Git 2.23+

# List branches
git branch                    # Local branches
git branch -a                # All branches (local + remote)
git branch -r                # Remote branches only

# Switch between branches
git checkout main
git switch main              # Git 2.23+

# Delete branch
git branch -d feature/completed  # Safe delete
git branch -D feature/abandoned  # Force delete
```

### Merging & Rebasing
```bash
# Merge branch into current branch
git merge feature/new-feature

# Rebase current branch onto main
git rebase main

# Interactive rebase (last 3 commits)
git rebase -i HEAD~3

# Abort rebase if conflicts
git rebase --abort

# Continue rebase after resolving conflicts
git rebase --continue
```

### Conflict Resolution
```bash
# Check for conflicts
git status

# View conflict markers in files
# Look for <<<<<<< HEAD, =======, >>>>>>> branch-name

# Resolve conflicts manually, then:
git add resolved-file.txt
git commit  # Complete the merge/rebase
```

### Cherry Picking & Stashing
```bash
# Cherry pick specific commit
git cherry-pick abc123

# Stash current changes
git stash push -m "Work in progress"

# List stashes
git stash list

# Apply latest stash
git stash pop
git stash apply stash@{0}

# Delete stash
git stash drop stash@{0}
```

### History & Investigation
```bash
# View commit history
git log --oneline           # Compact view
git log --graph --decorate  # Visual graph
git log --author="John"     # Filter by author

# Show specific commit
git show abc123

# Compare branches/commits
git diff main..feature
git diff HEAD~1 HEAD        # Last commit changes

# Blame (who changed what)
git blame filename.txt
```

## Technical Topics Covered

### Git Architecture
```text
Working Directory ────► Staging Area ────► Local Repository ────► Remote Repository
       │                       │                       │                       │
       │     git add           │     git commit        │     git push          │
       │                       │                       │                       │
   Untracked/Modified      Staged Changes         Committed History      Shared History
```

### Branching Models
```text
Git Flow Model:
┌─────────────┐
│   main      │ ← Production releases
└─────┬───────┘
      │
      ├─ develop ──────────────────┐
      │                           │
      ├─ feature/feature-1 ───────┼─ Merge to develop
      ├─ feature/feature-2 ───────┤
      │                           │
      ├─ release/v1.0 ────────────┼─ Merge to main & develop
      │                           │
      └─ hotfix/critical-bug ─────┘
```

### Merge vs Rebase
```text
Merge (preserves history):
A ─ B ─ C (main)
         │
         └─ D ─ E (feature)
             │
             └─ M (merge commit)

Rebase (linear history):
A ─ B ─ C ─ D ─ E (main)
                ↑
            (feature rebased)
```

### Conflict Resolution Process
```text
1. Identify conflicts: git status
2. Open conflicted files
3. Look for conflict markers:
   <<<<<<< HEAD (current branch)
   =======
   >>>>>>> feature-branch (incoming changes)
4. Edit file to resolve conflicts
5. Stage resolved files: git add <file>
6. Complete operation: git commit / git rebase --continue
```

## Production Environment Considerations

### Branching Strategy
- **Git Flow**: Separate branches for features, releases, and hotfixes
- **GitHub Flow**: Simplified model with main and feature branches
- **Trunk-Based Development**: Frequent commits to main branch
- **Branch Protection**: Require reviews, status checks, and approvals

### Code Review & Quality
- **Pull Request Templates**: Standardized review process
- **Automated Testing**: CI/CD integration for quality gates
- **Code Standards**: Linting, formatting, and style guides
- **Security Scanning**: Automated vulnerability detection

### Repository Security & Access
- **Access Controls**: Role-based permissions (read, write, admin)
- **Branch Protection Rules**: Prevent direct pushes to main
- **Required Reviews**: Minimum reviewers for critical changes
- **Status Checks**: Require CI/CD pipelines to pass

### Backup & Recovery
- **Regular Backups**: Repository backups for disaster recovery
- **Fork Management**: Control over forked repositories
- **Archive Policy**: Handling of stale branches and repositories
- **Data Retention**: Compliance requirements for code history

### Performance Optimization
- **Repository Size**: Monitor and optimize large repositories
- **Shallow Clones**: For CI/CD pipelines
- **Git LFS**: Large file storage for binary assets
- **Sparse Checkout**: Partial repository checkout

## Real-World Applications

### CI/CD Integration
```yaml
# GitHub Actions example
name: CI/CD Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run tests
      run: npm test
    - name: Build
      run: npm run build
```

### Git Hooks for Automation
```bash
#!/bin/bash
# pre-commit hook - run tests before commit

echo "Running pre-commit checks..."

# Run linting
npm run lint
if [ $? -ne 0 ]; then
  echo "Linting failed. Fix issues before committing."
  exit 1
fi

# Run tests
npm test
if [ $? -ne 0 ]; then
  echo "Tests failed. Fix issues before committing."
  exit 1
fi

echo "All checks passed!"
```

### Collaborative Workflow
```bash
# Feature development workflow
git checkout main
git pull origin main
git checkout -b feature/new-feature

# Make changes and commits
git add .
git commit -m "Implement new feature"

# Push feature branch
git push -u origin feature/new-feature

# Create pull request on GitHub/GitLab
# Code review and approval
# Merge to main
git checkout main
git pull origin main
git branch -d feature/new-feature
```

## Troubleshooting Common Issues

### Merge Conflicts
```bash
# Abort merge
git merge --abort

# Resolve conflicts manually
# Edit conflicted files
git add resolved-file.txt
git commit

# For rebase conflicts
git rebase --abort
# or
git rebase --continue
```

### Lost Commits
```bash
# Find lost commits
git reflog

# Restore lost commit
git checkout -b recovery-branch abc123

# Reset to previous state
git reset --hard HEAD~1  # Be careful!
```

### Repository Corruption
```bash
# Check repository health
git fsck

# Clone fresh copy
git clone --mirror corrupted-repo backup.git
git clone backup.git fixed-repo
```

### Large File Issues
```bash
# Remove large files from history
git filter-branch --tree-filter 'rm -rf large-file.zip' HEAD

# Use Git LFS for large files
git lfs install
git lfs track "*.zip"
git add .gitattributes
```

## Key Takeaways

1. **Branching Strategy**: Choose appropriate branching model for team size and release cadence
2. **Clean History**: Use rebase for linear history, merge for preserving context
3. **Code Review**: Mandatory reviews prevent bugs and knowledge sharing
4. **Automation**: Git hooks and CI/CD ensure quality and consistency
5. **Documentation**: Clear commit messages and PR descriptions

## Next Steps

- **GitOps**: Infrastructure as Code with Git workflows
- **Advanced Rebasing**: Complex history rewriting techniques
- **Git Internals**: Understanding Git's object model and plumbing commands
- **Distributed Teams**: Cross-organization collaboration patterns
- **Security**: Signed commits and repository security best practices

Git mastery is fundamental to modern software development, enabling collaboration, code quality, and reliable deployments across all DevOps practices.