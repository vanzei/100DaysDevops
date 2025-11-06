# Challenge 84 Troubleshooting Guide

## Issue: "Destination /opt/data not writable"

### Root Cause
The error occurred because the tasks were trying to write to `/opt/data` without proper root privileges. Even though the inventory file had `ansible_become=yes` configured, the playbook itself didn't specify `become: yes`.

### Solution Applied

#### 1. Fixed Inventory File Issues
**Problem**: Mixed SSH parameter names
- `stapp01` had `ansible_ssh_password` 
- `stapp02` and `stapp03` had `ansible_ssh_pass`

**Fix**: Standardized all to use `ansible_ssh_pass` (without quotes to avoid shell escaping issues)

#### 2. Added Privilege Escalation to Playbook
**Problem**: Tasks needed root privileges but playbook didn't specify `become: yes`

**Fix**: Added `become: yes` at the play level:

```yaml
- name: Copy data file to all application servers
  hosts: app_servers
  gather_facts: no
  become: yes  # <-- This was missing!
```

### Testing Commands

```bash
# 1. Test inventory file syntax
ansible-inventory -i inventory --list

# 2. Test SSH connectivity 
ansible -i inventory app_servers -m ping

# 3. Test sudo access
ansible -i inventory app_servers -m command -a "whoami" --become

# 4. Check if source file exists
ls -la /usr/src/data/index.html

# 5. Run the corrected playbook
ansible-playbook -i inventory playbook.yml

# 6. Verify the file was copied successfully
ansible -i inventory app_servers -m command -a "ls -la /opt/data/" --become
```

### Key Ansible Concepts

#### Privilege Escalation Options

1. **At Play Level** (recommended for this challenge):
```yaml
- name: My playbook
  hosts: all
  become: yes        # All tasks run with sudo
```

2. **At Task Level**:
```yaml
- name: Create directory
  file:
    path: /opt/data
    state: directory
  become: yes         # Only this task runs with sudo
```

3. **Via Command Line**:
```bash
ansible-playbook -i inventory playbook.yml --become
```

#### Inventory Parameter Consistency

Always use consistent parameter names:
- `ansible_ssh_pass` (not `ansible_ssh_password`)
- Remove quotes around passwords unless they contain special shell characters
- Ensure all hosts have the same required parameters

### Verification Steps

After running the corrected playbook, you should see:

```
PLAY [Copy data file to all application servers] *****************************

TASK [Ensure destination directory exists] ***********************************
changed: [stapp01]
changed: [stapp02] 
changed: [stapp03]

TASK [Copy index.html file to application servers] ***************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

PLAY RECAP ********************************************************************
stapp01                    : ok=2    changed=2    unreachable=0    failed=0
stapp02                    : ok=2    changed=2    unreachable=0    failed=0  
stapp03                    : ok=2    changed=2    unreachable=0    failed=0
```

### Common Permission Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Destination not writable" | Missing `become: yes` | Add privilege escalation |
| "Permission denied" | Wrong user credentials | Check SSH user/password |
| "sudo: no tty present" | sudo requires interactive terminal | Add `ansible_ssh_common_args` |
| "Authentication failure" | Wrong SSH password | Verify credentials in inventory |

### Final File Structure

```
/home/thor/ansible/
├── inventory      # Fixed SSH parameters and sudo config
└── playbook.yml   # Added become: yes for privilege escalation
```

The solution is now ready to run successfully!