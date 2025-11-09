# Day 092: Managing Jinja2 Templates Using Ansible - Complete Solution

## Challenge Overview and Requirements

### Core Challenge Requirements
1- **`owner: "{{ ansible_user }}"`** - Sets owner to connecting user (tony)
- **`group: "{{ ansible_user }}"`** - Sets group to connecting user (tony)
- **`mode: '0644'`** - Required file permissions*Update playbook.yml** to run httpd role on App Server 1 (stapp01)
2. **Create Jinja2 template** `index.html.j2` with dynamic server name using `inventory_hostname`
3. **Add template task** to copy temp### Security Considerations

### File Permissions Analysis
- **0644 permissions** - Owner can read/write, group and others can read
- **Owner: tony** - File owned by the connecting user
- **Web accessible** - File is in web root directory

**Note:** The challenge specifically requires 0644 permissions, which gives:
- Owner (tony): read, write (rw-)
- Group: read only (r--)
- Others: read only (r--)o `/var/www/html/index.html` with 0744 permissions
4. **Set proper ownership** to respective sudo user (tony for stapp01)
5. **Ensure role functionality** with httpd installation and service management

## Step-by-Step Solution

### Step 1: Directory Structure Setup

Create the required Ansible role directory structure:

```bash
# Create directory structure on jump host
mkdir -p /home/thor/ansible/role/httpd/{tasks,templates,handlers,vars,meta}
```

**Expected Structure:**
```
/home/thor/ansible/
├── inventory
├── playbook.yml
└── role/
    └── httpd/
        ├── tasks/
        │   └── main.yml
        ├── templates/
        │   └── index.html.j2
        ├── handlers/
        │   └── main.yml
        ├── vars/
        └── meta/
```

### Step 2: Inventory Configuration

The inventory file should already exist at `~/ansible/inventory`:

```ini
stapp01 ansible_host=172.16.238.10 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=172.16.238.11 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=172.16.238.12 ansible_ssh_pass=BigGr33n ansible_user=banner
```

**Key Points:**
- App Server 1 (stapp01) has user `tony`
- This will be used for file ownership

### Step 3: Create Playbook for App Server 1

Create `/home/thor/ansible/playbook.yml`:

```yaml
---
# Day 092: Managing Jinja2 Templates using Ansible
# Path: ~/ansible/playbook.yml

- name: Deploy httpd role on App Server 1
  hosts: stapp01
  become: yes
  become_method: sudo
  gather_facts: yes
  
  roles:
    - role/httpd
```

**Critical Configuration:**
- **`hosts: stapp01`** - Targets only App Server 1
- **`gather_facts: yes`** - Required for `inventory_hostname` variable
- **`become: yes`** - Required for httpd installation and file management

### Step 4: Create Jinja2 Template

Create `/home/thor/ansible/role/httpd/templates/index.html.j2`:

```jinja2
This file was created using Ansible on {{ inventory_hostname }}
```

**Jinja2 Template Explanation:**
- **`{{ inventory_hostname }}`** - Ansible built-in variable containing the hostname from inventory
- **Dynamic content** - Will render as "This file was created using Ansible on stapp01"
- **No hardcoding** - Server name is dynamically retrieved

### Step 5: Create Role Tasks

Create `/home/thor/ansible/role/httpd/tasks/main.yml`:

```yaml
---
# Main tasks for httpd role
# Path: /home/thor/ansible/role/httpd/tasks/main.yml

- name: Install httpd package
  yum:
    name: httpd
    state: present

- name: Start and enable httpd service
  systemd:
    name: httpd
    state: started
    enabled: yes

- name: Create index.html from Jinja2 template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    owner: "{{ ansible_user }}"
    group: "{{ ansible_user }}"
    mode: '0644'
    backup: yes
  notify: restart httpd

- name: Ensure httpd is running
  systemd:
    name: httpd
    state: started
```

**Task Breakdown:**
1. **Install httpd** - Package installation
2. **Start service** - Ensure httpd is running and enabled
3. **Template deployment** - Key task using Jinja2 template
4. **Service verification** - Final check

**Template Task Details:**
- **`src: index.html.j2`** - Template file in templates/ directory
- **`dest: /var/www/html/index.html`** - Target file location
- **`owner: "{{ ansible_user }}"`** - Sets owner to connecting user (banner)
- **`group: "{{ ansible_user }}"`** - Sets group to connecting user (banner)
- **`mode: '0744'`** - Required file permissions
- **`backup: yes`** - Creates backup before changes
- **`notify: restart httpd`** - Triggers handler if template changes

### Step 6: Create Handlers

Create `/home/thor/ansible/role/httpd/handlers/main.yml`:

```yaml
---
# Handlers for httpd role
# Path: /home/thor/ansible/role/httpd/handlers/main.yml

- name: restart httpd
  systemd:
    name: httpd
    state: restarted
```

**Handler Purpose:**
- **Triggered by template changes** - Only restarts httpd when template is updated
- **Efficiency** - Avoids unnecessary service restarts

### Step 7: Execute the Solution

```bash
# Navigate to ansible directory
cd /home/thor/ansible

# Run the playbook (validation command)
ansible-playbook -i inventory playbook.yml
```

## Expected Execution Results

