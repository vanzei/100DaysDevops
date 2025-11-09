# Day 091: Ansible Lineinfile Module - Solution

## Challenge Requirements
1. Install httpd web server on all app servers and ensure service is running
2. Create `/var/www/html/index.html` with content: `"This is a Nautilus sample file, created using Ansible!"`
3. Use `lineinfile` module to add `"Welcome to xFusionCorp Industries!"` **at the top** of the file
4. Set file ownership to `apache:apache`
5. Set file permissions to `0744`
6. Playbook must work with: `ansible-playbook -i inventory playbook.yml`

## Solution Implementation

### Inventory File
```ini
stapp01 ansible_host=172.16.238.10 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=172.16.238.11 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=172.16.238.12 ansible_ssh_pass=BigGr33n ansible_user=banner
```

### Key Tasks Breakdown

#### 1. HTTP Server Installation and Service Management
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

#### 2. Initial File Creation
```yaml
- name: Create index.html with initial content
  copy:
    content: "This is a Nautilus sample file, created using Ansible!"
    dest: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0744'
```

#### 3. Lineinfile Module Usage (Key Requirement)
```yaml
- name: Add welcome message at the top of index.html using lineinfile
  lineinfile:
    path: /var/www/html/index.html
    line: "Welcome to xFusionCorp Industries!"
    insertbefore: BOF
    state: present
```

**Critical Parameter**: `insertbefore: BOF` (Beginning Of File) ensures the new line is added at the top.

#### 4. File Ownership and Permissions
```yaml
- name: Set correct ownership and permissions for index.html
  file:
    path: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0744'
```

## Execution Instructions

### Step 1: Navigate to Directory
```bash
cd /home/thor/ansible
```

### Step 2: Execute Playbook
```bash
ansible-playbook -i inventory playbook.yml
```

## Expected Results

### Final File Content
After successful execution, `/var/www/html/index.html` should contain:
```
Welcome to xFusionCorp Industries!
This is a Nautilus sample file, created using Ansible!
```

### File Properties
- **Owner**: apache
- **Group**: apache  
- **Permissions**: 0744 (rwxr--r--)
- **Location**: `/var/www/html/index.html`

### Service Status
- **httpd service**: Started and enabled
- **Status**: Active (running)

## Lineinfile Module Deep Dive

### Key Parameters Used
| Parameter | Value | Purpose |
|-----------|-------|---------|
| `path` | `/var/www/html/index.html` | Target file |
| `line` | `"Welcome to xFusionCorp Industries!"` | Content to add |
| `insertbefore` | `BOF` | Insert at beginning of file |
| `state` | `present` | Ensure line exists |

### Alternative insertbefore Options
- `BOF` - Beginning of file (used in our solution)
- `EOF` - End of file
- `regex_pattern` - Insert before line matching pattern
- `line_content` - Insert before specific line content

### Common Lineinfile Use Cases
```yaml
# Insert at end of file
- lineinfile:
    path: /etc/hosts
    line: "192.168.1.100 myserver.local"
    
# Insert after specific pattern
- lineinfile:
    path: /etc/ssh/sshd_config
    line: "AllowUsers admin"
    insertafter: "^#AllowUsers"
    
# Replace existing line
- lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=disabled'
```

## Verification Commands

### Check File Content
```bash
ansible all -i inventory -m shell -a "cat /var/www/html/index.html" --become
```

### Check File Permissions
```bash
ansible all -i inventory -m shell -a "ls -la /var/www/html/index.html" --become
```

### Check HTTP Service
```bash
ansible all -i inventory -m shell -a "systemctl status httpd" --become
```

### Test Web Server Response
```bash
ansible all -i inventory -m shell -a "curl localhost" --become
```

## Expected Playbook Output
```
PLAY [Install httpd and configure web page using lineinfile module] ***********

TASK [Install httpd web server] ***********************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Start and enable httpd service] *****************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Create index.html with initial content] ********************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Add welcome message at the top of index.html using lineinfile] *********
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Set correct ownership and permissions for index.html] ******************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=5    changed=4    unreachable=0    failed=0
stapp02                    : ok=5    changed=4    unreachable=0    failed=0
stapp03                    : ok=5    changed=4    unreachable=0    failed=0
```

## Troubleshooting Guide

### Common Issues

1. **Lineinfile not adding content at the top**
   - Ensure `insertbefore: BOF` is specified
   - Check file already exists before running lineinfile

2. **Permission denied errors**
   - Verify `become: yes` is set
   - Check SSH connectivity and sudo privileges

3. **HTTP service not starting**
   - Check if port 80 is available
   - Verify firewall settings if needed

4. **File ownership incorrect**
   - Ensure apache user/group exists
   - Run file ownership task after file creation

## Key Learning Points

### Lineinfile vs Other Modules
- **lineinfile**: Single line modifications
- **blockinfile**: Multi-line block insertions
- **replace**: Pattern-based replacements
- **copy/template**: Complete file creation

### Best Practices
1. **Idempotency**: Lineinfile is idempotent - safe to run multiple times
2. **Backup**: Use `backup: yes` for critical files
3. **Validation**: Include verification tasks to confirm changes
4. **Order**: Create file before using lineinfile on it

This solution demonstrates effective use of the lineinfile module for precise file content management while maintaining proper service configuration and file security.