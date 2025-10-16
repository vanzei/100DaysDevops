# 1. Setup (you already did this)
cd /usr/src/kodekloudrepos/ecommerce
cp .git/hooks/post-update.sample .git/hooks/post-update
vi .git/hooks/post-update  # Add your script
chmod +x .git/hooks/post-update

# 2. Switch to master
git checkout master

# 3. Merge feature branch FIRST
git merge feature

# 4. THEN create the tag (this is the key!)
.git/hooks/post-update

# 5. Push everything
git push origin master --tags