### Successful Playbook Output
```
PLAY [Deploy httpd role on App Server 1] **************************************

TASK [Gathering Facts] *********************************************************
ok: [stapp01]

TASK [role/httpd : Install httpd package] *************************************
changed: [stapp01]

TASK [role/httpd : Start and enable httpd service] ****************************
changed: [stapp01]

TASK [role/httpd : Create index.html from Jinja2 template] ********************
changed: [stapp01]

TASK [role/httpd : Ensure httpd is running] ***********************************
ok: [stapp01]

RUNNING HANDLER [role/httpd : restart httpd] **********************************
changed: [stapp01]

PLAY RECAP *********************************************************************
stapp01                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### Verification Commands

#### 1. Check File Content
```bash
ansible stapp01 -i inventory -m shell -a "cat /var/www/html/index.html" --become
```

**Expected Output:**
```
stapp01 | CHANGED | rc=0 >>
This file was created using Ansible on stapp01
```

#### 2. Check File Permissions and Ownership
```bash
ansible stapp01 -i inventory -m shell -a "ls -la /var/www/html/index.html" --become
```

**Expected Output:**
```
stapp01 | CHANGED | rc=0 >>
-rw-r--r-- 1 tony tony 48 Nov 8 10:00 /var/www/html/index.html
```

#### 3. Check HTTP Service Status
```bash
ansible stapp01 -i inventory -m shell -a "systemctl status httpd" --become
```

#### 4. Test Web Server Response
```bash
ansible stapp01 -i inventory -m shell -a "curl localhost" --become
```

## Key Learning Points

### 1. Jinja2 Template Variables
- **`inventory_hostname`** - Built-in Ansible variable
- **Dynamic content generation** - Templates adapt to different servers
- **No hardcoding** - Server names retrieved automatically

### 2. Ansible Role Structure
- **Modular organization** - Tasks, templates, handlers separated
- **Reusability** - Roles can be used across multiple playbooks
- **Best practices** - Following Ansible role conventions

### 3. Template Module Features
- **File permissions** - Directly set in template task
- **Ownership management** - Dynamic user assignment
- **Backup functionality** - Automatic backup before changes
- **Handler triggers** - Notify handlers when templates change

### 4. Production Considerations
- **Variable validation** - Ensure required variables exist
- **Error handling** - Backup and rollback capabilities
- **Security** - Proper file permissions and ownership
- **Idempotency** - Safe to run multiple times

## Advanced Template Features (Production Extensions)

### 1. Enhanced Template with System Information
```jinja2
<!DOCTYPE html>
<html>
<head>
    <title>Server: {{ inventory_hostname }}</title>
</head>
<body>
    <h1>This file was created using Ansible on {{ inventory_hostname }}</h1>
    
    <h2>System Information</h2>
    <ul>
        <li>IP Address: {{ ansible_default_ipv4.address }}</li>
        <li>OS: {{ ansible_distribution }} {{ ansible_distribution_version }}</li>
        <li>Kernel: {{ ansible_kernel }}</li>
        <li>Memory: {{ ansible_memtotal_mb }}MB</li>
        <li>CPU: {{ ansible_processor_cores }} cores</li>
    </ul>
    
    <h2>Deployment Information</h2>
    <ul>
        <li>Deploy Time: {{ ansible_date_time.iso8601 }}</li>
        <li>Deployed by: {{ ansible_user }}</li>
        <li>Environment: {{ environment | default('production') }}</li>
    </ul>
</body>
</html>
```

### 2. Conditional Content Based on Server
```jinja2
This file was created using Ansible on {{ inventory_hostname }}

{% if inventory_hostname == 'stapp01' %}
This is the primary application server.
{% elif inventory_hostname == 'stapp02' %}
This is the secondary application server.
{% elif inventory_hostname == 'stapp03' %}
This is the tertiary application server.
{% endif %}

Server Role: {{ server_role | default('web-server') }}
Last Updated: {{ ansible_date_time.iso8601 }}
```

### 3. Production Variable Management
```yaml
# group_vars/app_servers.yml
server_role: web-server
environment: production
app_version: "2.1.0"

# host_vars/stapp03.yml
server_role: web-server-tertiary
special_config: true
backup_server: true
```

## Troubleshooting Guide

### Common Issues and Solutions

1. **Template not found error**
   ```
   Error: template not found: index.html.j2
   ```
   **Solution:** Ensure template is in `/home/thor/ansible/role/httpd/templates/`

2. **Permission denied on file creation**
   ```
   Error: Permission denied: /var/www/html/index.html
   ```
   **Solution:** Verify `become: yes` is set in playbook

3. **Variable undefined error**
   ```
   Error: 'inventory_hostname' is undefined
   ```
   **Solution:** Ensure `gather_facts: yes` is set in playbook

4. **Handler not triggered**
   ```
   Handler 'restart httpd' not running
   ```
   **Solution:** Check handler name matches notify name exactly

5. **Role not found**
   ```
   Error: the role 'role/httpd' was not found
   ```
   **Solution:** Verify role directory structure and path in playbook

## Security Considerations

### File Permissions Analysis
- **0755 permissions** - Owner can read/write/execute, group and others can read/execute
- **Owner: banner** - File owned by the connecting user
- **Web accessible** - File is in web root directory

### Production Security Enhancements
```yaml
# Enhanced security template task
- name: Create index.html from Jinja2 template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0644'  # More restrictive permissions
    backup: yes
    validate: 'html5validator %s'  # Validate HTML syntax
  notify: restart httpd
```

This solution demonstrates the power of Jinja2 templating in creating dynamic, reusable configurations while maintaining proper security and operational practices.