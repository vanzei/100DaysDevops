```

# Navigate and setup
cd /usr/src/kodekloudrepos
git status
git fetch origin

# Switch to feature branch
git checkout feature

# View current state
git log --oneline --graph
git log master..feature --oneline

# Perform rebase
git rebase master

# If conflicts, resolve them:
# (edit files, then git add them, then git rebase --continue)

# Verify result
git log --oneline --graph

# Push changes
git push origin feature --force-with-lease

```