# Git Stash Resources

## 🎯 What is Git Stash?

**Git stash** is a powerful feature that temporarily saves your uncommitted changes (both staged and unstaged) so you can work on something else, and then come back and re-apply them later. Think of it as a **temporary clipboard** for your work-in-progress.

### Key Characteristics:
- **Temporary storage** - Not part of permanent commit history
- **Local only** - Stashes are not pushed to remote repositories
- **Stack-based** - Multiple stashes stored in a stack (LIFO - Last In, First Out)
- **Quick save** - Faster than creating temporary commits

---

## 🤔 When to Use Git Stash

### **Real-World Scenarios:**

#### 1. **🚨 Emergency Context Switching**
```
Situation: Working on Feature A, urgent bug needs fixing
Solution: Stash → Fix bug → Commit → Push → Restore stash
```

#### 2. **🔄 Branch Switching with Dirty Working Directory**
```
Problem: Git won't let you switch branches with uncommitted changes
Solution: Stash changes → Switch branch → Work → Return → Restore stash
```

#### 3. **📦 Pulling Updates with Local Changes**
```
Problem: Can't pull remote changes due to local modifications
Solution: Stash → Pull → Restore stash (may need to resolve conflicts)
```

#### 4. **🧪 Experimental Code Testing**
```
Scenario: Want to try different approach without losing current work
Solution: Stash current work → Try new approach → Restore if needed
```

#### 5. **🔧 Quick Environment Setup**
```
Use case: Need clean working directory for testing/deployment
Solution: Stash all changes → Test → Restore when done
```

---

## 📋 Essential Git Stash Commands

### **Basic Operations**

| Command | Description | Example |
|---------|-------------|---------|
| `git stash` | Save current changes | `git stash` |
| `git stash push -m "message"` | Save with custom message | `git stash push -m "Login feature WIP"` |
| `git stash list` | Show all stashes | `git stash list` |
| `git stash show [stash@{n}]` | Show stash summary | `git stash show stash@{1}` |
| `git stash show -p [stash@{n}]` | Show detailed diff | `git stash show -p stash@{0}` |

### **Restore Operations**

| Command | Description | When to Use |
|---------|-------------|-------------|
| `git stash apply [stash@{n}]` | Apply stash (keeps in list) | When you might need the stash again |
| `git stash pop [stash@{n}]` | Apply and remove from list | When you're done with the stash |
| `git stash branch <branch> [stash@{n}]` | Create branch from stash | When stash conflicts with current branch |

### **Management Operations**

| Command | Description | Use Case |
|---------|-------------|----------|
| `git stash drop [stash@{n}]` | Delete specific stash | Clean up unwanted stashes |
| `git stash clear` | Delete all stashes | Clean slate |

---

## 🎓 Advanced Git Stash Techniques

### **1. Selective Stashing**
```bash
# Stash only specific files
git stash push -m "Only config changes" config.js package.json

# Stash including untracked files
git stash push --include-untracked -m "With new files"

# Stash only staged changes
git stash push --staged -m "Only staged changes"
```

### **2. Stash Management Best Practices**
```bash
# Always use descriptive messages
git stash push -m "User authentication half-complete"

# Regularly clean up old stashes
git stash list  # Review what you have
git stash drop stash@{2}  # Remove specific old stash

# Name your stashes meaningfully
git stash push -m "Before refactoring user service"
```

### **3. Working with Stash Conflicts**
```bash
# When applying stash causes conflicts
git stash apply stash@{1}
# Resolve conflicts manually in your editor
git add resolved-file.js
# Continue your work (no need to commit the conflict resolution)
```

---

## 🔍 Understanding Stash Identifiers

### **Stash Naming Convention:**
```
stash@{0}  ← Most recent stash (top of stack)
stash@{1}  ← Second most recent
stash@{2}  ← Third most recent
...
```

