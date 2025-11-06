# Day 084: Copy Data to App Servers - Complete Solution

## Challenge Requirements Analysis

### What We Need to Do
1. **Create inventory file** `/home/thor/ansible/inventory` with all application servers
2. **Create playbook** `/home/thor/ansible/playbook.yml` to copy file
3. **Source file**: `/usr/src/data/index.html` (on jump host)
4. **Destination**: `/opt/data/` (on all app servers)
5. **Target servers**: All application servers in Stratos DC (stapp01, stapp02, stapp03)

## Solution Files

### 1. Inventory File: `/home/thor/ansible/inventory`

```ini
# Ansible Inventory for All App Servers
# Day 084 Challenge Solution

[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass="Ir0nM@n" ansible_become=yes ansible_become_pass="Ir0nM@n" ansible_become_method=sudo ansible_become_user=root ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'

stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass="Am3ric@" ansible_become=yes ansible_become_pass="Am3ric@" ansible_become_method=sudo ansible_become_user=root ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'

stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass="BigGr33n" ansible_become=yes ansible_become_pass="BigGr33n" ansible_become_method=sudo ansible_become_user=root ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'
```

### 2. Playbook File: `/home/thor/ansible/playbook.yml`

```yaml
---
# Ansible Playbook for Day 084 Challenge
# Copy index.html file to all application servers
# File: /home/thor/ansible/playbook.yml

- name: Copy data file to all application servers
  hosts: app_servers
  gather_facts: no
  
  tasks:
    - name: Ensure destination directory exists
      file:
        path: /opt/data
        state: directory
        mode: '0755'
        owner: root
        group: root
    
    - name: Copy index.html file to application servers
      copy:
        src: /usr/src/data/index.html
        dest: /opt/data/index.html
        mode: '0644'
        owner: root
        group: root
        backup: yes
```

## Ansible Module Documentation and Examples

### How to Find Module Options and Examples

#### 1. **Using `ansible-doc` Command (Best Method)**

```bash
# Get detailed documentation for copy module
ansible-doc copy

# Get examples for copy module
ansible-doc copy -e

# List all available modules
ansible-doc -l

# Search for modules related to files
ansible-doc -l | grep file

# Get help for file module
ansible-doc file
```

#### 2. **Online Ansible Documentation**
- **Official Docs**: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/
- **Module Index**: https://docs.ansible.com/ansible/latest/modules/modules_by_category.html
- **Copy Module**: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html

#### 3. **Using `ansible-playbook --help`**
```bash
# Get playbook help
ansible-playbook --help

# Get syntax help
ansible-playbook --syntax-check playbook.yml
```

### Key Ansible Modules for File Operations

#### **copy Module** (Used in this challenge)
```yaml
# Basic copy
- name: Copy file
  copy:
    src: /path/to/source/file
    dest: /path/to/destination/file

# Copy with permissions and backup
- name: Copy with options
  copy:
    src: /usr/src/data/index.html
    dest: /opt/data/index.html
    mode: '0644'
    owner: root
    group: root
    backup: yes
    force: yes
```

**Common copy module parameters:**
- `src`: Source file path (on control node)
- `dest`: Destination file path (on managed nodes)
- `mode`: File permissions (e.g., '0644', '0755')
- `owner`: File owner
- `group`: File group
- `backup`: Create backup of existing file
- `force`: Overwrite existing files
- `directory_mode`: Permissions for created directories

#### **file Module** (For directory creation)
```yaml
# Create directory
- name: Create directory
  file:
    path: /opt/data
    state: directory
    mode: '0755'
    owner: root
    group: root

# Create empty file
- name: Create empty file
  file:
    path: /tmp/file.txt
    state: touch
    mode: '0644'

# Remove file
- name: Remove file
  file:
    path: /tmp/unwanted.txt
    state: absent
```

**Common file module parameters:**
- `path`: File/directory path
- `state`: directory, file, touch, absent, link
- `mode`: Permissions
- `owner`: Owner user
- `group`: Owner group
- `recurse`: Apply recursively (for directories)

#### **template Module** (For dynamic content)
```yaml
# Deploy template
- name: Deploy configuration
  template:
    src: config.j2
    dest: /etc/app/config.conf
    mode: '0644'
    backup: yes
```

#### **synchronize Module** (For rsync-like operations)
```yaml
# Synchronize directories
- name: Sync directories
  synchronize:
    src: /local/path/
    dest: /remote/path/
    delete: yes
    recursive: yes
```

### Module Parameters Discovery

#### **Finding Required vs Optional Parameters**

```bash
# View copy module documentation
ansible-doc copy
```

