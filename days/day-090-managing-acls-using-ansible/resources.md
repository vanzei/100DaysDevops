# Access Control Lists (ACLs) - Comprehensive Guide

## Overview

Access Control Lists (ACLs) provide a more flexible and granular permission system than traditional Unix file permissions. While standard Unix permissions only allow setting permissions for owner, group, and others, ACLs enable you to grant specific permissions to multiple users and groups on the same file or directory.

## Traditional vs. ACL Permissions

### Traditional Unix Permissions
```bash
# Standard permissions: owner-group-others
-rw-r--r-- 1 root root 1024 Nov 7 10:00 file.txt
# Only 3 entities: root(owner), root(group), others
```

### ACL Extended Permissions
```bash
# ACL permissions allow multiple users/groups
-rw-r--r--+ 1 root root 1024 Nov 7 10:00 file.txt
# The '+' indicates extended ACL permissions are set
# Can have permissions for: root, john, alice, admin-group, dev-group, etc.
```

## ACL Components and Terminology

### Key Concepts

| Term | Description | Example |
|------|-------------|---------|
| **Entity** | The user or group receiving permissions | `john`, `admin-group` |
| **Entity Type (etype)** | Whether entity is user or group | `user`, `group` |
| **Permissions** | Access rights granted | `r` (read), `w` (write), `x` (execute) |
| **Mask** | Maximum permissions for named users/groups | `rwx` |
| **Default ACL** | ACL inherited by new files/directories | Applied to new children |

### ACL Entry Format
```
[d[efault]:] [u[ser]:]uid [:perms]
[d[efault]:] g[roup]:gid [:perms]
[d[efault]:] m[ask][:] [:perms]
[d[efault]:] o[ther][:] [:perms]
```

## ACL Commands and Operations

### Basic Commands

#### View ACL Information
```bash
# Display ACL for a file/directory
getfacl /path/to/file

# Example output:
# file: /opt/data/report.txt
# owner: root
# group: root
# user::rw-
# user:john:r--
# user:alice:rw-
# group::r--
# group:developers:rw-
# mask::rw-
# other::---
```

#### Set ACL Permissions
```bash
# Grant user john read permission
setfacl -m u:john:r /path/to/file

# Grant group developers read/write permission
setfacl -m g:developers:rw /path/to/file

# Set multiple permissions at once
setfacl -m u:john:r,g:developers:rw,u:alice:rwx /path/to/file
```

#### Remove ACL Permissions
```bash
# Remove specific ACL entry
setfacl -x u:john /path/to/file

# Remove all ACL entries (keep base permissions)
setfacl -b /path/to/file

# Remove default ACL entries
setfacl -k /path/to/directory
```

### Advanced Operations

#### Recursive ACL Management
```bash
# Apply ACL recursively to directory and all contents
setfacl -R -m u:john:rwx /path/to/directory

# Set default ACL for new files in directory
setfacl -d -m u:john:rwx /path/to/directory

# Combine recursive and default
setfacl -R -d -m u:john:rwx /path/to/directory
```

#### Copy ACL Between Files
```bash
# Copy ACL from source to destination
getfacl /source/file | setfacl --set-file=- /destination/file
```

## Ansible ACL Module

### Module Parameters

| Parameter | Description | Options | Required |
|-----------|-------------|---------|----------|
| `path` | Target file/directory path | File system path | Yes |
| `entity` | User or group name | Username or groupname | Yes* |
| `etype` | Entity type | `user`, `group` | Yes* |
| `permissions` | Access permissions | `r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx` | Yes* |
| `state` | ACL entry state | `present`, `absent` | No (default: present) |
| `default` | Set as default ACL | `yes`, `no` | No (default: no) |
| `recursive` | Apply recursively | `yes`, `no` | No (default: no) |
| `follow` | Follow symbolic links | `yes`, `no` | No (default: yes) |

*Required when state=present

### Basic Ansible Examples

#### Single ACL Entry
```yaml
- name: Grant user john read access to file
  acl:
    path: /opt/data/report.txt
    entity: john
    etype: user
    permissions: r
    state: present
```

#### Multiple ACL Entries
```yaml
- name: Set multiple ACL permissions
  acl:
    path: /opt/shared/{{ item.path }}
    entity: "{{ item.entity }}"
    etype: "{{ item.etype }}"
    permissions: "{{ item.permissions }}"
    state: present
  loop:
    - { path: "project1.txt", entity: "john", etype: "user", permissions: "rw" }
    - { path: "project1.txt", entity: "developers", etype: "group", permissions: "r" }
    - { path: "project2.txt", entity: "alice", etype: "user", permissions: "rwx" }
```

