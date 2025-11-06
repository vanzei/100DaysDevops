# Day 082: Ansible Inventory Solution

## Challenge Requirements
- Create an INI type Ansible inventory file at `/home/thor/playbook/inventory`
- Include App Server 2 in the inventory
- Use proper hostname `stapp02` for app server 2
- Include necessary variables for proper functionality
- Ensure playbook works with command: `ansible-playbook -i inventory playbook.yml`

## Solution

### Inventory File: `/home/thor/playbook/inventory`

```ini
# Ansible Inventory for App Server Testing
# Created for Day 082 Challenge

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

### Alternative Solution with Host-Specific Variables

```ini
# Alternative format with host-specific variables
[app_servers]
stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_become=yes ansible_become_pass=Am3ric@

[app_servers:vars]
ansible_become_method=sudo
ansible_become_user=root
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

## Implementation Steps

### Step 1: Create Directory Structure
```bash
# Ensure the playbook directory exists
mkdir -p /home/thor/playbook

# Navigate to the directory
cd /home/thor/playbook
```

### Step 2: Create Inventory File
```bash
# Create the inventory file
cat > /home/thor/playbook/inventory << 'EOF'
# Ansible Inventory for App Server Testing
# App Server 2 Configuration

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

### Step 3: Verify Inventory File
```bash
# Check if file was created correctly
cat /home/thor/playbook/inventory

# Test inventory syntax
ansible-inventory -i /home/thor/playbook/inventory --list
```

### Step 4: Test Connectivity
```bash
# Test connection to app server 2
ansible -i /home/thor/playbook/inventory stapp02 -m ping

# Test with group name
ansible -i /home/thor/playbook/inventory app_servers -m ping
```

## Variable Explanations

### Connection Variables
- **ansible_user=steve**: Username for SSH connection to app server 2
- **ansible_ssh_pass=Am3ric@**: SSH password for the user (in real scenarios, use SSH keys)
- **ansible_become=yes**: Enable privilege escalation
- **ansible_become_pass=Am3ric@**: Password for sudo/privilege escalation
- **ansible_become_method=sudo**: Method for privilege escalation
- **ansible_become_user=root**: User to escalate privileges to

### System Variables
- **ansible_python_interpreter=/usr/bin/python3**: Python interpreter path
- **ansible_ssh_common_args='-o StrictHostKeyChecking=no'**: SSH options to disable host key checking

## Testing the Solution

### Test Inventory Parsing
```bash
# List all hosts in inventory
ansible-inventory -i inventory --list

# Show host details
ansible-inventory -i inventory --host stapp02

# Test with graph view
ansible-inventory -i inventory --graph
```

### Test Playbook Execution
```bash
# Run a simple playbook (assuming one exists)
ansible-playbook -i inventory playbook.yml

# Run with verbose output for debugging
ansible-playbook -i inventory playbook.yml -v

# Check syntax without execution
ansible-playbook -i inventory playbook.yml --syntax-check
```

### Ad-hoc Command Testing
```bash
# Test basic connectivity
ansible -i inventory stapp02 -m ping

# Get system facts
ansible -i inventory stapp02 -m setup

# Check system uptime
ansible -i inventory stapp02 -m command -a "uptime"

# Test privilege escalation
ansible -i inventory stapp02 -m command -a "whoami" --become
```

## Common Issues and Troubleshooting

### Issue 1: SSH Host Key Verification Failed
**Error**: `Host key verification failed`
**Solution**: Add `ansible_ssh_common_args='-o StrictHostKeyChecking=no'`

### Issue 2: Authentication Failure
**Error**: `Authentication failure`
**Solution**: Verify username and password are correct for app server 2

### Issue 3: Privilege Escalation Failed
**Error**: `sudo: a password is required`
**Solution**: Ensure `ansible_become_pass` is set correctly

### Issue 4: Python Interpreter Not Found
**Error**: `/usr/bin/python: not found`
**Solution**: Set `ansible_python_interpreter=/usr/bin/python3`

## Security Considerations

### For Production Use
```ini
# Use SSH keys instead of passwords
[app_servers]
stapp02 ansible_ssh_private_key_file=~/.ssh/app_server_key

[app_servers:vars]
ansible_user=steve
ansible_become=yes
ansible_become_method=sudo
ansible_python_interpreter=/usr/bin/python3
```

### With Ansible Vault
```bash
# Create encrypted password file
ansible-vault create group_vars/app_servers/vault.yml

# Content of vault file:
# vault_ssh_password: Am3ric@
# vault_become_password: Am3ric@

# Updated inventory
[app_servers]
stapp02

[app_servers:vars]
ansible_user=steve
ansible_ssh_pass="{{ vault_ssh_password }}"
ansible_become=yes
ansible_become_pass="{{ vault_become_password }}"
```

## Verification Commands

### Before Running Playbook
```bash
# 1. Verify inventory file exists
ls -la /home/thor/playbook/inventory

# 2. Check inventory syntax
ansible-inventory -i /home/thor/playbook/inventory --list

# 3. Test connectivity
ansible -i /home/thor/playbook/inventory stapp02 -m ping

# 4. Verify variables are loaded correctly
ansible-inventory -i /home/thor/playbook/inventory --host stapp02
```

### Expected Outputs

#### Inventory List Output
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

#### Ping Test Output
```
stapp02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

This solution provides a working Ansible inventory file that meets all the challenge requirements and includes proper variable configuration for connecting to app server 2.