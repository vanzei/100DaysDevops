```
sudo vi /etc/sshd/sshd_config

-> Modify to :
PermissionRootLogin no

sudo systemctl restart sshd
```