### **Stash Information Format:**
```
stash@{0}: WIP on master: 1a2b3c4 Last commit message
           ↑    ↑       ↑        ↑
        Index  Branch  Commit   Commit message
```

---

## ⚠️ Important Considerations

### **What Gets Stashed:**
- ✅ **Modified tracked files** - Files git already knows about
- ✅ **Staged changes** - Changes added with `git add`
- ❌ **Untracked files** - New files (unless `--include-untracked`)
- ❌ **Ignored files** - Files in `.gitignore`

### **Stash Limitations:**
- **Local only** - Cannot be shared between repositories
- **Not backup** - Lost if repository is deleted
- **Temporary nature** - Should not replace proper commits
- **Merge conflicts** - May occur when applying stashes

### **Best Practices:**
1. **Use descriptive messages** - Know what each stash contains
2. **Clean up regularly** - Don't let stashes accumulate
3. **Prefer commits for important work** - Stashes are temporary
4. **Check stash content** before applying - Use `git stash show -p`

---

## 🎯 Practical Examples

### **Example 1: Emergency Bug Fix**
```bash
# Currently working on new feature
echo "new feature code" >> feature.js
git add feature.js

# Emergency: Production bug!
git stash push -m "New feature development in progress"

# Fix the bug
git checkout master
echo "bug fix" >> bugfix.js
git add bugfix.js
git commit -m "Fix critical production bug"
git push origin master

# Back to feature development
git checkout feature-branch
git stash pop  # Restore your work
```

### **Example 2: Pulling Remote Updates**
```bash
# You have local changes
git status  # Shows modified files

# Team pushed updates
git pull  # Error: would be overwritten

# Solution with stash
git stash push -m "Local changes before pull"
git pull origin master
git stash pop  # May need to resolve conflicts
```

### **Example 3: Experimenting with Code**
```bash
# Current working implementation
git stash push -m "Current working version"

# Try completely different approach
# ... experiment with new code ...

# If experiment fails
git stash pop  # Restore original work

# If experiment succeeds
git stash drop stash@{0}  # Remove old version
```

---

## 🔧 Troubleshooting Common Issues

### **Issue 1: Stash Apply Conflicts**
```bash
# When conflicts occur during stash apply
git stash apply stash@{1}
# Auto-merging file.js
# CONFLICT (content): Merge conflict in file.js

# Solution:
# 1. Edit file.js to resolve conflicts
# 2. git add file.js
# 3. Continue working (conflicts resolved)
```

### **Issue 2: Can't Remember Stash Contents**
```bash
# See what's in each stash
git stash list
git stash show -p stash@{0}  # Detailed view
git stash show stash@{1}     # Summary view
```

### **Issue 3: Accidentally Stashed Wrong Changes**
```bash
# Apply the stash to get changes back
git stash apply stash@{0}

# Make corrections
# Then stash again with proper message
git stash push -m "Corrected version of changes"

# Remove the old incorrect stash
git stash drop stash@{1}
```

---

## 📚 Quick Reference

### **Daily Workflow Commands:**
```bash
# Quick save current work
git stash

# Save with description
git stash push -m "Descriptive message"

# See what you have stashed
git stash list

# Get your work back
git stash pop

# See what's in a stash before applying
git stash show -p stash@{0}

# Clean up old stashes
git stash clear
```

### **Memory Aid - The 4 S's of Git Stash:**
1. **Save** - `git stash push -m "message"`
2. **Show** - `git stash list` and `git stash show`
3. **Salvage** - `git stash apply` or `git stash pop`
4. **Scrap** - `git stash drop` or `git stash clear`

---

## 🎯 Summary

Git stash is an essential tool for managing temporary changes in your development workflow. It provides a clean way to:

- **Context switch** quickly between different tasks
- **Experiment** safely with new approaches
- **Collaborate** effectively by managing local changes
- **Maintain** a clean working directory when needed

Remember: **Stash is for temporary saves, commits are for permanent history!**