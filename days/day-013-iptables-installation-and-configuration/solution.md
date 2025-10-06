```
#!/bin/bash

# Day 013: IPtables Installation and Configuration
# Complete implementation script

echo "=== Installing iptables and dependencies ==="
sudo dnf install iptables iptables-services -y

echo "=== Configuring firewall rules ==="
# Replace with actual LBR host IP
LBR_HOST_IP="172.16.238.14"

# Basic connectivity rules
sudo iptables -I INPUT -i lo -j ACCEPT
sudo iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT

# Allow LBR host access to port 6200
sudo iptables -I INPUT -p tcp -s $LBR_HOST_IP --dport 6200 -j ACCEPT

# Block all other access to port 6200
sudo iptables -A INPUT -p tcp --dport 6200 -j REJECT

echo "=== Current iptables rules ==="
sudo iptables -L -n --line-numbers

echo "=== Making rules persistent ==="
# Method 1: Use tee to write with sudo privileges
sudo iptables-save | sudo tee /etc/sysconfig/iptables > /dev/null

# Method 2: Alternative - use service command to save
# sudo service iptables save

sudo systemctl enable iptables
sudo systemctl start iptables

echo "=== Verification ==="
sudo systemctl status iptables
echo "Rules have been applied and will persist after reboot"

```