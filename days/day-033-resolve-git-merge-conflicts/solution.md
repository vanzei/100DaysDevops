# 1. Check the conflicted file
cat story-index.txt

# 2. Edit and resolve conflicts
nano story-index.txt
# (Remove conflict markers, ensure 4 stories, fix "Mooose" → "Mouse")

# 3. Stage the resolved file
git add story-index.txt

# 4. Complete the merge
git commit -m "Resolve merge conflict and fix story content"

# 5. Push the changes
git push origin master