# Day 088: Ansible Blockinfile Module - Solution

## Challenge Requirements
1. Create playbook.yml under `/home/thor/ansible` directory
2. Install httpd web server on all app servers and ensure service is running
3. Use blockinfile module to add specific content to `/var/www/html/index.html`
4. Set file ownership to apache:apache and permissions to 0644
5. Do not use custom or empty markers for blockinfile module

## Solution Implementation

### Files Created
- `inventory` - App servers configuration
- `playbook.yml` - Main playbook for httpd installation and configuration

### Inventory Configuration
```ini
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=Ir0nM@n
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=BigGr33n
```

### Playbook Execution
```bash
# Change to ansible directory
cd /home/thor/ansible

# Execute the playbook (validation command)
ansible-playbook -i inventory playbook.yml
```

## Key Tasks Implemented

### 1. httpd Installation and Service Management
```yaml
- name: Install httpd web server
  yum:
    name: httpd
    state: present

- name: Start and enable httpd service
  systemd:
    name: httpd
    state: started
    enabled: yes
```

### 2. Blockinfile Module Usage
```yaml
- name: Add content to index.html using blockinfile
  blockinfile:
    path: /var/www/html/index.html
    create: yes
    block: |
      Welcome to XfusionCorp!
      
      This is  Nautilus sample file, created using Ansible!
      
      Please do not modify this file manually!
```

### 3. File Permissions and Ownership
```yaml
- name: Set ownership of index.html to apache user and group
  file:
    path: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0644'
```

## Expected Output
The playbook should successfully:
- Install httpd on all app servers
- Start and enable the httpd service
- Create index.html with the specified content using blockinfile
- Set proper ownership (apache:apache) and permissions (0644)

## Verification Commands
```bash
# Check httpd service status
ansible app_servers -i inventory -m shell -a "systemctl status httpd" --become

# Verify file content
ansible app_servers -i inventory -m shell -a "cat /var/www/html/index.html" --become

# Check file permissions
ansible app_servers -i inventory -m shell -a "ls -la /var/www/html/index.html" --become

# Test web server response
ansible app_servers -i inventory -m shell -a "curl localhost" --become
```