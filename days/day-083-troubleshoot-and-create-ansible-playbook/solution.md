# Day 083: Troubleshoot and Create Ansible Playbook - Complete Solution

## Challenge Overview
This challenge requires completing an Ansible setup by:
1. Adjusting the inventory file to target App Server 2 in Stratos DC
2. Creating a playbook that creates an empty file `/tmp/file.txt` on App Server 2
3. Ensuring the playbook works with the command: `ansible-playbook -i inventory playbook.yml`

## Challenge Requirements Analysis

### Requirements Breakdown
- **Inventory File**: `/home/thor/ansible/inventory` - must target App Server 2
- **Playbook File**: `/home/thor/ansible/playbook.yml` - must create `/tmp/file.txt`
- **Target Server**: App Server 2 in Stratos DC (hostname: `stapp02`)
- **Validation Command**: `ansible-playbook -i inventory playbook.yml`

### Stratos DC Environment Context
- **App Server 2**: Hostname `stapp02`
- **SSH User**: `steve`
- **SSH Password**: `Am3ric@`
- **Sudo Access**: Available with same password
- **Operating System**: Linux (CentOS/RHEL based)

## Solution Files

### 1. Inventory File: `/home/thor/ansible/inventory`

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
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### 2. Playbook File: `/home/thor/ansible/playbook.yml`

```yaml
---
# Ansible Playbook for Day 083 Challenge
# Create empty file on App Server 2
# File: /home/thor/ansible/playbook.yml

- name: Create empty file on App Server 2
  hosts: app_servers
  gather_facts: no
  
  tasks:
    - name: Create empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
```

## Implementation Steps

### Step 1: Create Directory Structure
```bash
# Create the ansible directory
mkdir -p /home/thor/ansible

# Navigate to the directory
cd /home/thor/ansible
```

### Step 2: Create Inventory File
```bash
# Create the inventory file
cat > /home/thor/ansible/inventory << 'EOF'
# Ansible Inventory for App Server 2
[app_servers]
stapp02

[app_servers:vars]
ansible_user=steve
ansible_ssh_pass=Am3ric@
ansible_become=yes
ansible_become_pass=Am3ric@
ansible_become_method=sudo
ansible_become_user=root
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### Step 3: Create Playbook File
```bash
# Create the playbook file
cat > /home/thor/ansible/playbook.yml << 'EOF'
---
- name: Create empty file on App Server 2
  hosts: app_servers
  gather_facts: no
  
  tasks:
    - name: Create empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
EOF
```

### Step 4: Verify File Creation
```bash
# Check both files exist
ls -la /home/thor/ansible/

# Verify inventory content
cat /home/thor/ansible/inventory

# Verify playbook content
cat /home/thor/ansible/playbook.yml
```

## Testing and Validation

### Pre-execution Tests

#### 1. Validate Inventory Syntax
```bash
# Change to the ansible directory
cd /home/thor/ansible

# List inventory hosts
ansible-inventory -i inventory --list

# Show specific host details
ansible-inventory -i inventory --host stapp02
```

#### 2. Test Connectivity
```bash
# Test ping to app server
ansible -i inventory stapp02 -m ping

# Test with group name
ansible -i inventory app_servers -m ping
```

#### 3. Validate Playbook Syntax
```bash
# Check playbook syntax
ansible-playbook -i inventory playbook.yml --syntax-check

# Run in check mode (dry run)
ansible-playbook -i inventory playbook.yml --check
```

### Execute the Solution
```bash
# Run the playbook
ansible-playbook -i inventory playbook.yml
```

### Post-execution Verification
```bash
# Verify file was created
ansible -i inventory stapp02 -m command -a "ls -la /tmp/file.txt"

# Check file permissions
ansible -i inventory stapp02 -m stat -a "path=/tmp/file.txt"

