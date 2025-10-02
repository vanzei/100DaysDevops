# Update package repositories and system packages
sudo yum update -y

# Install SELinux packages
sudo yum install -y selinux-policy selinux-policy-targeted policycoreutils policycoreutils-python-utils setroubleshoot-server

# Edit SELinux configuration
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config

# Verify the configuration
cat /etc/selinux/config | grep SELINUX=