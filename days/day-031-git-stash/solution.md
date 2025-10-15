

```
cd /usr/src/kodekloudrepos/news
git stash list
git stash show stash@{1}

git stash apply stash@{1}
git status
git diff

git add .
git commit -m "Restore stashed changes from stash@{1}"
git push origin master

```