#### Default ACL for Directories
```yaml
- name: Set default ACL for new files in directory
  acl:
    path: /opt/shared/projects
    entity: developers
    etype: group
    permissions: rw
    default: yes
    state: present
```

## Real-World Production Scenarios

### 1. Application Deployment and Access Control

#### Scenario: Web Application with Multiple Teams
```yaml
---
- name: Configure web application ACLs
  hosts: web_servers
  become: yes
  
  vars:
    app_path: /var/www/html/myapp
    
  tasks:
    # Create application directory structure
    - name: Create application directories
      file:
        path: "{{ item }}"
        state: directory
        owner: apache
        group: apache
        mode: '0755'
      loop:
        - "{{ app_path }}"
        - "{{ app_path }}/logs"
        - "{{ app_path }}/config"
        - "{{ app_path }}/uploads"
        
    # Development team: read/write access to application files
    - name: Grant developers access to application files
      acl:
        path: "{{ app_path }}"
        entity: developers
        etype: group
        permissions: rw
        recursive: yes
        state: present
        
    # Operations team: full access to logs directory
    - name: Grant operations team access to logs
      acl:
        path: "{{ app_path }}/logs"
        entity: operations
        etype: group
        permissions: rwx
        recursive: yes
        state: present
        
    # Security team: read-only access for auditing
    - name: Grant security team read access for auditing
      acl:
        path: "{{ app_path }}"
        entity: security-audit
        etype: group
        permissions: r
        recursive: yes
        state: present
        
    # Specific user: database admin access to config
    - name: Grant DBA access to config directory
      acl:
        path: "{{ app_path }}/config"
        entity: dba-admin
        etype: user
        permissions: rw
        recursive: yes
        state: present
        
    # Set default ACL for future files
    - name: Set default ACL for uploads directory
      acl:
        path: "{{ app_path }}/uploads"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        default: yes
        state: present
      loop:
        - { entity: "apache", etype: "user", permissions: "rwx" }
        - { entity: "developers", etype: "group", permissions: "rw" }
        - { entity: "operations", etype: "group", permissions: "r" }
```

### 2. Shared File System for Collaborative Work

#### Scenario: Research Data Sharing
```yaml
---
- name: Configure research data sharing ACLs
  hosts: research_servers
  become: yes
  
  vars:
    research_path: /data/research
    
  tasks:
    # Create research project directories
    - name: Create research project directories
      file:
        path: "{{ research_path }}/{{ item }}"
        state: directory
        owner: root
        group: research
        mode: '0750'
      loop:
        - project-alpha
        - project-beta
        - shared-resources
        - published-results
        
    # Project Alpha: Full access for team members, read for collaborators
    - name: Configure Project Alpha ACLs
      acl:
        path: "{{ research_path }}/project-alpha"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        recursive: yes
        default: yes
        state: present
      loop:
        - { entity: "alpha-team", etype: "group", permissions: "rwx" }
        - { entity: "research-collaborators", etype: "group", permissions: "r" }
        - { entity: "principal-investigator", etype: "user", permissions: "rwx" }
        
    # Project Beta: Different access pattern
    - name: Configure Project Beta ACLs
      acl:
        path: "{{ research_path }}/project-beta"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        recursive: yes
        default: yes
        state: present
      loop:
        - { entity: "beta-team", etype: "group", permissions: "rwx" }
        - { entity: "external-partners", etype: "group", permissions: "rw" }
        - { entity: "data-analyst", etype: "user", permissions: "r" }
        
    # Shared resources: Read access for all, write for leads
    - name: Configure shared resources ACLs
      acl:
        path: "{{ research_path }}/shared-resources"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        recursive: yes
        default: yes
        state: present
      loop:
        - { entity: "research", etype: "group", permissions: "r" }
        - { entity: "project-leads", etype: "group", permissions: "rw" }
        - { entity: "librarian", etype: "user", permissions: "rwx" }
```

### 3. Database and Log File Management

#### Scenario: Database Server Access Control
```yaml
---
- name: Configure database server ACLs
  hosts: database_servers
  become: yes
  
  vars:
    db_path: /var/lib/mysql
    log_path: /var/log/mysql
    backup_path: /backup/mysql
    
  tasks:
    # Database files: Strict access control
    - name: Configure database files ACL
      acl:
        path: "{{ db_path }}"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        recursive: yes
        state: present
      loop:
        - { entity: "mysql", etype: "user", permissions: "rwx" }
        - { entity: "dba-primary", etype: "user", permissions: "r" }
        - { entity: "backup-service", etype: "user", permissions: "r" }
        
    # Log files: Read access for monitoring and troubleshooting
    - name: Configure database log ACLs
      acl:
        path: "{{ log_path }}"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        recursive: yes
        default: yes
        state: present
      loop:
        - { entity: "mysql", etype: "user", permissions: "rw" }
        - { entity: "dba-team", etype: "group", permissions: "r" }
        - { entity: "monitoring", etype: "user", permissions: "r" }
        - { entity: "log-analyzer", etype: "user", permissions: "r" }
        
    # Backup directory: Controlled write access
    - name: Configure backup directory ACLs
      acl:
        path: "{{ backup_path }}"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        recursive: yes
        default: yes
        state: present
      loop:
        - { entity: "backup-service", etype: "user", permissions: "rwx" }
        - { entity: "dba-primary", etype: "user", permissions: "rwx" }
        - { entity: "dba-team", etype: "group", permissions: "r" }
        - { entity: "restore-service", etype: "user", permissions: "r" }
```

