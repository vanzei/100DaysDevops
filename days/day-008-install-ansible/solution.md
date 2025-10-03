```
# Update system packages
sudo dnf update -y

# Install Python 3 and pip3 if not already installed
sudo dnf install -y python3 python3-pip

# Install Ansible 4.10.0 globally
sudo pip3 install ansible==4.10.0

# Verify installation
ansible --version
```