# Alternative verification
ansible -i inventory stapp02 -m shell -a "test -f /tmp/file.txt && echo 'File exists' || echo 'File missing'"
```

## Solution Components Explained

### Inventory Configuration

#### Group Definition
```ini
[app_servers]
stapp02
```
- **`app_servers`**: Logical group name for application servers
- **`stapp02`**: Hostname for App Server 2 in Stratos DC

#### Connection Variables
```ini
ansible_user=steve
ansible_ssh_pass=Am3ric@
```
- **`ansible_user`**: SSH username for connecting to the server
- **`ansible_ssh_pass`**: SSH password (in production, use SSH keys instead)

#### Privilege Escalation
```ini
ansible_become=yes
ansible_become_pass=Am3ric@
ansible_become_method=sudo
ansible_become_user=root
```
- **`ansible_become=yes`**: Enable privilege escalation
- **`ansible_become_pass`**: Password for sudo
- **`ansible_become_method=sudo`**: Use sudo for privilege escalation
- **`ansible_become_user=root`**: Escalate to root user

#### System Configuration
```ini
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```
- **`ansible_python_interpreter`**: Use Python 3 for compatibility
- **`ansible_ssh_common_args`**: Disable SSH host key checking for lab environment

### Playbook Structure

#### Play Header
```yaml
- name: Create empty file on App Server 2
  hosts: app_servers
  gather_facts: no
```
- **`name`**: Descriptive name for the play
- **`hosts`**: Target the `app_servers` group
- **`gather_facts: no`**: Skip fact gathering for speed

#### Task Definition
```yaml
tasks:
  - name: Create empty file /tmp/file.txt
    file:
      path: /tmp/file.txt
      state: touch
      mode: '0644'
```
- **`name`**: Clear description of what the task does
- **`file`**: Ansible module for file operations
- **`path`**: Target file path
- **`state: touch`**: Create empty file (like Unix `touch` command)
- **`mode: '0644'`**: Set file permissions (readable by owner/group/others, writable by owner)

## Alternative Implementations

### Alternative 1: With Error Handling
```yaml
---
- name: Create empty file on App Server 2 with error handling
  hosts: app_servers
  gather_facts: no
  
  tasks:
    - name: Ensure /tmp directory exists
      file:
        path: /tmp
        state: directory
        mode: '0755'
      
    - name: Create empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
      register: file_creation
      
    - name: Verify file creation
      stat:
        path: /tmp/file.txt
      register: file_stat
      
    - name: Display file creation status
      debug:
        msg: |
          File creation: {{ 'SUCCESS' if file_stat.stat.exists else 'FAILED' }}
          File path: {{ file_stat.stat.path | default('N/A') }}
          File size: {{ file_stat.stat.size | default('N/A') }} bytes
          File permissions: {{ file_stat.stat.mode | default('N/A') }}
```

### Alternative 2: With Variables
```yaml
---
- name: Create file with variables
  hosts: app_servers
  gather_facts: no
  vars:
    target_file: /tmp/file.txt
    file_mode: '0644'
    file_owner: root
    file_group: root
  
  tasks:
    - name: Create empty file {{ target_file }}
      file:
        path: "{{ target_file }}"
        state: touch
        mode: "{{ file_mode }}"
        owner: "{{ file_owner }}"
        group: "{{ file_group }}"
```

### Alternative 3: With Conditional Logic
```yaml
---
- name: Create file with conditions
  hosts: app_servers
  gather_facts: yes
  
  tasks:
    - name: Create file only on CentOS/RHEL systems
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
      when: ansible_os_family == "RedHat"
      
    - name: Create file only on Ubuntu/Debian systems
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
      when: ansible_os_family == "Debian"
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: SSH Connection Failed
**Error**: `UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh"}`

**Solutions**:
```bash
# Test manual SSH connection
ssh steve@stapp02

# Check if host is reachable
ping stapp02

# Verify SSH service is running
ansible -i inventory stapp02 -m command -a "systemctl status sshd" --ask-pass
```

#### Issue 2: Authentication Failure
**Error**: `FAILED! => {"msg": "Authentication failure"}`

**Solutions**:
```bash
# Verify credentials in inventory
cat inventory | grep -A5 "\[app_servers:vars\]"

# Test with explicit password prompt
ansible -i inventory stapp02 -m ping --ask-pass

# Check if user exists on target server
ssh steve@stapp02 'id'
```

#### Issue 3: Permission Denied
**Error**: `FAILED! => {"msg": "Permission denied"}`

**Solutions**:
```bash
# Test sudo access
ssh steve@stapp02 'sudo whoami'

# Check sudoers configuration
ssh steve@stapp02 'sudo -l'

# Verify become configuration in inventory
grep -A3 "ansible_become" inventory
```

#### Issue 4: Python Interpreter Issues
**Error**: `MODULE FAILURE: /usr/bin/python: not found`

**Solutions**:
```bash
# Check Python installation
ssh steve@stapp02 'which python3'
ssh steve@stapp02 'python3 --version'

# Update inventory with correct Python path
# ansible_python_interpreter=/usr/bin/python3
```