### 4. Multi-Tenant Application Environment

#### Scenario: SaaS Platform with Tenant Isolation
```yaml
---
- name: Configure multi-tenant ACLs
  hosts: app_servers
  become: yes
  
  vars:
    tenant_base: /opt/saas/tenants
    
  tasks:
    # Create tenant directories
    - name: Create tenant directories
      file:
        path: "{{ tenant_base }}/{{ item }}"
        state: directory
        owner: root
        group: saas-platform
        mode: '0755'
      loop:
        - tenant-001
        - tenant-002
        - tenant-003
        - shared-services
        
    # Tenant isolation: Each tenant can only access their own data
    - name: Configure tenant-specific ACLs
      acl:
        path: "{{ tenant_base }}/tenant-{{ '%03d' | format(item | int) }}"
        entity: "{{ tenant_entity.entity }}"
        etype: "{{ tenant_entity.etype }}"
        permissions: "{{ tenant_entity.permissions }}"
        recursive: yes
        default: yes
        state: present
      loop: [1, 2, 3]
      vars:
        tenant_entities:
          - { entity: "tenant-{{ '%03d' | format(item | int) }}-app", etype: "user", permissions: "rwx" }
          - { entity: "tenant-{{ '%03d' | format(item | int) }}-users", etype: "group", permissions: "rw" }
          - { entity: "platform-admin", etype: "user", permissions: "rwx" }
          - { entity: "monitoring", etype: "user", permissions: "r" }
      loop_control:
        loop_var: tenant_entity
        
    # Shared services: Read access for all tenants
    - name: Configure shared services ACLs
      acl:
        path: "{{ tenant_base }}/shared-services"
        entity: "{{ item.entity }}"
        etype: "{{ item.etype }}"
        permissions: "{{ item.permissions }}"
        recursive: yes
        default: yes
        state: present
      loop:
        - { entity: "saas-platform", etype: "group", permissions: "r" }
        - { entity: "platform-admin", etype: "user", permissions: "rwx" }
        - { entity: "shared-service", etype: "user", permissions: "rw" }
```

## Security Considerations and Best Practices

### 1. Principle of Least Privilege
```yaml
# Bad: Overly permissive
- name: Bad example - too permissive
  acl:
    path: /opt/sensitive-data
    entity: everyone
    etype: group
    permissions: rwx  # Too much access
    
# Good: Minimal necessary permissions
- name: Good example - least privilege
  acl:
    path: /opt/sensitive-data
    entity: data-readers
    etype: group
    permissions: r  # Only what's needed
```

### 2. Regular ACL Auditing
```yaml
---
- name: Audit ACL configurations
  hosts: all
  become: yes
  
  tasks:
    - name: Collect ACL information for critical paths
      shell: "getfacl {{ item }} 2>/dev/null || echo 'Path not found: {{ item }}'"
      register: acl_audit
      loop:
        - /etc/passwd
        - /opt/sensitive-data
        - /var/log/audit
        - /home/shared
      changed_when: false
      
    - name: Generate ACL report
      copy:
        content: |
          ACL Audit Report - {{ ansible_date_time.iso8601 }}
          Server: {{ inventory_hostname }}
          
          {% for result in acl_audit.results %}
          Path: {{ result.item }}
          {{ result.stdout }}
          
          {% endfor %}
        dest: /tmp/acl-audit-{{ inventory_hostname }}.txt
        
    - name: Check for world-writable files with ACLs
      shell: "find /opt /var -type f -perm -o+w -exec getfacl {} \\; 2>/dev/null | grep -E '^# file:|^other:.*w'"
      register: world_writable_acls
      changed_when: false
      failed_when: false
      
    - name: Alert if world-writable files found
      fail:
        msg: "Security Alert: World-writable files with ACLs found: {{ world_writable_acls.stdout_lines }}"
      when: world_writable_acls.stdout | length > 0
```

