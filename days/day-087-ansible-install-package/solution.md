# Day 087: Ansible Install Package - Solution

## Challenge Requirements
1. Create inventory file `/home/thor/playbook/inventory` with all app servers
2. Create Ansible playbook `/home/thor/playbook/playbook.yml` to install wget using yum module
3. Ensure thor user can run the playbook on jump host
4. Playbook must work with command: `ansible-playbook -i inventory playbook.yml`

## Solution Steps

### Step 1: Create Directory Structure
```bash
# On jump host as thor user
mkdir -p /home/thor/playbook
cd /home/thor/playbook
```

### Step 2: Create Inventory File
Create `/home/thor/playbook/inventory`:
```ini
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=Ir0nM@n
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=BigGr33n
```

### Step 3: Create Ansible Playbook
Create `/home/thor/playbook/playbook.yml`:
```yaml
---
- name: Install wget package on all app servers
  hosts: app_servers
  become: yes
  become_method: sudo
  gather_facts: no
  
  tasks:
    - name: Install wget package using yum
      yum:
        name: wget
        state: present
      register: wget_install_result
      
    - name: Display installation result
      debug:
        msg: "wget package installation completed on {{ inventory_hostname }}"
      when: wget_install_result is succeeded
```

### Step 4: Execute the Playbook
```bash
# Change to the playbook directory
cd /home/thor/playbook

# Run the playbook (exact command as required)
ansible-playbook -i inventory playbook.yml
```

## Key Configuration Details

### Inventory Configuration
- **Host Groups**: `[app_servers]` groups all application servers
- **Connection Details**: Each server has specific IP, user, and password
- **Users**: 
  - stapp01: tony
  - stapp02: steve  
  - stapp03: banner

### Playbook Configuration
- **Target**: `hosts: app_servers` (targets all servers in the group)
- **Privilege Escalation**: `become: yes` with `sudo` method
- **Package Manager**: Uses `yum` module (for CentOS/RHEL systems)
- **Package**: Installs `wget` package
- **State**: `present` ensures package is installed

## Alternative Approaches

### Option 1: Single Command (Ad-hoc)
```bash
ansible app_servers -i inventory -m yum -a "name=wget state=present" --become
```

### Option 2: Advanced Playbook with Error Handling
```yaml
---
- name: Install wget package on all app servers
  hosts: app_servers
  become: yes
  gather_facts: yes
  
  tasks:
    - name: Update yum cache
      yum:
        update_cache: yes
      ignore_errors: yes
      
    - name: Install wget package
      yum:
        name: wget
        state: present
      register: result
      
    - name: Verify installation
      command: which wget
      register: wget_path
      
    - name: Show result
      debug:
        msg: "wget installed at {{ wget_path.stdout }}"
```

## Troubleshooting

### Common Issues and Solutions

1. **SSH Connection Failed**
   ```bash
   # Test SSH connectivity
   ansible app_servers -i inventory -m ping
   ```

2. **Permission Denied (sudo)**
   - Ensure users have sudo privileges on target servers
   - Add `ansible_become_pass` if sudo password required

3. **Yum Module Not Found**
   - Verify target systems are CentOS/RHEL based
   - For Ubuntu/Debian, use `apt` module instead

4. **Package Installation Failed**
   ```bash
   # Check if repositories are available
   ansible app_servers -i inventory -m shell -a "yum repolist" --become
   ```

## Verification Commands

### Before Installation
```bash
# Check if wget is installed
ansible app_servers -i inventory -m shell -a "which wget" --become
```

### After Installation
```bash
# Verify wget is installed and working
ansible app_servers -i inventory -m shell -a "wget --version" --become
```

## Expected Output
```
PLAY [Install wget package on all app servers] ********************************

TASK [Install wget package using yum] *****************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Display installation result] ********************************************
ok: [stapp01] => {
    "msg": "wget package installation completed on stapp01"
}
ok: [stapp02] => {
    "msg": "wget package installation completed on stapp02"
}
ok: [stapp03] => {
    "msg": "wget package installation completed on stapp03"
}

PLAY RECAP *********************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0
stapp02                    : ok=2    changed=1    unreachable=0    failed=0
stapp03                    : ok=2    changed=1    unreachable=0    failed=0
```

## Files Created
- `/home/thor/playbook/inventory` - Inventory file with all app servers
- `/home/thor/playbook/playbook.yml` - Main playbook for wget installation
- Solution works with the exact validation command: `ansible-playbook -i inventory playbook.yml`