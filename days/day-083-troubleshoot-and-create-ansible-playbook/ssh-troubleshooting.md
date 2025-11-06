# SSH Connection Troubleshooting Guide for Ansible

## Error Analysis: SSH Authentication Failure

### The Error
```
fatal: [stapp02]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: steve@172.16.238.11: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).", "unreachable": true}
```

### Root Cause
The error occurs because SSH is attempting multiple authentication methods in this order:
1. **publickey** (SSH key authentication) - fails because no key is configured
2. **gssapi-keyex** (Kerberos key exchange) - fails because not configured
3. **gssapi-with-mic** (Kerberos with MIC) - fails because not configured  
4. **password** (password authentication) - may fail due to SSH client configuration

## Solution Applied

### Updated Inventory Configuration
The inventory has been updated with proper SSH options:

```ini
# System variables
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'
```

### SSH Options Explained
- **`StrictHostKeyChecking=no`**: Skip host key verification (for lab environments)
- **`UserKnownHostsFile=/dev/null`**: Don't save host keys to known_hosts file
- **`PubkeyAuthentication=no`**: Disable SSH key authentication attempts
- **`PreferredAuthentications=password`**: Force password authentication first

## Testing Steps

### Step 1: Test SSH Connection Manually
```bash
# Test direct SSH connection with the same options
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password steve@stapp02
```

### Step 2: Test Ansible Ping
```bash
# Test Ansible connectivity
cd /home/thor/ansible
ansible -i inventory stapp02 -m ping
```

### Step 3: Run with Verbose Output
```bash
# Run with maximum verbosity to see detailed SSH debugging
ansible -i inventory stapp02 -m ping -vvv
```

### Step 4: Execute the Playbook
```bash
# Run the playbook
ansible-playbook -i inventory playbook.yml
```

## Alternative Solutions

### Solution 1: Use SSH Key Authentication (Recommended for Production)

#### Generate SSH Key Pair
```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/stapp02_key -N ""

# Copy public key to target server
ssh-copy-id -i ~/.ssh/stapp02_key.pub steve@stapp02
```

#### Update Inventory for SSH Keys
```ini
[app_servers]
stapp02

[app_servers:vars]
ansible_user=steve
ansible_ssh_private_key_file=~/.ssh/stapp02_key
ansible_become=yes
ansible_become_pass=Am3ric@
ansible_become_method=sudo
ansible_become_user=root
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Solution 2: Use Connection Variables in Playbook
```yaml
---
- name: Create empty file on App Server 2
  hosts: app_servers
  gather_facts: no
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o PubkeyAuthentication=no -o PreferredAuthentications=password'
  
  tasks:
    - name: Create empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
```

### Solution 3: Use Command Line Options
```bash
# Run playbook with explicit SSH arguments
ansible-playbook -i inventory playbook.yml --ssh-common-args='-o PubkeyAuthentication=no -o PreferredAuthentications=password'
```

## Additional Troubleshooting

### Check Host Connectivity
```bash
# Test basic network connectivity
ping stapp02

# Test SSH port availability
telnet stapp02 22
# or
nc -zv stapp02 22
```

### Verify SSH Service on Target
```bash
# Check if SSH service is running (if you have access)
systemctl status sshd

# Check SSH configuration
sudo sshd -T | grep -i passwordauth
sudo sshd -T | grep -i pubkeyauth
```

### Check SSH Client Configuration
```bash
# View SSH client configuration
ssh -F /dev/null -o BatchMode=yes steve@stapp02 2>&1

# Test with explicit configuration
ssh -o BatchMode=no -o PasswordAuthentication=yes -o PubkeyAuthentication=no steve@stapp02
```

### Debug SSH Connection
```bash
# Run SSH with maximum verbosity
ssh -vvv -o PubkeyAuthentication=no -o PreferredAuthentications=password steve@stapp02

# Test Ansible with SSH debugging
ANSIBLE_SSH_ARGS="-vvv" ansible -i inventory stapp02 -m ping
```

## Environment-Specific Considerations

### Stratos DC Lab Environment
- **Network**: Servers may be on isolated network segments
- **Authentication**: Password-based authentication is common in lab setups
- **Security**: Host key checking often disabled for convenience
- **Firewall**: SSH port (22) should be accessible

### Common Lab Server Credentials
```bash
# App Server 2 (stapp02)
Username: steve
Password: Am3ric@
IP: 172.16.238.11 (as shown in error)
```

## Complete Working Configuration

### Final inventory File
```ini
# Ansible Inventory for App Server 2
# Day 083 Challenge Solution
# File: /home/thor/ansible/inventory

[app_servers]
stapp02

[app_servers:vars]
# Connection variables
ansible_user=steve
ansible_ssh_pass=Am3ric@
ansible_become=yes
ansible_become_pass=Am3ric@
ansible_become_method=sudo
ansible_become_user=root

# System variables
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'
```

### Verification Commands
```bash
# Navigate to ansible directory
cd /home/thor/ansible

# Test inventory parsing
ansible-inventory -i inventory --list

# Test connectivity
ansible -i inventory stapp02 -m ping

# Run playbook
ansible-playbook -i inventory playbook.yml

# Verify file creation
ansible -i inventory stapp02 -m command -a "ls -la /tmp/file.txt"
```

## Expected Output After Fix

### Successful Ping Test
```
stapp02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### Successful Playbook Execution
```
PLAY [Create empty file on App Server 2] ************************************

TASK [Create empty file /tmp/file.txt] **************************************
changed: [stapp02]

PLAY RECAP *******************************************************************
stapp02                    : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

The key fix is forcing SSH to use password authentication and disabling public key authentication attempts, which resolves the "Permission denied" error you encountered.