### 3. ACL Backup and Recovery
```yaml
---
- name: Backup and restore ACL configurations
  hosts: all
  become: yes
  
  tasks:
    # Backup ACLs
    - name: Create ACL backup directory
      file:
        path: /backup/acls
        state: directory
        mode: '0700'
        
    - name: Backup current ACL configurations
      shell: |
        getfacl -R {{ item }} > /backup/acls/acl-backup-{{ item | basename }}-{{ ansible_date_time.epoch }}.txt
      loop:
        - /opt
        - /var/www
        - /home/shared
      changed_when: false
      
    # Restore ACLs (when needed)
    - name: Restore ACL configurations
      shell: "setfacl --restore={{ acl_backup_file }}"
      when: restore_acls is defined and restore_acls
      vars:
        acl_backup_file: "{{ acl_backup_path | default('/backup/acls/latest-backup.txt') }}"
```

### 4. Performance Considerations
```yaml
# Efficient ACL management for large directory structures
- name: Optimize ACL operations for large directories
  block:
    # Use targeted operations instead of recursive for large trees
    - name: Set ACL on parent directory only
      acl:
        path: /large/directory/tree
        entity: users
        etype: group
        permissions: rw
        default: yes  # This will apply to new files
        
    # For existing files, use find with xargs for better performance
    - name: Apply ACL to existing files efficiently
      shell: |
        find /large/directory/tree -type f -print0 | 
        xargs -0 -P 4 -n 100 setfacl -m g:users:rw
      when: apply_to_existing_files | default(false)
```

## Troubleshooting Common ACL Issues

### 1. ACL Not Working
```bash
# Check if filesystem supports ACLs
mount | grep -E "(ext[34]|xfs|btrfs)" | grep acl

# Remount with ACL support if needed
mount -o remount,acl /mount/point

# Check ACL package installation
rpm -qa | grep acl
# or
dpkg -l | grep acl
```

### 2. Permission Denied Despite ACL
```bash
# Check effective permissions (mask)
getfacl /path/to/file

# The mask limits maximum permissions for named users/groups
# If mask is r-- but user ACL is rw-, effective permission is r--

# Fix mask if needed
setfacl -m m::rw /path/to/file
```

### 3. Inheritance Issues
```bash
# Check default ACLs on parent directory
getfacl /parent/directory

# Set default ACL if missing
setfacl -d -m u:john:rw /parent/directory

# Apply to existing files
setfacl -R -m u:john:rw /parent/directory
```

## Monitoring and Compliance

### 1. ACL Change Monitoring
```yaml
- name: Monitor ACL changes with auditd
  lineinfile:
    path: /etc/audit/rules.d/acl.rules
    line: "{{ item }}"
    create: yes
  loop:
    - "-w /usr/bin/setfacl -p x -k acl_changes"
    - "-w /usr/bin/getfacl -p x -k acl_access"
  notify: restart auditd
```

### 2. Compliance Reporting
```yaml
- name: Generate ACL compliance report
  shell: |
    echo "ACL Compliance Report - $(date)" > /tmp/acl-compliance.txt
    echo "================================" >> /tmp/acl-compliance.txt
    
    # Check for files with excessive permissions
    find /opt -type f -perm -o+w -exec getfacl {} \; | 
    grep -E "^# file:|^other:.*w" >> /tmp/acl-compliance.txt
    
    # Check for default ACLs on sensitive directories
    for dir in /etc /opt /var/log; do
      if [ -d "$dir" ]; then
        echo "Default ACLs for $dir:" >> /tmp/acl-compliance.txt
        getfacl -d "$dir" 2>/dev/null >> /tmp/acl-compliance.txt || 
        echo "No default ACLs set" >> /tmp/acl-compliance.txt
      fi
    done
  register: compliance_report
```

## Integration with Configuration Management

### 1. ACL Templates and Variables
```yaml
# Group variables for different environments
# group_vars/production.yml
acl_configs:
  web_servers:
    - path: /var/www/html
      entity: web-developers
      etype: group
      permissions: rw
    - path: /var/log/httpd
      entity: log-analyzers
      etype: group
      permissions: r
      
  database_servers:
    - path: /var/lib/mysql
      entity: dba-team
      etype: group
      permissions: r
    - path: /backup/mysql
      entity: backup-operators
      etype: group
      permissions: rw

# Playbook using templates
- name: Apply environment-specific ACLs
  acl:
    path: "{{ item.path }}"
    entity: "{{ item.entity }}"
    etype: "{{ item.etype }}"
    permissions: "{{ item.permissions }}"
    recursive: "{{ item.recursive | default(false) }}"
    default: "{{ item.default | default(false) }}"
    state: present
  loop: "{{ acl_configs[server_role] | default([]) }}"
  when: server_role is defined
```

ACLs provide essential granular access control capabilities that extend far beyond traditional Unix permissions, making them crucial for enterprise environments requiring sophisticated access management while maintaining security and compliance standards.