**Output shows:**
- **REQUIRED parameters** (marked with [Required])
- **Optional parameters** with default values
- **Examples section** with practical usage
- **Return values** (what the module returns)

#### **Parameter Types**
- **String**: Text values (paths, names)
- **Boolean**: yes/no, true/false
- **Integer**: Numeric values
- **List**: Array of values
- **Dictionary**: Key-value pairs

### Advanced Copy Operations

#### **Copy Multiple Files**
```yaml
# Copy multiple files using loop
- name: Copy multiple files
  copy:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
    mode: '0644'
  loop:
    - { src: '/usr/src/data/index.html', dest: '/opt/data/index.html' }
    - { src: '/usr/src/data/style.css', dest: '/opt/data/style.css' }
    - { src: '/usr/src/data/script.js', dest: '/opt/data/script.js' }
```

#### **Copy with Content Generation**
```yaml
# Create file with specific content
- name: Create file with content
  copy:
    content: |
      This is the content
      of the new file
      Generated by Ansible
    dest: /opt/data/generated.txt
    mode: '0644'
```

#### **Copy with Validation**
```yaml
# Copy with validation
- name: Copy and validate
  copy:
    src: /usr/src/data/index.html
    dest: /opt/data/index.html
    mode: '0644'
    backup: yes
    validate: 'html5validator %s'  # Validate HTML file
```

## Implementation Steps

### Step 1: Create Directory Structure
```bash
# Create ansible directory
mkdir -p /home/thor/ansible
cd /home/thor/ansible
```

### Step 2: Create Inventory File
```bash
cat > /home/thor/ansible/inventory << 'EOF'
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass="Ir0nM@n" ansible_become=yes ansible_become_pass="Ir0nM@n" ansible_become_method=sudo ansible_become_user=root ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'

stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass="Am3ric@" ansible_become=yes ansible_become_pass="Am3ric@" ansible_become_method=sudo ansible_become_user=root ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'

stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass="BigGr33n" ansible_become=yes ansible_become_pass="BigGr33n" ansible_become_method=sudo ansible_become_user=root ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password'
EOF
```

### Step 3: Create Playbook File
```bash
cat > /home/thor/ansible/playbook.yml << 'EOF'
---
- name: Copy data file to all application servers
  hosts: app_servers
  gather_facts: no
  
  tasks:
    - name: Ensure destination directory exists
      file:
        path: /opt/data
        state: directory
        mode: '0755'
        owner: root
        group: root
    
    - name: Copy index.html file to application servers
      copy:
        src: /usr/src/data/index.html
        dest: /opt/data/index.html
        mode: '0644'
        owner: root
        group: root
        backup: yes
EOF
```

### Step 4: Verify Source File Exists
```bash
# Check if source file exists
ls -la /usr/src/data/index.html

# If it doesn't exist, create it for testing
sudo mkdir -p /usr/src/data
echo "<html><body><h1>Hello from Nautilus!</h1></body></html>" | sudo tee /usr/src/data/index.html
```

### Step 5: Test and Execute
```bash
# Test inventory
ansible-inventory -i inventory --list

# Test connectivity
ansible -i inventory app_servers -m ping

# Run playbook
ansible-playbook -i inventory playbook.yml

# Verify file was copied
ansible -i inventory app_servers -m command -a "ls -la /opt/data/"
```

## Quick Reference: Common Ansible Modules

### File Operations
- **copy**: Copy files from control node to managed nodes
- **file**: Manage files and directories
- **template**: Deploy Jinja2 templates
- **fetch**: Copy files from managed nodes to control node
- **synchronize**: Sync directories (uses rsync)
- **unarchive**: Extract archives
- **archive**: Create archives

### System Operations
- **command**: Run commands
- **shell**: Run shell commands
- **service**: Manage services
- **systemd**: Manage systemd services
- **package**: Install packages (generic)
- **yum**: Install packages (RHEL/CentOS)
- **apt**: Install packages (Ubuntu/Debian)

### User Management
- **user**: Manage user accounts
- **group**: Manage groups
- **authorized_key**: Manage SSH keys

### Network Operations
- **uri**: Interact with web services
- **get_url**: Download files from web
- **ping**: Test connectivity

## Module Documentation Quick Commands

```bash
# Essential commands for finding module information
ansible-doc -l                    # List all modules
ansible-doc copy                  # Full documentation for copy module
ansible-doc copy -e               # Examples for copy module
ansible-doc -l | grep -i file     # Find file-related modules
ansible-doc -l | grep -i network  # Find network-related modules
ansible-doc -l | grep -i service  # Find service-related modules
```

This comprehensive guide shows you exactly how the playbook should look for Challenge 84 and provides you with the tools to discover and understand Ansible module options and examples!