#### Issue 5: File Creation Failed
**Error**: Task fails to create file

**Solutions**:
```bash
# Check /tmp directory permissions
ansible -i inventory stapp02 -m command -a "ls -ld /tmp"

# Test file creation manually
ansible -i inventory stapp02 -m shell -a "touch /tmp/test.txt && ls -la /tmp/test.txt"

# Check disk space
ansible -i inventory stapp02 -m command -a "df -h /tmp"
```

### Debugging Commands

#### Verbose Execution
```bash
# Run with verbose output
ansible-playbook -i inventory playbook.yml -v

# Extra verbose (shows task details)
ansible-playbook -i inventory playbook.yml -vv

# Maximum verbosity (shows all details)
ansible-playbook -i inventory playbook.yml -vvv
```

#### Step-by-Step Execution
```bash
# Run playbook step by step
ansible-playbook -i inventory playbook.yml --step

# Start at specific task
ansible-playbook -i inventory playbook.yml --start-at-task="Create empty file /tmp/file.txt"
```

#### Check Mode Testing
```bash
# Dry run to see what would change
ansible-playbook -i inventory playbook.yml --check

# Show differences that would be made
ansible-playbook -i inventory playbook.yml --check --diff
```

## Production Considerations

### Security Improvements

#### 1. Use SSH Keys Instead of Passwords
```ini
# Secure inventory configuration
[app_servers]
stapp02

[app_servers:vars]
ansible_user=steve
ansible_ssh_private_key_file=~/.ssh/stapp02_key
ansible_become=yes
ansible_become_method=sudo
ansible_python_interpreter=/usr/bin/python3
```

#### 2. Use Ansible Vault for Sensitive Data
```bash
# Create vault file for passwords
ansible-vault create group_vars/app_servers/vault.yml

# Content of vault file:
# vault_ssh_password: Am3ric@
# vault_become_password: Am3ric@

# Updated inventory:
# ansible_ssh_pass="{{ vault_ssh_password }}"
# ansible_become_pass="{{ vault_become_password }}"
```

#### 3. Limit Sudo Privileges
```bash
# On target server, create specific sudoers rule
echo "steve ALL=(ALL) NOPASSWD: /bin/touch, /bin/ls, /bin/cat" | sudo tee /etc/sudoers.d/ansible-steve
```

### Enhanced Playbook Features

#### 1. Add Error Handling
```yaml
---
- name: Robust file creation
  hosts: app_servers
  gather_facts: no
  
  tasks:
    - name: Create empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
      register: file_result
      failed_when: false
      
    - name: Handle file creation failure
      debug:
        msg: "File creation failed: {{ file_result.msg | default('Unknown error') }}"
      when: file_result.failed | default(false)
      
    - name: Confirm successful file creation
      debug:
        msg: "File /tmp/file.txt created successfully"
      when: not (file_result.failed | default(false))
```

#### 2. Add Validation
```yaml
---
- name: Create and validate file
  hosts: app_servers
  gather_facts: no
  
  tasks:
    - name: Create empty file /tmp/file.txt
      file:
        path: /tmp/file.txt
        state: touch
        mode: '0644'
        
    - name: Verify file exists
      stat:
        path: /tmp/file.txt
      register: file_stat
      
    - name: Assert file was created
      assert:
        that:
          - file_stat.stat.exists
          - file_stat.stat.isreg
        fail_msg: "File /tmp/file.txt was not created properly"
        success_msg: "File /tmp/file.txt created and verified successfully"
```

## Expected Output

### Successful Inventory List
```json
{
    "_meta": {
        "hostvars": {
            "stapp02": {
                "ansible_become": true,
                "ansible_become_method": "sudo",
                "ansible_become_pass": "Am3ric@",
                "ansible_become_user": "root",
                "ansible_python_interpreter": "/usr/bin/python3",
                "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
                "ansible_ssh_pass": "Am3ric@",
                "ansible_user": "steve"
            }
        }
    },
    "all": {
        "children": [
            "ungrouped",
            "app_servers"
        ]
    },
    "app_servers": {
        "hosts": [
            "stapp02"
        ]
    }
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

### File Verification
```bash
# Command: ansible -i inventory stapp02 -m command -a "ls -la /tmp/file.txt"
stapp02 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 0 Nov  5 10:30 /tmp/file.txt
```

This comprehensive solution provides everything needed to successfully complete Challenge 83, including troubleshooting guides, alternative implementations, and production-ready enhancements.