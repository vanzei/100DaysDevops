```bash


sudo cd /usr/src/kodekloudrepos/demo
sudo git checkout -b nautilus
sudo cp /tmp/index.html .
sudo git add index.html
sudo git commit -m "added index file"
sudo git push origin nautilus
sudo git checkout master
sudo git merge nautilus
sudo git commit -m "branchs merged"
sudo git push origin master
```